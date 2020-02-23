# FxMigrant
_automated database migrations for CitizenFX servers_

## Installation
1. Download the latest release from GitHub releases.
2. Extract it someplace in your resources directory.
3. Currently, only MySQL is supported. Use a valid MySQLConnector connection string as `mysql_connection_string` convar. Typically, `mysql-async` already uses this kind of string.
4. Run a resource that uses FxMigrant.

Currently (2019-05-25), it's unlikely for Linux servers to work with this as-is, this might need either a new artifact build or the usual copying of CitizenFX.Core.Server.dll.

## Building
1. Clone the repository.
2. Make sure you have .NET Core SDK installed.
3. Run build.ps1.

## Using
Reference [FluentMigrator](https://fluentmigrator.github.io/) migration .cs files in your \_\_resource.lua:

```lua
migration_files {
    'migrations/0001_create_users.cs',
    'migrations/0002_add_license.cs
}

dependency 'fxmigrant'

server_script '@fxmigrant/helper.lua'
```

Also, instead of `MySQL.ready`, use `Migrant.ready`.

Example files to show the point:

### 0001_create_users.cs
```cs
using FluentMigrator;

[Migration(1)]
public class CreateUsers : Migration
{
    public override void Up()
    {
        Create.Table("users")
            .WithColumn("identifier").AsString().NotNullable().PrimaryKey()
            .WithColumn("money").AsInt64().Nullable()
            .WithColumn("bank").AsInt64().Nullable()
            .WithColumn("permission_level").AsInt32().Nullable()
            .WithColumn("group").AsString().Nullable();
    }

    public override void Down()
    {
        Delete.Table("users");
    }
}
```

### 0002_add_license.cs
```cs
using FluentMigrator;

[Migration(2)]
public class AddLicense : Migration
{
    public override void Up()
    {
        Create.Column("license")
            .OnTable("users")
            .AsString()
            .Nullable()
            .WithDefaultValue("");
    }

    public override void Down()
    {
        Delete.Column("license").FromTable("users");
    }
}
```