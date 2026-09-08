#requires -Version 5.1

# ============================================================
# AUTOELEVACION COMO ADMINISTRADOR
# ============================================================

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()

$principal = New-Object `
    Security.Principal.WindowsPrincipal($identity)

$isAdmin = $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {

    # --------------------------------------------------------
    # INTENTAR USAR WINDOWS TERMINAL
    # --------------------------------------------------------

    $terminal = Get-Command wt.exe `
        -ErrorAction SilentlyContinue

    if ($terminal) {

        Start-Process wt.exe `
            -Verb RunAs `
            -ArgumentList @(
            "powershell.exe",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            "`"$PSCommandPath`""
        )
    }
    else {

        # ----------------------------------------------------
        # RESPALDO: POWERSHELL CLASICO
        # ----------------------------------------------------

        Start-Process powershell.exe `
            -Verb RunAs `
            -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            "`"$PSCommandPath`""
        )
    }

    exit
}


# ============================================================
# INICIAR PROGRAMA
# ============================================================

$ErrorActionPreference = "Continue"

$script:Root = $PSScriptRoot
$script:LogDir = Join-Path $script:Root "Logs"
$script:LogFile = Join-Path $script:LogDir "technician.log"


# ============================================================
# ARCHIVOS REQUERIDOS
# ============================================================

$required = @(

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
    "Modules\Hardware.ps1"

)


# ============================================================
# CARGAR ARCHIVOS
# ============================================================

foreach ($rel in $required) {

    $path = Join-Path $script:Root $rel

    if (-not (Test-Path $path)) {

        Write-Host ""
        Write-Host "Falta archivo requerido: $rel" `
            -ForegroundColor Red

        exit 1
    }

    . $path
}


# ============================================================
# INICIO
# ============================================================

Write-Log "TechToolkit iniciado"


# ============================================================
# MENU PRINCIPAL
# ============================================================

while ($true) {

    $menuLines = @(
        "[1] Idioma y region",
        "[2] Windows",
        "[3] Programas",
        "[4] Red",
        "[5] Almacenamiento",
        "[6] Diagnostico",
        "[7] Impresoras",
        "[8] Mantenimiento",
        "[9] Componentes PC",
        "[0] Salir"
    )

    Show-MainHeader -MenuLines $menuLines

    foreach ($line in $menuLines) {
        Write-Host $line
    }


    # --------------------------------------------------------
    # LEER OPCION SIN ENTER
    # --------------------------------------------------------

    $option = Read-TTKey `
        -Prompt "Selecciona" `
        -ValidKeys @(
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9"
    )


    # --------------------------------------------------------
    # EJECUTAR OPCION
    # --------------------------------------------------------

    switch ($option) {

        "1" {
            Show-LanguageMenu
        }

        "2" {
            Show-WindowsMenu
        }

        "3" {
            Show-ProgramsMenu
        }

        "4" {
            Show-NetworkMenu
        }

        "5" {
            Show-StorageMenu
        }

        "6" {
            Show-DiagnosticsMenu
        }

        "7" {
            Show-PrintersMenu
        }

        "8" {
            Show-MaintenanceMenu
        }

        "9" {
            Show-HardwareInfo
        }

        "0" {
            break
        }
    }


    # --------------------------------------------------------
    # SALIR DEL TOOLKIT
    # --------------------------------------------------------

    if ($option -eq "0") {
        break
    }
}