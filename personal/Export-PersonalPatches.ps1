# Export the two independent personal source changes; never reset, commit or push.
[CmdletBinding()]
param([string]$BaseRef = '')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $BaseRef) { $BaseRef = (Get-Content (Join-Path $PSScriptRoot 'UPSTREAM_BASE.txt') -Raw).Trim() }
$gitArgs = @('-c', "safe.directory=$repo", '-C', $repo)
$baseCommit = & git @gitArgs rev-parse --verify "$BaseRef^{commit}"
if ($LASTEXITCODE -ne 0) { throw 'Cannot resolve upstream baseline.' }
$patchDir = Join-Path $PSScriptRoot 'patches'
New-Item -ItemType Directory -Path $patchDir -Force | Out-Null
$viewer = 'source/ImageGlass.Lib/UI/Viewer/ViewerControl.cs'
$extension = 'source/ImageGlass.Lib/UI/Viewer/ViewerControl_FileDrag.cs'
$core = 'source/ImageGlass.Lib/Core.cs'
$viewerPatch = @(& git @gitArgs diff --binary --full-index $baseCommit -- $viewer)
if ($LASTEXITCODE -ne 0) { throw 'Cannot export viewer hooks.' }
& git @gitArgs cat-file -e "${baseCommit}:$extension" 2>$null
if ($LASTEXITCODE -eq 0) {
    $extensionPatch = @(& git @gitArgs diff --binary --full-index $baseCommit -- $extension)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot export viewer extension.' }
}
else {
    Push-Location $repo
    try {
        $extensionPatch = @(& git -c "safe.directory=$repo" diff --no-index --binary --full-index -- /dev/null $extension)
        if ($LASTEXITCODE -gt 1) { throw 'Cannot export new viewer extension.' }
    }
    finally { Pop-Location }
}
$corePatch = @(& git @gitArgs diff --binary --full-index $baseCommit -- $core)
if ($LASTEXITCODE -ne 0) { throw 'Cannot export personal Pro change.' }
[IO.File]::WriteAllText((Join-Path $patchDir '0001-viewer-file-drag.patch'), (($viewerPatch + $extensionPatch) -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $patchDir '0002-personal-pro.patch'), ($corePatch -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "Baseline: $baseCommit"
Get-ChildItem -LiteralPath $patchDir -File | Select-Object Name, Length
