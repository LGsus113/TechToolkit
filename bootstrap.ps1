# TechToolkit Bootstrap
# Uso remoto:
#   irm https://TU-DOMINIO/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"

# Cambia esta URL cuando publiques el proyecto.
$BaseUrl = "https://TU-DOMINIO/TechToolkit"

$TempRoot = Join-Path $env:TEMP "TechToolkit"
$CoreDir  = Join-Path $TempRoot "Core"
$ModDir   = Join-Path $TempRoot "Modules"
$CfgDir   = Join-Path $TempRoot "Config"

New-Item -ItemType Directory -Force -Path $TempRoot, $CoreDir, $ModDir, $CfgDir | Out-Null

$files = @(
    "TechToolkit.ps1",
    "Core\UI.ps1",
    "Core\Common.ps1",
    "Modules\Language.ps1",
    "Modules\Windows.ps1",
    "Modules\Programs.ps1",
    "Modules\Network.ps1",
    "Modules\Storage.ps1",
    "Modules\Diagnostics.ps1",
    "Modules\Printers.ps1",
    "Modules\Maintenance.ps1",
    "Config\settings.json"
)

Write-Host ""
Write-Host "TechToolkit - cargando archivos..." -ForegroundColor Cyan

foreach ($file in $files) {
    $url = "$BaseUrl/$($file -replace '\\','/')"
    $dest = Join-Path $TempRoot $file

    $parent = Split-Path $dest
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    Write-Host "  -> $file" -ForegroundColor DarkGray
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $dest
}

& (Join-Path $TempRoot "TechToolkit.ps1")
