# ============================================================
# TECHTOOLKIT - PROGRAMS MODULE
# ============================================================


# ============================================================
# MENU DE PROGRAMAS
# ============================================================

function Show-ProgramsMenu {

    while ($true) {

        Show-SectionHeader "PROGRAMAS"

        Write-Host "[1] WinRAR"
        Write-Host "[2] VLC"
        Write-Host "[3] Brave Browser"
        Write-Host "[4] Opera GX"
        Write-Host "[5] Visual C++ Redistributable"
        Write-Host "[6] Steam"
        Write-Host "[7] Epic Games Launcher"
        Write-Host "[8] Discord"
        Write-Host "[9] AnyDesk"

        Write-Host ""
        Write-Host "[A] NVIDIA App" -ForegroundColor Green

        Write-Host ""
        Write-Host "[B] Instalar TODOS" -ForegroundColor Cyan
        Write-Host "[C] Instalar TODOS sin NVIDIA" -ForegroundColor Cyan

        Write-Host ""
        Write-Host "[0] Volver"


        # --------------------------------------------------------
        # SELECCION SIN ENTER
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
            "9",
            "a",
            "A",
            "b",
            "B",
            "c",
            "C"
        )


        switch ($option.ToUpper()) {

            "1" {

                Install-TTWinget `
                    -Id "RARLab.WinRAR" `
                    -Name "WinRAR"
            }


            "2" {

                Install-TTWinget `
                    -Id "VideoLAN.VLC" `
                    -Name "VLC"
            }


            "3" {

                Install-TTWinget `
                    -Id "Brave.Brave" `
                    -Name "Brave Browser"
            }


            "4" {

                Install-TTWinget `
                    -Id "Opera.OperaGX" `
                    -Name "Opera GX"
            }


            "5" {

                Install-TTWinget `
                    -Id "Microsoft.VCRedist.2015+.x64" `
                    -Name "Visual C++ Redistributable"
            }


            "6" {

                Install-TTWinget `
                    -Id "Valve.Steam" `
                    -Name "Steam"
            }


            "7" {

                Install-TTWinget `
                    -Id "EpicGames.EpicGamesLauncher" `
                    -Name "Epic Games Launcher"
            }


            "8" {

                Install-TTWinget `
                    -Id "Discord.Discord" `
                    -Name "Discord"
            }


            "9" {

                Install-TTWinget `
                    -Id "AnyDeskSoftwareGmbH.AnyDesk" `
                    -Name "AnyDesk"
            }


            "A" {

                Install-TTNvidiaApp
            }


            # ----------------------------------------------------
            # INSTALAR TODO
            # ----------------------------------------------------

            "B" {

                Install-TTProgramBundle `
                    -IncludeNvidia $true
            }


            # ----------------------------------------------------
            # INSTALAR TODO SIN NVIDIA
            # ----------------------------------------------------

            "C" {

                Install-TTProgramBundle `
                    -IncludeNvidia $false
            }


            "0" {

                return
            }
        }
    }
}


# ============================================================
# INSTALAR PROGRAMA CON WINGET
# ============================================================

# ============================================================
# INSTALAR PROGRAMA CON WINGET
# ============================================================

