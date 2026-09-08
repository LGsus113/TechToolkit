function Show-WindowsMenu {

    while ($true) {

        Show-SectionHeader "WINDOWS"

        Write-Host "[1] Informacion del sistema"
        Write-Host "[2] Windows Update"
        Write-Host "[3] SFC /scannow"
        Write-Host "[4] DISM RestoreHealth"
        Write-Host "[5] Estado de activacion"
        Write-Host "[6] Administrador de dispositivos"
        Write-Host "[0] Volver"

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

                Show-SectionHeader "INFORMACION DEL SISTEMA"

                Get-ComputerInfo |
                Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsName, CsManufacturer, CsModel |
                Format-List

                Pause-TT

            }

            "2" {

                Start-Process "ms-settings:windowsupdate"

            }

            "3" {

                if (Require-TTAdmin) {

                    Show-SectionHeader "SFC"

                    Invoke-TTCommand "sfc.exe" @("/scannow")

                    Pause-TT

                }

            }

            "4" {

                if (Require-TTAdmin) {

                    Show-SectionHeader "DISM"

                    Invoke-TTCommand "DISM.exe" @(
                        "/Online",
                        "/Cleanup-Image",
                        "/RestoreHealth"
                    )

                    Pause-TT

                }

            }

            "5" {

                Show-SectionHeader "ACTIVACION"

                Invoke-TTCommand "cscript.exe" @(
                    "//Nologo",
                    "$env:windir\system32\slmgr.vbs",
                    "/xpr"
                )

                Pause-TT

            }

            "6" {

                Start-Process devmgmt.msc

            }

            "0" {

                return

            }

        }

    }

}