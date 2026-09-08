function Show-PrintersMenu {

    while ($true) {

        Show-SectionHeader "IMPRESORAS"

        Write-Host "[1] Listar impresoras"
        Write-Host "[2] Abrir configuracion"
        Write-Host "[3] Reiniciar Spooler"
        Write-Host "[4] Limpiar cola"
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
            "4"
        )


        switch ($option) {

            # ----------------------------------------------------
            # LISTAR IMPRESORAS
            # ----------------------------------------------------

            "1" {

                Show-SectionHeader "IMPRESORAS INSTALADAS"

                try {

                    Get-Printer |
                    Format-Table `
                        Name,
                    DriverName,
                    PortName,
                    PrinterStatus `
                        -AutoSize
                }
                catch {

                    Write-Host ""
                    Write-Host "[ERROR] No se pudieron obtener las impresoras." `
                        -ForegroundColor Red

                    Write-Host $_.Exception.Message `
                        -ForegroundColor DarkGray
                }

                Pause-TT
            }


            # ----------------------------------------------------
            # ABRIR CONFIGURACION
            # ----------------------------------------------------

            "2" {

                Start-Process "ms-settings:printers"
            }


            # ----------------------------------------------------
            # REINICIAR SPOOLER
            # ----------------------------------------------------

            "3" {

                if (Require-TTAdmin) {

                    Show-SectionHeader "REINICIAR SPOOLER"

                    try {

                        Write-Host "Reiniciando servicio de impresion..." `
                            -ForegroundColor Cyan

                        Restart-Service Spooler `
                            -Force `
                            -ErrorAction Stop

                        Write-Host ""
                        Write-Host "[OK] Spooler reiniciado correctamente." `
                            -ForegroundColor Green
                    }
                    catch {

                        Write-Host ""
                        Write-Host "[ERROR] No se pudo reiniciar el Spooler." `
                            -ForegroundColor Red

                        Write-Host $_.Exception.Message `
                            -ForegroundColor DarkGray
                    }

                    Pause-TT
                }
            }


            # ----------------------------------------------------
            # LIMPIAR COLA DE IMPRESION
            # ----------------------------------------------------

            "4" {

                if (Require-TTAdmin) {

                    Show-SectionHeader "LIMPIAR COLA DE IMPRESION"

                    try {

                        Write-Host "Deteniendo Spooler..." `
                            -ForegroundColor Cyan

                        Stop-Service Spooler `
                            -Force `
                            -ErrorAction Stop


                        Write-Host "Eliminando trabajos pendientes..." `
                            -ForegroundColor Cyan

                        $spoolPath =
                        "$env:windir\System32\spool\PRINTERS\*"

                        Remove-Item $spoolPath `
                            -Force `
                            -ErrorAction SilentlyContinue


                        Write-Host "Iniciando Spooler..." `
                            -ForegroundColor Cyan

                        Start-Service Spooler `
                            -ErrorAction Stop


                        Write-Host ""
                        Write-Host "[OK] Cola de impresion limpiada." `
                            -ForegroundColor Green
                    }
                    catch {

                        Write-Host ""
                        Write-Host "[ERROR] No se pudo limpiar la cola." `
                            -ForegroundColor Red

                        Write-Host $_.Exception.Message `
                            -ForegroundColor DarkGray

                        # Intentar dejar el Spooler funcionando
                        Start-Service Spooler `
                            -ErrorAction SilentlyContinue
                    }

                    Pause-TT
                }
            }


            # ----------------------------------------------------
            # VOLVER
            # ----------------------------------------------------

            "0" {

                return
            }
        }
    }
}