# ============================================================
# TECH TOOLKIT - UI
# ============================================================


# ============================================================
# AJUSTAR TAMANO DE CONSOLA
# ============================================================

function Set-TTConsoleSize {

    param(
        [string[]]$Lines,
        [int]$HorizontalMargin = 8,
        [int]$VerticalMargin = 6,
        [int]$MinWidth = 50,
        [int]$MinHeight = 18
    )

    try {

        # ----------------------------------------------------
        # CALCULAR LINEA MAS LARGA
        # ----------------------------------------------------

        $longestLine = 0

        foreach ($line in $Lines) {

            if (
                $null -ne $line -and
                $line.Length -gt $longestLine
            ) {
                $longestLine = $line.Length
            }
        }


        # ----------------------------------------------------
        # CALCULAR ANCHO
        # ----------------------------------------------------

        $width = $longestLine + $HorizontalMargin

        if ($width -lt $MinWidth) {
            $width = $MinWidth
        }

        $maxWidth = $Host.UI.RawUI.MaxPhysicalWindowSize.Width

        if ($width -gt $maxWidth) {
            $width = $maxWidth
        }


        # ----------------------------------------------------
        # CALCULAR ALTO
        # ----------------------------------------------------

        $height = $Lines.Count + $VerticalMargin

        if ($height -lt $MinHeight) {
            $height = $MinHeight
        }

        $maxHeight = $Host.UI.RawUI.MaxPhysicalWindowSize.Height

        if ($height -gt $maxHeight) {
            $height = $maxHeight
        }


        # ----------------------------------------------------
        # OBTENER TAMANOS ACTUALES
        # ----------------------------------------------------

        $currentWindow = $Host.UI.RawUI.WindowSize
        $currentBuffer = $Host.UI.RawUI.BufferSize


        # ----------------------------------------------------
        # SI HAY QUE AGRANDAR, PRIMERO AGRANDAR BUFFER
        # ----------------------------------------------------

        if ($width -gt $currentBuffer.Width) {

            $currentBuffer.Width = $width
            $Host.UI.RawUI.BufferSize = $currentBuffer
        }

        if ($height -gt $currentBuffer.Height) {

            $currentBuffer.Height = $height
            $Host.UI.RawUI.BufferSize = $currentBuffer
        }


        # ----------------------------------------------------
        # AJUSTAR VENTANA
        # ----------------------------------------------------

        $newWindow = $Host.UI.RawUI.WindowSize

        $newWindow.Width = $width
        $newWindow.Height = $height

        $Host.UI.RawUI.WindowSize = $newWindow


        # ----------------------------------------------------
        # REDUCIR BUFFER DESPUES DE REDUCIR VENTANA
        # ----------------------------------------------------

        $newBuffer = $Host.UI.RawUI.BufferSize

        $newBuffer.Width = $width

        if ($newBuffer.Height -lt 300) {
            $newBuffer.Height = 300
        }

        $Host.UI.RawUI.BufferSize = $newBuffer
    }
    catch {

        # Algunos hosts como Windows Terminal pueden
        # ignorar cambios de tamano de ventana.
    }
}


# ============================================================
# HEADER PRINCIPAL
# ============================================================

