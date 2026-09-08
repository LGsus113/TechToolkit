function Show-StorageMenu {

    while ($true) {

        Show-SectionHeader "ALMACENAMIENTO"

        Write-Host "[1] Discos fisicos"
        Write-Host "[2] Volumenes"
        Write-Host "[3] Administracion de discos"
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

                Get-PhysicalDisk |
                Format-Table `
                    FriendlyName,
                MediaType,
                HealthStatus,
                OperationalStatus,
                Size `
                    -AutoSize

                Pause-TT
            }

            "2" {

                Get-Volume |
                Format-Table `
                    DriveLetter,
                FileSystemLabel,
                FileSystem,
                HealthStatus,
                SizeRemaining,
                Size `
                    -AutoSize

                Pause-TT
            }

            "3" {

                Start-Process diskmgmt.msc
            }

            "0" {

                return
            }
        }
    }
}