function Show-NetworkMenu {

    while ($true) {

        Show-SectionHeader "RED"

        Write-Host "[1] ipconfig /all"
        Write-Host "[2] Renovar IP"
        Write-Host "[3] Vaciar DNS"
        Write-Host "[4] Reset Winsock"
        Write-Host "[5] Reset TCP/IP"
        Write-Host "[6] Prueba de Internet"
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
            "6"
        )


        switch ($option) {

            "1" {

                ipconfig /all

                Pause-TT
            }


            "2" {

                Write-Host ""
                Write-Host "Liberando direccion IP..." `
                    -ForegroundColor Cyan

                ipconfig /release

                Write-Host ""
                Write-Host "Renovando direccion IP..." `
                    -ForegroundColor Cyan

                ipconfig /renew

                Pause-TT
            }


            "3" {

                Write-Host ""
                Write-Host "Vaciando cache DNS..." `
                    -ForegroundColor Cyan

                ipconfig /flushdns

                Pause-TT
            }


            "4" {

                if (Require-TTAdmin) {

                    Write-Host ""
                    Write-Host "Restableciendo Winsock..." `
                        -ForegroundColor Cyan

                    netsh winsock reset

                    Write-Host ""
                    Write-Host "Puede ser necesario reiniciar Windows." `
                        -ForegroundColor Yellow

                    Pause-TT
                }
            }


            "5" {

                if (Require-TTAdmin) {

                    Write-Host ""
                    Write-Host "Restableciendo TCP/IP..." `
                        -ForegroundColor Cyan

                    netsh int ip reset

                    Write-Host ""
                    Write-Host "Puede ser necesario reiniciar Windows." `
                        -ForegroundColor Yellow

                    Pause-TT
                }
            }


            "6" {

                Show-SectionHeader "PRUEBA DE INTERNET"

                Write-Host "Probando conectividad..." `
                    -ForegroundColor Cyan

                Write-Host ""

                $internetOK = Test-Connection `
                    1.1.1.1 `
                    -Count 2 `
                    -Quiet


                if ($internetOK) {

                    Write-Host "[OK] Conexion con Internet" `
                        -ForegroundColor Green
                }
                else {

                    Write-Host "[ERROR] No hay respuesta de 1.1.1.1" `
                        -ForegroundColor Red
                }


                Write-Host ""
                Write-Host "Probando resolucion DNS..." `
                    -ForegroundColor Cyan

                Write-Host ""


                try {

                    Resolve-DnsName example.com `
                        -ErrorAction Stop |
                    Select-Object -First 2

                    Write-Host ""
                    Write-Host "[OK] DNS funcionando." `
                        -ForegroundColor Green
                }
                catch {

                    Write-Host ""
                    Write-Host "[ERROR] Fallo DNS." `
                        -ForegroundColor Red
                }


                Pause-TT
            }


            "0" {

                return
            }
        }
    }
}