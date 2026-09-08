function Show-MaintenanceMenu {

    while ($true) {

        Show-SectionHeader "MANTENIMIENTO"

        Write-Host "[1] Limpiar temporales"
        Write-Host "[2] Abrir Sensor de almacenamiento"
        Write-Host "[3] SFC + DISM"
        Write-Host "[0] Volver"

        $option = Read-TTKey `
            -Prompt "Selecciona" `
            -ValidKeys @(
            "0",
            "1",
            "2",
            "3"
        )

        switch ($option) {

            "1" {

                $paths = @(
                    $env:TEMP,
                    "$env:LOCALAPPDATA\Temp",
                    "C:\Windows\Temp"
                )

                foreach ($path in $paths) {

                    if (Test-Path $path) {

                        Remove-Item "$path\*" `
                            -Recurse `
                            -Force `
                            -ErrorAction SilentlyContinue
                    }
                }

                Write-Host ""
                Write-Host "[OK] Temporales limpiados." `
                    -ForegroundColor Green

                Pause-TT
            }


            "2" {

                Start-Process "ms-settings:storagesense"
            }


            "3" {

                if (Require-TTAdmin) {

                    Show-SectionHeader "REPARACION DE WINDOWS"

                    Write-Host "Ejecutando DISM..." `
                        -ForegroundColor Cyan

                    Write-Host ""

                    DISM.exe /Online /Cleanup-Image /RestoreHealth

                    Write-Host ""
                    Write-Host "Ejecutando SFC..." `
                        -ForegroundColor Cyan

                    Write-Host ""

                    sfc.exe /scannow

                    Write-Host ""
                    Write-Host "[OK] Reparacion finalizada." `
                        -ForegroundColor Green

                    Pause-TT
                }
            }


            "0" {

                return
            }
        }
    }
}