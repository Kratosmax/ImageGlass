# Build a self-contained personal portable package. Does not push or publish.
#Requires -Version 7.0
[CmdletBinding()]
param([ValidatePattern('^[a-zA-Z0-9.-]+$')][string]$Revision = 'drag.1')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $repo 'source'
$version = ([xml](Get-Content (Join-Path $source 'Directory.Build.props') -Raw)).Project.PropertyGroup.IgVersion | Where-Object { $_ } | Select-Object -First 1
$output = Join-Path $source '__artifacts/personal/release'
$name = "ImageGlass_${version}_personal-${Revision}_win-x64"
$publish = Join-Path $output $name
$zip = Join-Path $output "$name.zip"
if ((Test-Path $publish) -or (Test-Path $zip)) { throw 'Output already exists. Use a new revision; never overwrite a published package.' }
New-Item -ItemType Directory -Path $output -Force | Out-Null
$log = Join-Path $output "build-$Revision.log"
$project = Join-Path $source 'ImageGlass.Win32/ImageGlass.Win32.csproj'
& dotnet publish $project -c Release -r win-x64 -p:Platform=x64 -p:PublishAot=false -p:SelfContained=true -p:PublishTrimmed=false -p:PublishSingleFile=false -p:PublishReadyToRun=false -p:MSBuildEnableWorkloadResolver=false --source https://api.nuget.org/v3/index.json -o $publish *> $log
if ($LASTEXITCODE -ne 0) { Get-Content $log -Tail 40; throw "Build failed. See $log" }
Copy-Item -Path (Join-Path $source '__assets/__app/*') -Destination $publish -Recurse -Force
Copy-Item -LiteralPath (Join-Path $repo 'LICENSE') -Destination $publish
[IO.File]::WriteAllBytes((Join-Path $publish '.igportable'), @())
# Keep the personal source changes from being replaced by an upstream automatic update.
[IO.File]::WriteAllText((Join-Path $publish 'igconfig.json'), '{"AutoUpdate":"0","Language":"Chinese Simplified.iglang.json"}', [Text.UTF8Encoding]::new($false))
$info = @"
ImageGlass $version - personal $Revision (Windows x64)

解压到可写目录，运行 ImageGlass.exe。已自带运行环境，无需安装 .NET。
完整显示图片时左键拖出原文件；超出窗口时左键保留平移。拖放只允许复制。
保留自用 Pro 功能开关。名称、图标与许可证保留原样，本包不是上游官方发行。
配置保存在本目录。默认关闭上游自动更新；请从自己的 fork 下载个人版更新。
源码、需求及维护说明：https://github.com/Kratosmax/ImageGlass/tree/personal/viewer-file-drag
本包未做代码签名，构建为非 NativeAOT；微信、真实 Sony RAW 速度和多 DPI 尚未实测。
"@
[IO.File]::WriteAllText((Join-Path $publish '自用版说明.txt'), $info, [Text.UTF8Encoding]::new($false))
[IO.Compression.ZipFile]::CreateFromDirectory($publish, $zip, [IO.Compression.CompressionLevel]::Optimal, $true)
$sha = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $output 'SHA256SUMS.txt'), "$sha  $name.zip`n", [Text.UTF8Encoding]::new($false))
$result = [ordered]@{Version=$version;Revision=$Revision;Folder=$publish;Zip=$zip;Bytes=(Get-Item $zip).Length;SHA256=$sha;Log=$log;SelfContained=$true}
$result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'latest-package.json') -Encoding utf8NoBOM
$result | ConvertTo-Json
