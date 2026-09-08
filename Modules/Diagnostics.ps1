function Show-DiagnosticsMenu {

    while ($true) {

        Show-SectionHeader "DIAGNOSTICO"

        Write-Host "[1] CPU y RAM"
        Write-Host "[2] GPU"
        Write-Host "[3] Bateria"
        Write-Host "[4] Diagnostico de memoria"
        Write-Host "[5] Battery report"
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
            "5"
        )


        switch ($option) {

            "1" {

                Get-CimInstance Win32_Processor |
                Select-Object `
                    Name,
                NumberOfCores,
                NumberOfLogicalProcessors,
                MaxClockSpeed |
                Format-List

                Get-CimInstance Win32_ComputerSystem |
                Select-Object TotalPhysicalMemory |
                Format-List

                Pause-TT
            }


            "2" {

                Get-CimInstance Win32_VideoController |
                Select-Object `
                    Name,
                DriverVersion,
                AdapterRAM |
                Format-List

                Pause-TT
            }


            "3" {

                Get-CimInstance Win32_Battery |
                Format-Table `
                    Name,
                BatteryStatus,
                EstimatedChargeRemaining,
                EstimatedRunTime `
                    -AutoSize

                Pause-TT
            }


            "4" {

                Start-Process mdsched.exe
            }


            "5" {

                $out = Join-Path `
                    $env:USERPROFILE `
                    "Desktop\battery-report.html"

                powercfg /batteryreport /output $out

                Write-Host ""
                Write-Host "Reporte generado en:" `
                    -ForegroundColor Green

                Write-Host $out `
                    -ForegroundColor Cyan

                Pause-TT
            }


            "0" {

                return
            }
        }
    }
}