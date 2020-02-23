Remove-Item -Recurse dist

mkdir dist\fxmigrant

Push-Location server
dotnet publish -c Release
Pop-Location

Copy-Item -Recurse -Force __resource.lua dist\fxmigrant
Copy-Item -Recurse -Force helper.lua dist\fxmigrant

mkdir dist\fxmigrant\server\bin\Release\netstandard2.0\publish\
Copy-Item -Recurse -Force server\bin\Release\netstandard2.0\publish dist\fxmigrant\server\bin\Release\netstandard2.0\

Compress-Archive -Path dist\* -CompressionLevel Optimal -DestinationPath dist\fxmigrant