function Show-MainHeader {

    param(
        [string[]]$MenuLines
    )

    $title = "TECH TOOLKIT v2.0"

    $content = @(
        $title
    )

    if ($MenuLines) {
        $content += $MenuLines
    }

    Set-TTConsoleSize -Lines $content


    # --------------------------------------------------------
    # CALCULAR ANCHO DEL HEADER
    # --------------------------------------------------------

    $longestLine = $title.Length

    foreach ($line in $content) {

        if ($line.Length -gt $longestLine) {
            $longestLine = $line.Length
        }
    }

    $headerWidth = $longestLine + 8

    if ($headerWidth -lt 50) {
        $headerWidth = 50
    }

    $separator = "=" * $headerWidth


    # --------------------------------------------------------
    # CENTRAR TITULO
    # --------------------------------------------------------

    $leftPadding = [math]::Floor(
        ($headerWidth - $title.Length) / 2
    )

    $centeredTitle =
    (" " * $leftPadding) + $title


    # --------------------------------------------------------
    # MOSTRAR HEADER
    # --------------------------------------------------------

    Clear-Host

    Write-Host $separator `
        -ForegroundColor Cyan

    Write-Host $centeredTitle `
        -ForegroundColor White

    Write-Host $separator `
        -ForegroundColor Cyan

    Write-Host ""
}


# ============================================================
# HEADER DE SECCION
# ============================================================

function Show-SectionHeader {

    param(
        [string]$Title,
        [string[]]$MenuLines
    )

    $content = @(
        $Title
    )

    if ($MenuLines) {
        $content += $MenuLines
    }

    Set-TTConsoleSize -Lines $content


    # --------------------------------------------------------
    # CALCULAR ANCHO DEL HEADER
    # --------------------------------------------------------

    $longestLine = $Title.Length

    foreach ($line in $content) {

        if ($line.Length -gt $longestLine) {
            $longestLine = $line.Length
        }
    }

    $headerWidth = $longestLine + 8

    if ($headerWidth -lt 50) {
        $headerWidth = 50
    }

    $separator = "=" * $headerWidth


    # --------------------------------------------------------
    # MOSTRAR HEADER
    # --------------------------------------------------------

    Clear-Host

    Write-Host $separator `
        -ForegroundColor DarkCyan

    Write-Host "  $Title" `
        -ForegroundColor Yellow

    Write-Host $separator `
        -ForegroundColor DarkCyan

    Write-Host ""
}


# ============================================================
# PAUSA
# ============================================================

function Pause-TT {

    Write-Host ""

    [void](Read-Host "Presiona ENTER para continuar")
}


# ============================================================
# OPCION INVALIDA
# ============================================================

function Show-InvalidOption {

    Write-Host ""

    Write-Host "Opcion no valida." `
        -ForegroundColor Red

    Start-Sleep `
        -Milliseconds 700
}


# ============================================================
# LEER OPCION SIN NECESIDAD DE ENTER
# ============================================================

function Read-TTKey {

    param(
        [string]$Prompt = "Selecciona una opcion",
        [string[]]$ValidKeys
    )

    Write-Host ""

    Write-Host "$Prompt`: " `
        -NoNewline `
        -ForegroundColor Yellow


    while ($true) {

        $keyInfo = [Console]::ReadKey($true)

        $key = $keyInfo.KeyChar.ToString()


        # ----------------------------------------------------
        # IGNORAR TECLAS QUE NO PRODUCEN CARACTER
        # ----------------------------------------------------

        if ([string]::IsNullOrWhiteSpace($key)) {
            continue
        }


        # ----------------------------------------------------
        # NORMALIZAR LETRAS A MAYUSCULAS
        # ----------------------------------------------------

        $key = $key.ToUpper()


        # ----------------------------------------------------
        # SI NO SE ESPECIFICARON OPCIONES VALIDAS
        # DEVOLVER CUALQUIER TECLA
        # ----------------------------------------------------

        if (
            -not $ValidKeys -or
            $ValidKeys.Count -eq 0
        ) {

            Write-Host $key `
                -ForegroundColor Cyan

            return $key
        }


        # ----------------------------------------------------
        # NORMALIZAR OPCIONES VALIDAS
        # ----------------------------------------------------

        $normalizedKeys = @(
            $ValidKeys |
            ForEach-Object {
                $_.ToUpper()
            }
        )


        # ----------------------------------------------------
        # OPCION VALIDA
        # ----------------------------------------------------

        if ($normalizedKeys -contains $key) {

            Write-Host $key `
                -ForegroundColor Cyan

            return $key
        }


        # ----------------------------------------------------
        # OPCION INVALIDA
        # ----------------------------------------------------

        try {
            [Console]::Beep(
                500,
                100
            )
        }
        catch {
        }
    }
}