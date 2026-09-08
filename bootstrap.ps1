# ============================================================
# TECH TOOLKIT - BOOTSTRAP
# ============================================================
#
# Uso remoto:
#
# irm https://raw.githubusercontent.com/LGsus113/TechToolkit/main/bootstrap.ps1 | iex
#
# ============================================================

$ErrorActionPreference = "Stop"


# ============================================================
# CONFIGURACION
# ============================================================

$BaseUrl = "https://raw.githubusercontent.com/LGsus113/TechToolkit/main"

$TempRoot = Join-Path $env:TEMP "TechToolkit"

$CoreDir = Join-Path $TempRoot "Core"
$ModDir = Join-Path $TempRoot "Modules"
$CfgDir = Join-Path $TempRoot "Config"


# ============================================================
# ENCABEZADO
# ============================================================

Clear-Host

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "              TECH TOOLKIT" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""


# ============================================================
# LIMPIAR VERSION TEMPORAL ANTERIOR
# ============================================================

if (Test-Path $TempRoot) {

    Write-Host "Limpiando archivos temporales anteriores..." `
        -ForegroundColor DarkGray

    try {

        Remove-Item `
            -LiteralPath $TempRoot `
            -Recurse `
            -Force `
            -ErrorAction Stop

    }
    catch {

        Write-Host ""
        Write-Host "No se pudo limpiar la carpeta temporal anterior." `
            -ForegroundColor Yellow

        Write-Host "Se intentara continuar." `
            -ForegroundColor Yellow

        Write-Host ""
    }
}


# ============================================================
# CREAR ESTRUCTURA
# ============================================================

New-Item `
    -ItemType Directory `
    -Force `
    -Path $TempRoot |
Out-Null

New-Item `
    -ItemType Directory `
    -Force `
    -Path $CoreDir |
Out-Null

New-Item `
    -ItemType Directory `
    -Force `
    -Path $ModDir |
Out-Null

New-Item `
    -ItemType Directory `
    -Force `
    -Path $CfgDir |
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

Write-Host "Descargando TechToolkit..." `
    -ForegroundColor Yellow

Write-Host ""

try {

    foreach ($file in $files) {

        $relativeUrl = $file -replace '\\', '/'

        $url = "$BaseUrl/$relativeUrl"

        $dest = Join-Path $TempRoot $file

        $parent = Split-Path $dest -Parent


        # ----------------------------------------------------
        # CREAR CARPETA SI NO EXISTE
        # ----------------------------------------------------

        if (-not (Test-Path $parent)) {

            New-Item `
                -ItemType Directory `
                -Force `
                -Path $parent |
            Out-Null
        }


        # ----------------------------------------------------
        # MOSTRAR ARCHIVO
        # ----------------------------------------------------

        Write-Host " -> $file" `
            -ForegroundColor DarkGray


        # ----------------------------------------------------
        # DESCARGAR
        # ----------------------------------------------------

        Invoke-WebRequest `
            -UseBasicParsing `
            -Uri $url `
            -OutFile $dest `
            -ErrorAction Stop
    }

}
catch {

    Write-Host ""
    Write-Host "ERROR AL DESCARGAR TECHTOOLKIT" `
        -ForegroundColor Red

    Write-Host ""

    Write-Host $_.Exception.Message `
        -ForegroundColor Red

    Write-Host ""

    Write-Host "Presiona ENTER para cerrar..." `
        -ForegroundColor Yellow

    [void](Read-Host)

    exit 1
}


# ============================================================
# DESCARGA COMPLETADA
# ============================================================

Write-Host ""

Write-Host "Descarga completada." `
    -ForegroundColor Green

Write-Host ""

Write-Host "Solicitando permisos de administrador..." `
    -ForegroundColor Cyan

Write-Host ""


# ============================================================
# RUTA PRINCIPAL
# ============================================================

$ToolkitPath = Join-Path $TempRoot "TechToolkit.ps1"


# ============================================================
# EJECUTAR COMO ADMINISTRADOR
# ============================================================

try {

    $process = Start-Process `
        -FilePath "powershell.exe" `
        -Verb RunAs `
        -Wait `
        -PassThru `
        -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "`"$ToolkitPath`""
    )

}
catch {

    Write-Host ""
    Write-Host "No se pudo iniciar TechToolkit." `
        -ForegroundColor Red

    Write-Host ""

    Write-Host $_.Exception.Message `
        -ForegroundColor Red

    Write-Host ""

}


# ============================================================
# LIMPIEZA
# ============================================================

Write-Host ""
Write-Host "Limpiando archivos temporales..." `
    -ForegroundColor DarkGray

Start-Sleep -Milliseconds 500

try {

    Remove-Item `
        -LiteralPath $TempRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop

    Write-Host "Archivos temporales eliminados." `
        -ForegroundColor Green

}
catch {

    Write-Host "No se pudieron eliminar todos los archivos temporales." `
        -ForegroundColor Yellow
}


# ============================================================
# FIN
# ============================================================

Write-Host ""
Write-Host "TechToolkit finalizado." `
    -ForegroundColor Cyan