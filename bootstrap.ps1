# TechToolkit Bootstrap
#
# Uso remoto:
# irm https://raw.githubusercontent.com/LGsus113/TechToolkit/main/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"

# ============================================================
# URL BASE DE GITHUB RAW
# ============================================================

$BaseUrl = "https://raw.githubusercontent.com/LGsus113/TechToolkit/main"


# ============================================================
# CARPETA TEMPORAL
# ============================================================

$TempRoot = Join-Path $env:TEMP "TechToolkit"

$CoreDir = Join-Path $TempRoot "Core"
$ModDir = Join-Path $TempRoot "Modules"
$CfgDir = Join-Path $TempRoot "Config"


# ============================================================
# CREAR ESTRUCTURA
# ============================================================

New-Item `
    -ItemType Directory `
    -Force `
    -Path $TempRoot, $CoreDir, $ModDir, $CfgDir |
Out-Null


# ============================================================
# ARCHIVOS DEL TOOLKIT
# ============================================================

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
    "Modules\Hardware.ps1",

    "Config\settings.json"
)


# ============================================================
# DESCARGAR ARCHIVOS
# ============================================================

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "          TECH TOOLKIT - BOOTSTRAP" -ForegroundColor White
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Descargando archivos..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $files) {

    $url = "$BaseUrl/$($file -replace '\\','/')"

    $dest = Join-Path $TempRoot $file

    $parent = Split-Path $dest

    if (-not (Test-Path $parent)) {

        New-Item `
            -ItemType Directory `
            -Force `
            -Path $parent |
        Out-Null
    }

    Write-Host " -> $file" -ForegroundColor DarkGray

    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri $url `
        -OutFile $dest
}


# ============================================================
# EJECUTAR TECHTOOLKIT
# ============================================================

Write-Host ""
Write-Host "Descarga completada." -ForegroundColor Green
Write-Host "Iniciando TechToolkit..." -ForegroundColor Cyan
Write-Host ""

& (Join-Path $TempRoot "TechToolkit.ps1")