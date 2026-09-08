function Show-HardwareInfo {

  Show-SectionHeader "COMPONENTES PC"

  # --------------------------------------------------------
  # EQUIPO
  # --------------------------------------------------------

  $computer = Get-CimInstance Win32_ComputerSystem
  $board = Get-CimInstance Win32_BaseBoard
  $bios = Get-CimInstance Win32_BIOS
  $cpu = Get-CimInstance Win32_Processor
  $gpu = Get-CimInstance Win32_VideoController
  $ram = Get-CimInstance Win32_PhysicalMemory
  $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue

  Write-Host "EQUIPO" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  Write-Host "Fabricante : $($computer.Manufacturer)"
  Write-Host "Modelo     : $($computer.Model)"
  Write-Host "Nombre PC  : $($computer.Name)"

  Write-Host ""

  # --------------------------------------------------------
  # PROCESADOR
  # --------------------------------------------------------

  Write-Host "PROCESADOR" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  foreach ($item in $cpu) {

    Write-Host "Modelo      : $($item.Name)"
    Write-Host "Nucleos     : $($item.NumberOfCores)"
    Write-Host "Hilos       : $($item.NumberOfLogicalProcessors)"
    Write-Host "Frecuencia  : $($item.MaxClockSpeed) MHz"
  }

  Write-Host ""

  # --------------------------------------------------------
  # PLACA MADRE
  # --------------------------------------------------------

  Write-Host "PLACA MADRE" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  Write-Host "Fabricante : $($board.Manufacturer)"
  Write-Host "Modelo     : $($board.Product)"
  Write-Host "Version    : $($board.Version)"

  Write-Host ""

  # --------------------------------------------------------
  # BIOS
  # --------------------------------------------------------

  Write-Host "BIOS" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  Write-Host "Fabricante : $($bios.Manufacturer)"
  Write-Host "Version    : $($bios.SMBIOSBIOSVersion)"

  Write-Host ""

  # --------------------------------------------------------
  # RAM
  # --------------------------------------------------------

  Write-Host "MEMORIA RAM" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  $totalRam = 0
  $slot = 1

  foreach ($module in $ram) {

    $capacityGB = [math]::Round(
      $module.Capacity / 1GB,
      2
    )

    $totalRam += $module.Capacity

    Write-Host "Modulo $slot"
    Write-Host "  Capacidad : $capacityGB GB"
    Write-Host "  Marca     : $($module.Manufacturer)"
    Write-Host "  Modelo    : $($module.PartNumber)"
    Write-Host "  Velocidad : $($module.Speed) MHz"
    Write-Host ""

    $slot++
  }

  $totalRamGB = [math]::Round(
    $totalRam / 1GB,
    2
  )

  Write-Host "RAM TOTAL  : $totalRamGB GB" -ForegroundColor Green

  Write-Host ""

  # --------------------------------------------------------
  # GPU
  # --------------------------------------------------------

  Write-Host "TARJETA GRAFICA" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  $gpuList = Get-CimInstance Win32_VideoController

  foreach ($item in $gpuList) {

    Write-Host "GPU        : $($item.Name)"
    Write-Host "Driver     : $($item.DriverVersion)"

    $vramGB = $null

    # ----------------------------------------------------
    # INTENTAR OBTENER VRAM REAL DESDE EL REGISTRO
    # ----------------------------------------------------

    try {

      $videoKeys = Get-ChildItem `
        "HKLM:\SYSTEM\CurrentControlSet\Control\Video" `
        -ErrorAction Stop

      foreach ($videoKey in $videoKeys) {

        $subKeys = Get-ChildItem `
          $videoKey.PSPath `
          -ErrorAction SilentlyContinue

        foreach ($subKey in $subKeys) {

          try {

            $properties = Get-ItemProperty `
              $subKey.PSPath `
              -ErrorAction Stop

            if (
              $properties.DriverDesc -and
              $properties.DriverDesc -eq $item.Name -and
              $properties."HardwareInformation.qwMemorySize"
            ) {

              $vramBytes =
              $properties."HardwareInformation.qwMemorySize"

              $vramGB = [math]::Round(
                $vramBytes / 1GB,
                2
              )

              break
            }

          }
          catch {
            # Ignorar entradas sin informacion
          }
        }

        if ($null -ne $vramGB) {
          break
        }
      }

    }
    catch {
      # Si falla el registro usamos metodo alternativo
    }


    # ----------------------------------------------------
    # RESPALDO CON WMI
    # ----------------------------------------------------

    if ($null -eq $vramGB -and $item.AdapterRAM) {

      $vramGB = [math]::Round(
        $item.AdapterRAM / 1GB,
        2
      )
    }


    # ----------------------------------------------------
    # MOSTRAR RESULTADO
    # ----------------------------------------------------

    if ($null -ne $vramGB) {

      Write-Host "VRAM       : $vramGB GB"
    }
    else {

      Write-Host "VRAM       : No determinada" `
        -ForegroundColor Yellow
    }

    Write-Host ""
  }

  # --------------------------------------------------------
  # ALMACENAMIENTO
  # --------------------------------------------------------

  Write-Host "ALMACENAMIENTO" -ForegroundColor Cyan
  Write-Host "------------------------------------------------------------"

  if ($disks) {

    foreach ($disk in $disks) {

      $sizeGB = [math]::Round(
        $disk.Size / 1GB,
        2
      )

      Write-Host "Disco      : $($disk.FriendlyName)"
      Write-Host "Tipo       : $($disk.MediaType)"
      Write-Host "Capacidad  : $sizeGB GB"
      Write-Host "Estado     : $($disk.HealthStatus)"
      Write-Host ""
    }
  }
  else {

    Write-Host "No se pudo obtener informacion de los discos." `
      -ForegroundColor Yellow
  }

  Pause-TT
}