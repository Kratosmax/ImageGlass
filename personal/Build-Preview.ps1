# Local preview only. Does not modify project settings, install tools, commit or publish.
#Requires -Version 7.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $repo 'source'
$output = Join-Path $source '__artifacts/personal'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$version = ([xml](Get-Content (Join-Path $source 'Directory.Build.props') -Raw)).Project.PropertyGroup.IgVersion | Where-Object { $_ } | Select-Object -First 1
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$name = "ImageGlass_${version}_personal-drag_Lite_win-x64_$stamp"
$publish = Join-Path $output $name
$project = Join-Path $source 'ImageGlass.Win32/ImageGlass.Win32.csproj'
$log = Join-Path $output "build-$stamp.log"
& dotnet publish $project -c Release -r win-x64 -p:Platform=x64 -p:PublishAot=false -p:SelfContained=false -p:PublishTrimmed=false -p:PublishSingleFile=false -p:PublishReadyToRun=false -p:MSBuildEnableWorkloadResolver=false --source https://api.nuget.org/v3/index.json -o $publish *> $log
if ($LASTEXITCODE -ne 0) { Get-Content $log -Tail 40; throw "Build failed. See $log" }
Copy-Item -Path (Join-Path $source '__assets/__app/*') -Destination $publish -Recurse -Force
Copy-Item -LiteralPath (Join-Path $repo 'LICENSE') -Destination $publish
[IO.File]::WriteAllBytes((Join-Path $publish '.igportable'), @())
$zip = Join-Path $output "$name.zip"
[IO.Compression.ZipFile]::CreateFromDirectory($publish, $zip, [IO.Compression.CompressionLevel]::Optimal, $true)
$result = [ordered]@{ Version=$version; Kind='Local Lite preview, not official Release'; Folder=$publish; Zip=$zip; Bytes=(Get-Item $zip).Length; SHA256=(Get-FileHash $zip -Algorithm SHA256).Hash; Log=$log; Requires='.NET 10 Desktop Runtime (x64)' }
$result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'latest-preview.json') -Encoding utf8NoBOM
$result | ConvertTo-Json
