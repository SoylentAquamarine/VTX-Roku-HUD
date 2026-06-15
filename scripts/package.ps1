$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
$out = Join-Path $dist 'VTX-Roku-HUD.zip'

if (!(Test-Path $dist)) {
    New-Item -ItemType Directory -Path $dist | Out-Null
}

if (Test-Path $out) {
    Remove-Item $out -Force
}

$items = @(
    'manifest',
    'source',
    'components'
)

$paths = $items | ForEach-Object { Join-Path $root $_ }
Compress-Archive -Path $paths -DestinationPath $out -Force
Write-Host "Created $out"
