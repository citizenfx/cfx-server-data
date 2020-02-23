using System;

using CitizenFX.Core;
using static CitizenFX.Core.Native.API;

using Microsoft.Extensions.DependencyInjection;

using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;

using FluentMigrator.Runner;
using FluentMigrator.Runner.Initialization;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using FluentMigrator;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;
using FluentMigrator.Runner.Processors.MySql;
using MySql.Data.MySqlClient;
using System.Data.Common;
using FluentMigrator.Runner.VersionTableInfo;

namespace FxMigrant
{
    public class Main : BaseScript
    {
        private bool m_ticked;

        private readonly Queue<string> m_migrationQueue = new Queue<string>();

        public Main()
        {
            Debug.WriteLine(typeof(MySql.Data.MySqlClient.MySqlConnection).Name);

            // to work around mysql-async ready event not triggering on starts
            Exports.Add("hasTicked", new Func<bool>(() => m_ticked));
        }

        [EventHandler("onServerResourceStart")]
        public async void OnServerResourceStart(string resourceName)
        {
            m_migrationQueue.Enqueue(resourceName);
        }

        [Tick]
        public async Task RunTick()
        {
            m_ticked = true;

            while (m_migrationQueue.Count > 0)
            {
                await Delay(0);
                await MigrateResource(m_migrationQueue.Dequeue());
            }
        }

        private async Task MigrateResource(string resourceName)
        {
            var cs = GetConvar("mysql_connection_string", "");
            var numMetaData = GetNumResourceMetadata(resourceName, "migration_file");

            if (numMetaData > 0)
            {
                var migrationAssemblies = new List<Assembly>();

                for (var md = 0; md < numMetaData; md++)
                {
                    await Delay(0);

                    var mdFileName = GetResourceMetadata(resourceName, "migration_file", md);
                    var migrationAssembly = await LoadMigrationAssembly(resourceName, mdFileName);

                    if (migrationAssembly != null)
                    {
                        migrationAssemblies.Add(migrationAssembly);
                    }
                }
                
                var sc = new ServiceCollection()
                    .AddFluentMigratorCore()
                    .AddScoped<IVersionLoader>(sp => 
                    {
                        var service = ActivatorUtilities.CreateInstance<FxVersionLoader>(sp, resourceName);

                        return service;
                    })
                    .ConfigureRunner(rb =>
                    {
                        rb.Services.AddScoped<MySqlDbFactory, MySqlConnectorDbFactory>();

                        rb.AddMySql5()
                            .WithGlobalConnectionString(cs)
                            .WithMigrationsIn(migrationAssemblies.ToArray())
                            .WithVersionTable(new FxVersionTable());
                    })
                    .BuildServiceProvider(false);

                using (var scope = sc.CreateScope())
                {
                    var runner = scope.ServiceProvider.GetRequiredService<IMigrationRunner>();
                    var loader = scope.ServiceProvider.GetRequiredService<IVersionLoader>();

                    SynchronizationContext.SetSynchronizationContext(new SynchronizationContext());

                    await Task.Factory.StartNew(async () => 
                    {
                        bool success = false;

                        try
                        {
                            runner.MigrateUp();
                            success = true;
                        }
                        catch (Exception e)
                        {
                            Debug.WriteLine(e.ToString());
                            Debug.WriteLine($"^1Failed to migrate for resource {resourceName}.^7");
                        }

                        await Delay(0);

                        TriggerEvent("fxmigrant:resourceDone", resourceName, success);
                    }, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.FromCurrentSynchronizationContext());
                }
            }
        }

        private async Task<Assembly> LoadMigrationAssembly(string resourceName, string fileName)
        {
            var fileData = LoadResourceFile(resourceName, fileName);

            if (fileData == null)
            {
                return null;
            }

            var dataHash = "";

            using (var hash = SHA256.Create())
            {
                var bytes = hash.ComputeHash(Encoding.UTF8.GetBytes(fileData));

                var sb = new StringBuilder();
                foreach (var b in bytes)
                {
                    sb.Append($"{b:X2}");
                }

                dataHash = sb.ToString();
            }

            var cacheName = $"cache/files/fxmigrant/{dataHash}.dll";

            if (!File.Exists(cacheName))
            {
                SynchronizationContext.SetSynchronizationContext(new SynchronizationContext());

                var migratorStream = File.OpenRead(GetResourcePath(GetCurrentResourceName()) + @"/server/bin/Release/netstandard2.0/publish/FluentMigrator.dll");
                var migratorStreamTwo = File.OpenRead(GetResourcePath(GetCurrentResourceName()) + @"/server/bin/Release/netstandard2.0/publish/FluentMigrator.Abstractions.dll");

                var buildTask = Task.Factory.StartNew(() => 
                {
                    var parseOptions = new CSharpParseOptions();
                    var syntaxTree = CSharpSyntaxTree.ParseText(fileData, options: parseOptions);

                    var compileOptions = new CSharpCompilationOptions(OutputKind.DynamicallyLinkedLibrary, optimizationLevel: OptimizationLevel.Release);
                    var compilation = CSharpCompilation.Create("AutoGenerated_FxMigrant_" + dataHash, options: compileOptions)
                        .AddReferences(
                            MetadataReference.CreateFromFile(Path.Combine(Path.GetDirectoryName(typeof(object).GetTypeInfo().Assembly.Location), "mscorlib.dll")),
                            MetadataReference.CreateFromFile(Path.Combine(Path.GetDirectoryName(typeof(object).GetTypeInfo().Assembly.Location), "Facades", "netstandard.dll")),
                            MetadataReference.CreateFromStream(migratorStream),
                            MetadataReference.CreateFromStream(migratorStreamTwo)
                        )

                        .AddSyntaxTrees(syntaxTree);

                    using (var peStream = new MemoryStream())
                    {
                        var emitResult = compilation.Emit(peStream);

                        migratorStream.Dispose();
                        migratorStreamTwo.Dispose();

                        if (!emitResult.Success)
                        {
                            Debug.WriteLine($"^1Error compiling @{resourceName}/{fileName}.");
                            Debug.WriteLine(string.Join("\n", emitResult.Diagnostics.Select(diag => diag.ToString())));
                            Debug.WriteLine("^7");

                            return;
                        }

                        Directory.CreateDirectory("cache/files/fxmigrant/");
                        File.WriteAllBytes(cacheName, peStream.ToArray());
                    }
                }, CancellationToken.None, TaskCreationOptions.None, TaskScheduler.FromCurrentSynchronizationContext());

                await buildTask;
            }

            if (!File.Exists(cacheName))
            {
                return null;
            }

            return Assembly.Load(File.ReadAllBytes(cacheName));
        }

        private class MySqlConnectorDbFactory : MySqlDbFactory
        {
            public MySqlConnectorDbFactory(IServiceProvider serviceProvider)
                : base(serviceProvider)
            { }

            protected override DbProviderFactory CreateFactory()
                => MySqlClientFactory.Instance;
        }

#pragma warning disable 0618

        private class FxVersionTable : DefaultVersionTableMetaData
        {
            public override string TableName => $"fxmigrant_versioninfo";
        }
    }
}