function Install-TTWinget {

    param(

        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$NoPause
    )


    Show-SectionHeader "INSTALANDO $Name"


    # --------------------------------------------------------
    # COMPROBAR WINGET
    # --------------------------------------------------------

    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue

    if (-not $winget) {

        Write-Host ""
        Write-Host "[ERROR] winget no esta disponible." `
            -ForegroundColor Red

        Write-Host ""
        Write-Host "Instala o actualiza App Installer desde Microsoft Store." `
            -ForegroundColor Yellow

        if (-not $NoPause) {
            Pause-TT
        }

        return $false
    }


    # --------------------------------------------------------
    # COMPROBAR SI YA ESTA INSTALADO
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Comprobando si $Name ya esta instalado..." `
        -ForegroundColor DarkGray

    & winget.exe list `
        --id $Id `
        --exact `
        --source winget `
        --accept-source-agreements `
        --disable-interactivity `
        *> $null

    $alreadyInstalled = ($LASTEXITCODE -eq 0)


    if ($alreadyInstalled) {

        Write-Host ""
        Write-Host "[OK] $Name ya esta instalado." `
            -ForegroundColor Green

        Write-Host "No es necesario volver a instalarlo." `
            -ForegroundColor DarkGray

        if (-not $NoPause) {
            Pause-TT
        }

        return $true
    }


    # --------------------------------------------------------
    # INSTALAR
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Descargando e instalando $Name..." `
        -ForegroundColor Cyan

    Write-Host ""

    & winget.exe install `
        --id $Id `
        --exact `
        --source winget `
        --accept-package-agreements `
        --accept-source-agreements `
        --disable-interactivity `
        --silent

    $installExitCode = $LASTEXITCODE


    # --------------------------------------------------------
    # VERIFICAR INSTALACION REAL
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Verificando instalacion..." `
        -ForegroundColor DarkGray

    Start-Sleep -Seconds 2

    & winget.exe list `
        --id $Id `
        --exact `
        --source winget `
        --accept-source-agreements `
        --disable-interactivity `
        *> $null

    $verified = ($LASTEXITCODE -eq 0)


    # --------------------------------------------------------
    # RESULTADO
    # --------------------------------------------------------

    if ($verified) {

        Write-Host ""
        Write-Host "[OK] $Name instalado correctamente." `
            -ForegroundColor Green

        Write-Log "Programa instalado y verificado: $Name / $Id"

        $success = $true
    }
    else {

        Write-Host ""
        Write-Host "[ERROR] $Name NO aparece instalado." `
            -ForegroundColor Red

        Write-Host ""
        Write-Host "Codigo devuelto por winget: $installExitCode" `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "Winget termino, pero la instalacion no pudo verificarse." `
            -ForegroundColor Yellow

        Write-Log `
            "ERROR instalando $Name / $Id / Codigo $installExitCode"

        $success = $false
    }


    if (-not $NoPause) {
        Pause-TT
    }

    return $success
}


# ============================================================
# PAQUETE DE PROGRAMAS
# ============================================================

function Install-TTProgramBundle {

    param(

        [bool]$IncludeNvidia = $false
    )


    Show-SectionHeader "INSTALACION AUTOMATICA"


    Write-Host "Se instalaran:" `
        -ForegroundColor Yellow

    Write-Host ""

    Write-Host "  WinRAR"
    Write-Host "  VLC"
    Write-Host "  Brave Browser"
    Write-Host "  Opera GX"
    Write-Host "  Visual C++ Redistributable"
    Write-Host "  Steam"
    Write-Host "  Epic Games Launcher"
    Write-Host "  Discord"
    Write-Host "  AnyDesk"


    if ($IncludeNvidia) {

        Write-Host "  NVIDIA App" `
            -ForegroundColor Green
    }


    Write-Host ""
    Write-Host "Iniciando instalacion..." `
        -ForegroundColor Cyan

    Start-Sleep -Milliseconds 700


    # --------------------------------------------------------
    # LISTA DE PROGRAMAS
    # --------------------------------------------------------

    $programs = @(

        @{
            Name = "WinRAR"
            Id   = "RARLab.WinRAR"
        },

        @{
            Name = "VLC"
            Id   = "VideoLAN.VLC"
        },

        @{
            Name = "Brave Browser"
            Id   = "Brave.Brave"
        },

        @{
            Name = "Opera GX"
            Id   = "Opera.OperaGX"
        },

        @{
            Name = "Visual C++ Redistributable"
            Id   = "Microsoft.VCRedist.2015+.x64"
        },

        @{
            Name = "Steam"
            Id   = "Valve.Steam"
        },

        @{
            Name = "Epic Games Launcher"
            Id   = "EpicGames.EpicGamesLauncher"
        },

        @{
            Name = "Discord"
            Id   = "Discord.Discord"
        },

        @{
            Name = "AnyDesk"
            Id   = "AnyDeskSoftwareGmbH.AnyDesk"
        }
    )


    # --------------------------------------------------------
    # CONTADORES
    # --------------------------------------------------------

    $installed = 0
    $failed = 0


    # --------------------------------------------------------
    # INSTALAR
    # --------------------------------------------------------

    foreach ($program in $programs) {

        $result = Install-TTWinget `
            -Id $program.Id `
            -Name $program.Name `
            -NoPause


        if ($result) {

            $installed++
        }
        else {

            $failed++
        }
    }


    # --------------------------------------------------------
    # NVIDIA
    # --------------------------------------------------------

    if ($IncludeNvidia) {

        $nvidiaResult =
        Install-TTNvidiaApp -NoPause


        if ($nvidiaResult) {

            $installed++
        }
        else {

            $failed++
        }
    }


    # --------------------------------------------------------
    # RESUMEN
    # --------------------------------------------------------

    Show-SectionHeader "INSTALACION FINALIZADA"


    Write-Host "Correctos : $installed" `
        -ForegroundColor Green

    Write-Host "Errores   : $failed" `
        -ForegroundColor $(

        if ($failed -gt 0) {
            "Red"
        }
        else {
            "Green"
        }
    )


    Write-Host ""

    Pause-TT
}


# ============================================================
# NVIDIA APP
# ============================================================

function Install-TTNvidiaApp {

    param(
        [switch]$NoPause
    )


    Show-SectionHeader "NVIDIA APP"


    # --------------------------------------------------------
    # DETECTAR GPU NVIDIA
    # --------------------------------------------------------

    $nvidiaGPU = Get-CimInstance `
        Win32_VideoController `
        -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match "NVIDIA"
    }


    if (-not $nvidiaGPU) {

        Write-Host ""
        Write-Host "[AVISO] No se detecto una GPU NVIDIA." `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "Se omitira NVIDIA App."

        Write-Log "NVIDIA App omitida - GPU NVIDIA no detectada"


        if (-not $NoPause) {
            Pause-TT
        }


        return $true
    }


    Write-Host ""
    Write-Host "GPU NVIDIA detectada:" `
        -ForegroundColor Green


    foreach ($gpu in $nvidiaGPU) {

        Write-Host "  $($gpu.Name)" `
            -ForegroundColor Cyan
    }


    Write-Host ""
    Write-Host "NVIDIA App no esta disponible actualmente" `
        -ForegroundColor Yellow

    Write-Host "como paquete normal de WinGet."

    Write-Host ""
    Write-Host "Por ahora se omite la instalacion automatica." `
        -ForegroundColor Yellow


    Write-Log `
        "GPU NVIDIA detectada pero NVIDIA App no disponible mediante WinGet"


    if (-not $NoPause) {
        Pause-TT
    }


    return $true
}