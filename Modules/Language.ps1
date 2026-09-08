# ============================================================
# TECHTOOLKIT - LANGUAGE MODULE
# ============================================================


function Show-LanguageMenu {

    while ($true) {

        Show-SectionHeader "IDIOMA, REGION Y TECLADO"

        Write-Host "[1] Descargar / configurar Espanol - Mexico"
        Write-Host "[2] Descargar / configurar English - US"
        Write-Host "[3] Configurar solo teclado"
        Write-Host "[4] Ver configuracion completa"
        Write-Host "[0] Volver"

        $option = Read-TTKey -Prompt "Selecciona" -ValidKeys @("0", "1", "2", "3", "4")

        switch ($option) {

            "1" {
                Install-TTLanguage -Language "es-MX"
            }

            "2" {
                Install-TTLanguage -Language "en-US"
            }

            "3" {
                Show-TTKeyboardMenu
            }

            "4" {
                Show-TTLanguageConfiguration
            }

            "0" {
                return
            }

            default {
                Show-InvalidOption
            }
        }
    }
}



# ============================================================
# DESCARGAR / CONFIGURAR IDIOMA
# ============================================================

function Install-TTLanguage {

    param(
        [Parameter(Mandatory)]
        [string]$Language
    )

    if (-not (Require-TTAdmin)) {
        return
    }

    Show-SectionHeader "INSTALAR IDIOMA"


    # --------------------------------------------------------
    # CONFIGURACION ORIGINAL
    # --------------------------------------------------------

    $originalLanguages = Get-WinUserLanguageList
    $originalUILanguage = Get-WinUILanguageOverride
    $originalCulture = Get-Culture
    $originalSystemLocale = Get-WinSystemLocale
    $originalKeyboard = Get-WinDefaultInputMethodOverride


    # --------------------------------------------------------
    # DETECTAR TECLADO ACTUAL
    # --------------------------------------------------------

    $originalInputTip = $null

    if ($originalKeyboard) {

        $originalInputTip = $originalKeyboard.InputMethodTip
    }
    elseif ($originalLanguages.Count -gt 0) {

        $firstOriginalLanguage = $originalLanguages[0]

        if ($firstOriginalLanguage.InputMethodTips.Count -gt 0) {

            $originalInputTip =
            $firstOriginalLanguage.InputMethodTips[0]
        }
    }


    # --------------------------------------------------------
    # MOSTRAR CONFIGURACION ENCONTRADA
    # --------------------------------------------------------

    Write-Host "Configuracion encontrada:" -ForegroundColor Yellow
    Write-Host ""


    if ($originalUILanguage) {

        Write-Host "Idioma de interfaz : $($originalUILanguage.LanguageTag)"
    }
    elseif ($originalLanguages.Count -gt 0) {

        Write-Host "Idioma de interfaz : $($originalLanguages[0].LanguageTag)"
        Write-Host "Tipo interfaz      : Automatico"
    }
    else {

        Write-Host "Idioma de interfaz : No determinado"
    }


    Write-Host "Formato regional   : $($originalCulture.Name)"
    Write-Host "System Locale      : $($originalSystemLocale.Name)"


    if ($originalInputTip) {

        Write-Host "Teclado actual     : $(Get-TTKeyboardName $originalInputTip)"
        Write-Host "Codigo teclado     : $originalInputTip"
    }
    else {

        Write-Host "Teclado actual     : No se pudo determinar"
    }


    Write-Host ""
    Write-Host "Idioma solicitado  : $Language" -ForegroundColor Cyan
    Write-Host ""


    # --------------------------------------------------------
    # COMPROBAR SI YA ESTA INSTALADO
    # --------------------------------------------------------

    $alreadyInstalled = $false


    if (Get-Command Get-InstalledLanguage -ErrorAction SilentlyContinue) {

        try {

            $installed = Get-InstalledLanguage

            foreach ($item in $installed) {

                if ($item.LanguageId -eq $Language) {

                    $alreadyInstalled = $true
                    break
                }
            }
        }
        catch {
        }
    }


    # --------------------------------------------------------
    # DESCARGA
    # --------------------------------------------------------

    if ($alreadyInstalled) {

        Write-Host "[OK] El idioma $Language ya esta instalado." `
            -ForegroundColor Green

    }
    else {

        try {

            if (-not (Get-Command Install-Language -ErrorAction SilentlyContinue)) {

                Write-Host ""
                Write-Host "Install-Language no esta disponible." `
                    -ForegroundColor Red

                Write-Host ""
                Write-Host "Esta version de Windows puede requerir"
                Write-Host "instalar el idioma desde Configuracion."

                Pause-TT
                return
            }


            Write-Host "Descargando paquete de idioma $Language..." `
                -ForegroundColor Cyan

            Write-Host ""


            Install-Language $Language


            Write-Host ""
            Write-Host "[OK] Idioma instalado correctamente." `
                -ForegroundColor Green


            Write-Log "Idioma descargado: $Language"
        }
        catch {

            Write-Host ""
            Write-Host "ERROR descargando el idioma:" `
                -ForegroundColor Red

            Write-Host $_.Exception.Message `
                -ForegroundColor Red


            Write-Log "ERROR descargando $Language - $($_.Exception.Message)"


            Pause-TT
            return
        }
    }


    # --------------------------------------------------------
    # PREGUNTAR SI SE APLICA COMO PRINCIPAL
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Deseas colocar $Language como idioma principal de Windows?"
    Write-Host ""
    Write-Host "[1] Si"
    Write-Host "[0] No - Solo descargar"


    $setPrincipal = Read-TTKey -Prompt "Selecciona" -ValidKeys @("0", "1")


    if ($setPrincipal -ne "1") {

        Write-Host ""
        Write-Host "Idioma instalado pero NO configurado como principal." `
            -ForegroundColor Yellow


        Write-Log "$Language instalado solamente"


        Pause-TT
        return
    }


    # --------------------------------------------------------
    # OBTENER TECLADO DEL NUEVO IDIOMA
    # --------------------------------------------------------

    $newLanguageList = New-WinUserLanguageList $Language

    $newInputTip = $null


    if ($newLanguageList.Count -gt 0) {

        if ($newLanguageList[0].InputMethodTips.Count -gt 0) {

            $newInputTip =
            $newLanguageList[0].InputMethodTips[0]
        }
    }


    # --------------------------------------------------------
    # SELECCION DE TECLADO
    # --------------------------------------------------------

    Show-SectionHeader "DISTRIBUCION DE TECLADO"


    Write-Host "Idioma principal seleccionado:"
    Write-Host "  $Language" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Selecciona el teclado que deseas usar:"
    Write-Host ""


    Write-Host "[1] Mantener teclado NATIVO / actual" `
        -ForegroundColor Cyan


    if ($originalInputTip) {

        Write-Host "    $(Get-TTKeyboardName $originalInputTip)"
        Write-Host "    $originalInputTip"
    }
    else {

        Write-Host "    No se pudo detectar automaticamente."
    }


    Write-Host ""


    Write-Host "[0] Usar teclado del NUEVO idioma" `
        -ForegroundColor Cyan


    if ($newInputTip) {

        Write-Host "    $(Get-TTKeyboardName $newInputTip)"
        Write-Host "    $newInputTip"
    }
    else {

        Write-Host "    No se pudo detectar."
    }


    $keyboardOption = Read-TTKey -Prompt "Selecciona" -ValidKeys @("0", "1")


    if ($keyboardOption -eq "1") {

        $selectedKeyboard = $originalInputTip
    }
    else {

        $selectedKeyboard = $newInputTip
    }


    # --------------------------------------------------------
    # APLICAR CONFIGURACION
    # --------------------------------------------------------

    Set-TTLanguageConfiguration `
        -Language $Language `
        -Keyboard $selectedKeyboard
}



# ============================================================
# APLICAR CONFIGURACION
# ============================================================

function Set-TTLanguageConfiguration {

    param(

        [Parameter(Mandatory)]
        [string]$Language,

        [string]$Keyboard
    )


    Show-SectionHeader "CONFIGURANDO WINDOWS"


    try {

        # ----------------------------------------------------
        # OBTENER LISTA ACTUAL
        # ----------------------------------------------------

        $currentLanguages = Get-WinUserLanguageList


        # ----------------------------------------------------
        # CREAR NUEVA LISTA CON EL IDIOMA PRINCIPAL PRIMERO
        # ----------------------------------------------------

        $newMainLanguageList =
        New-WinUserLanguageList $Language

        if ($Keyboard) {

            $newMainLanguageList[0].InputMethodTips.Clear()
            [void]$newMainLanguageList[0].InputMethodTips.Add($Keyboard)
        }


        $finalLanguageList =
        New-Object System.Collections.Generic.List[object]


        # Agregar idioma principal primero

        $finalLanguageList.Add(
            $newMainLanguageList[0]
        )


        # Agregar los demas idiomas existentes

        foreach ($item in $currentLanguages) {

            if ($item.LanguageTag -ne $Language) {

                $finalLanguageList.Add($item)
            }
        }


        # ----------------------------------------------------
        # APLICAR LISTA
        # ----------------------------------------------------

        Set-WinUserLanguageList `
            $finalLanguageList `
            -Force


        # ----------------------------------------------------
        # IDIOMA VISUAL
        # ----------------------------------------------------

        Set-WinUILanguageOverride `
            -Language $Language


        # ----------------------------------------------------
        # SYSTEM LOCALE
        # ----------------------------------------------------

        Set-WinSystemLocale `
            $Language


        # ----------------------------------------------------
        # CULTURA / FORMATO REGIONAL
        # ----------------------------------------------------

        if ($Language -eq "es-MX") {

            Set-Culture "es-PE"
        }
        else {

            Set-Culture $Language
        }


        # ----------------------------------------------------
        # TECLADO PREDETERMINADO
        # ----------------------------------------------------

        if ($Keyboard) {

            Set-WinDefaultInputMethodOverride `
                -InputTip $Keyboard


            $effectiveKeyboard = Get-WinDefaultInputMethodOverride

            if ($Keyboard -and $effectiveKeyboard.InputMethodTip -ne $Keyboard) {

                throw "Windows no acepto la distribucion '$Keyboard' como predeterminada. Valor actual: $($effectiveKeyboard.InputMethodTip)"
            }
            Set-TTActiveKeyboard `
                -InputTip $Keyboard
        }


        # ----------------------------------------------------
        # RESULTADO
        # ----------------------------------------------------

        Write-Host ""
        Write-Host "[OK] Configuracion aplicada." `
            -ForegroundColor Green


        Write-Host ""

        Write-Host "Idioma Windows : $Language"


        if ($Language -eq "es-MX") {

            Write-Host "Formato regional: es-PE"
        }
        else {

            Write-Host "Formato regional: $Language"
        }


        Write-Host "System Locale  : $Language"


        if ($Keyboard) {

            Write-Host "Teclado        : $(Get-TTKeyboardName $Keyboard)"
            Write-Host "Codigo         : $Keyboard"
        }


        Write-Host ""
        Write-Host "Orden de idiomas:" `
            -ForegroundColor Yellow


        $resultLanguages =
        Get-WinUserLanguageList


        $position = 1


        foreach ($item in $resultLanguages) {

            Write-Host "  [$position] $($item.LanguageTag)"

            $position++
        }


        Write-Host ""
        Write-Host "Puede ser necesario cerrar sesion o reiniciar." `
            -ForegroundColor Yellow


        Write-Log `
            "Configurado idioma $Language / Keyboard $Keyboard"
    }
    catch {

        Write-Host ""

        Write-Host "ERROR configurando Windows:" `
            -ForegroundColor Red


        Write-Host $_.Exception.Message `
            -ForegroundColor Red


        Write-Log `
            "ERROR configurando $Language - $($_.Exception.Message)"
    }


    Pause-TT
}



# ============================================================
# ACTIVAR TECLADO INMEDIATAMENTE
# ============================================================

function Set-TTActiveKeyboard {

    param(
        [Parameter(Mandatory)]
        [string]$InputTip
    )

    $parts = $InputTip -split ":"

    if ($parts.Count -lt 2) {
        throw "Codigo de teclado invalido: $InputTip"
    }

    $layoutID = $parts[1].ToUpper()

    if (-not ("TTKeyboardNative" -as [type])) {

        Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class TTKeyboardNative
{
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr LoadKeyboardLayout(string pwszKLID, uint Flags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr ActivateKeyboardLayout(IntPtr hkl, uint Flags);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@
    }

    $KLF_ACTIVATE = 0x00000001
    $KLF_SETFORPROCESS = 0x00000100
    $WM_INPUTLANGCHANGEREQUEST = 0x0050
    $HWND_BROADCAST = [IntPtr]0xFFFF

    $hkl = [TTKeyboardNative]::LoadKeyboardLayout(
        $layoutID,
        ($KLF_ACTIVATE -bor $KLF_SETFORPROCESS)
    )

    if ($hkl -eq [IntPtr]::Zero) {
        throw "Windows no pudo cargar la distribucion $layoutID"
    }

    [TTKeyboardNative]::ActivateKeyboardLayout(
        $hkl,
        $KLF_SETFORPROCESS
    ) | Out-Null

    [TTKeyboardNative]::PostMessage(
        $HWND_BROADCAST,
        $WM_INPUTLANGCHANGEREQUEST,
        [IntPtr]::Zero,
        $hkl
    ) | Out-Null
}



# ============================================================
# OBTENER TECLADOS DISPONIBLES DINAMICAMENTE
# ============================================================

function Get-TTAvailableKeyboards {

    # Fuente principal: la lista REAL del usuario.
    # Es mas rapida y, para cambiar teclado, es la fuente correcta:
    # contiene exactamente los InputMethodTips disponibles en el perfil.
    $result = @()

    try {
        $userLanguages = Get-WinUserLanguageList
    }
    catch {
        Write-Log "ERROR leyendo idiomas del usuario: $($_.Exception.Message)"
        return @()
    }

    foreach ($language in $userLanguages) {

        if (-not $language.LanguageTag) {
            continue
        }

        foreach ($tip in $language.InputMethodTips) {

            if (-not $tip) {
                continue
            }

            $parts = $tip -split ":"

            if ($parts.Count -lt 2) {
                continue
            }

            $layoutID = $parts[1].ToUpper()

            $result += [PSCustomObject]@{
                LanguageTag = $language.LanguageTag
                InputTip    = $tip
                LayoutID    = $layoutID
                Name        = Get-TTKeyboardName $tip
            }
        }
    }

    return @($result)
}


# ============================================================
# CONFIGURAR SOLO TECLADO
# ============================================================

function Show-TTKeyboardMenu {

    while ($true) {

        Show-SectionHeader "CONFIGURAR TECLADO"


        # ----------------------------------------------------
        # DETECTAR TECLADOS DINAMICAMENTE
        # ----------------------------------------------------

        $detectedKeyboards =
        Get-TTAvailableKeyboards


        if (-not $detectedKeyboards -or
            $detectedKeyboards.Count -eq 0) {

            Write-Host ""
            Write-Host "No se encontraron distribuciones de teclado." `
                -ForegroundColor Red

            Pause-TT
            return
        }


        # ----------------------------------------------------
        # AGRUPAR POR DISTRIBUCION FISICA
        #
        # Por ejemplo:
        #
        # 080A:0000080A
        # 280A:0000080A
        #
        # Ambos usan:
        #
        # 0000080A = Latinoamericano
        # ----------------------------------------------------

        $groups =
        $detectedKeyboards |
        Group-Object LayoutID


        $keyboardOptions = @()

        $index = 1


        Write-Host "Distribuciones detectadas en los idiomas instalados:"
        Write-Host ""


        foreach ($group in $groups) {

            $first =
            $group.Group |
            Select-Object -First 1


            $languages =
            $group.Group |
            Select-Object -ExpandProperty LanguageTag -Unique


            $languageText =
            $languages -join ", "


            Write-Host "[$index] $($first.Name)" `
                -ForegroundColor Cyan


            Write-Host "    Idiomas : $languageText"

            Write-Host "    Layout  : $($first.LayoutID)"

            Write-Host ""


            $keyboardOptions +=
            [PSCustomObject]@{

                Index       = $index

                Name        = $first.Name

                LayoutID    = $first.LayoutID

                InputTip    = $first.InputTip

                LanguageTag = $first.LanguageTag

                Languages   = $languages
            }


            $index++
        }


        Write-Host "[0] Volver"


        $selection = Read-TTKey `
            -Prompt "Selecciona la distribucion de teclado" `
            -ValidKeys @("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")


        if ($selection -eq "0") {

            return
        }


        # ----------------------------------------------------
        # VALIDAR OPCION
        # ----------------------------------------------------

        $number = 0


        if (-not [int]::TryParse(
                $selection,
                [ref]$number
            )) {

            Show-InvalidOption
            continue
        }


        $selected =
        $keyboardOptions |
        Where-Object {
            $_.Index -eq $number
        }


        if (-not $selected) {

            Show-InvalidOption
            continue
        }


        # ----------------------------------------------------
        # PREPARAR IDIOMA DEL TECLADO
        # ----------------------------------------------------

        try {

            $userLanguages =
            Get-WinUserLanguageList


            $languageExists =
            $userLanguages |
            Where-Object {
                $_.LanguageTag -eq $selected.LanguageTag
            }


            # ------------------------------------------------
            # Si el idioma esta instalado en Windows pero
            # todavia no esta agregado al perfil del usuario,
            # lo agregamos.
            # ------------------------------------------------

            if (-not $languageExists) {

                Write-Host ""

                Write-Host "Agregando perfil $($selected.LanguageTag) al usuario..." `
                    -ForegroundColor Yellow


                $newLanguage =
                New-WinUserLanguageList $selected.LanguageTag


                $userLanguages.Add(
                    $newLanguage[0]
                )


                Set-WinUserLanguageList `
                    $userLanguages `
                    -Force
            }


            # ------------------------------------------------
            # OBTENER INPUT TIP CORRECTO
            # ------------------------------------------------

            $updatedLanguages =
            Get-WinUserLanguageList


            $inputTip =
            $null


            foreach ($language in $updatedLanguages) {

                foreach ($tip in $language.InputMethodTips) {

                    $parts =
                    $tip -split ":"


                    if ($parts.Count -lt 2) {

                        continue
                    }


                    if ($parts[1].ToUpper() -eq
                        $selected.LayoutID) {

                        $inputTip = $tip

                        break
                    }
                }


                if ($inputTip) {

                    break
                }
            }


            # Si no encontramos uno ya agregado,
            # usamos el detectado originalmente.

            if (-not $inputTip) {

                $inputTip =
                $selected.InputTip
            }


            # ------------------------------------------------
            # CONFIGURAR PREDETERMINADO
            # ------------------------------------------------

            Set-WinDefaultInputMethodOverride `
                -InputTip $inputTip


            # ------------------------------------------------
            # ACTIVAR AHORA
            # ------------------------------------------------

            Set-TTActiveKeyboard `
                -InputTip $inputTip


            # ------------------------------------------------
            # ACTIVAR CTFMON
            # ------------------------------------------------

            $ctfmon =
            "$env:WINDIR\System32\ctfmon.exe"


            if (Test-Path $ctfmon) {

                Start-Process `
                    $ctfmon `
                    -ErrorAction SilentlyContinue
            }


            # ------------------------------------------------
            # RESULTADO
            # ------------------------------------------------

            Write-Host ""

            Write-Host "[OK] Distribucion cambiada." `
                -ForegroundColor Green


            Write-Host ""

            Write-Host "Teclado:" `
                -ForegroundColor Yellow


            Write-Host "  $($selected.Name)" `
                -ForegroundColor Cyan


            Write-Host ""

            Write-Host "Layout:"
            Write-Host "  $($selected.LayoutID)"


            Write-Host ""

            Write-Host "InputTip usado:"
            Write-Host "  $inputTip"


            Write-Log `
                "Teclado cambiado: $inputTip / Layout $($selected.LayoutID)"

            # Esperar ENTER
            Pause-TT

            # Salir de Show-TTKeyboardMenu y volver
            # al menu de Idioma, Region y Teclado
            return
        }
        catch {

            Write-Host ""

            Write-Host "ERROR configurando teclado:" `
                -ForegroundColor Red


            Write-Host $_.Exception.Message `
                -ForegroundColor Red
        }


        Pause-TT
    }
}



# ============================================================
# INTERPRETAR CODIGOS DE TECLADO
# ============================================================

function Get-TTKeyboardName {

    param(
        [string]$InputTip
    )


    if (-not $InputTip) {

        return "No determinado"
    }


    # InputTip:
    #
    # LanguageID:KeyboardLayoutID
    #
    # Ejemplos:
    #
    # 0409:00000409
    # 280A:0000080A
    # 080A:0000080A
    #
    # La parte derecha identifica la distribucion.


    $parts =
    $InputTip -split ":"


    if ($parts.Count -lt 2) {

        return "Distribucion desconocida ($InputTip)"
    }


    $layout =
    $parts[1].ToUpper()


    switch ($layout) {

        "00000409" {

            return "English - United States (US)"
        }


        "0000080A" {

            return "Espanol - Latinoamericano"
        }


        "0000040A" {

            return "Espanol - Espana"
        }


        "00000407" {

            return "Aleman - Alemania"
        }


        "0000040C" {

            return "Frances - Francia"
        }


        "00000410" {

            return "Italiano - Italia"
        }


        default {

            return "Distribucion desconocida ($layout)"
        }
    }
}



# ============================================================
# VER CONFIGURACION COMPLETA
# ============================================================

function Show-TTLanguageConfiguration {

    Show-SectionHeader "CONFIGURACION DE IDIOMA Y TECLADO"


    # --------------------------------------------------------
    # DATOS GENERALES
    # --------------------------------------------------------

    $languages =
    Get-WinUserLanguageList


    $ui =
    Get-WinUILanguageOverride


    $defaultKeyboard =
    Get-WinDefaultInputMethodOverride


    # --------------------------------------------------------
    # IDIOMA DE WINDOWS
    # --------------------------------------------------------

    Write-Host "IDIOMA DE WINDOWS" `
        -ForegroundColor Yellow

    Write-Host ""


    if ($ui) {

        Write-Host "  $($ui.LanguageTag)" `
            -ForegroundColor Cyan


        Write-Host "  Tipo: Forzado manualmente"
    }
    elseif ($languages.Count -gt 0) {

        Write-Host "  $($languages[0].LanguageTag)" `
            -ForegroundColor Cyan


        Write-Host "  Tipo: Automatico segun preferencias"
    }
    else {

        Write-Host "  No se pudo determinar." `
            -ForegroundColor Red
    }


    # --------------------------------------------------------
    # CONFIGURACION REGIONAL
    # --------------------------------------------------------

    Write-Host ""

    Write-Host "CONFIGURACION REGIONAL" `
        -ForegroundColor Yellow

    Write-Host ""


    Write-Host "  Cultura       : $((Get-Culture).Name)"

    Write-Host "  System Locale : $((Get-WinSystemLocale).Name)"


    # --------------------------------------------------------
    # TECLADO PREDETERMINADO
    # --------------------------------------------------------

    Write-Host ""

    Write-Host "TECLADO PREDETERMINADO" `
        -ForegroundColor Yellow

    Write-Host ""


    if ($defaultKeyboard) {

        Write-Host "  $(Get-TTKeyboardName $defaultKeyboard.InputMethodTip)" `
            -ForegroundColor Cyan


        Write-Host "  $($defaultKeyboard.InputMethodTip)"

        Write-Host "  Tipo: Forzado manualmente"
    }
    else {

        Write-Host "  Automatico" `
            -ForegroundColor Cyan


        Write-Host "  Windows selecciona el teclado segun la lista de idiomas."


        if ($languages.Count -gt 0) {

            $firstLanguage =
            $languages[0]


            if ($firstLanguage.InputMethodTips.Count -gt 0) {

                $tip =
                $firstLanguage.InputMethodTips[0]


                Write-Host ""

                Write-Host "  Primera distribucion disponible:"


                Write-Host "  $(Get-TTKeyboardName $tip)" `
                    -ForegroundColor Cyan


                Write-Host "  $tip"
            }
        }
    }


    # --------------------------------------------------------
    # IDIOMAS Y DISTRIBUCIONES
    # --------------------------------------------------------

    Write-Host ""

    Write-Host "IDIOMAS Y DISTRIBUCIONES DISPONIBLES" `
        -ForegroundColor Yellow

    Write-Host ""


    $position = 1


    foreach ($language in $languages) {

        Write-Host "[$position] $($language.LanguageTag) - $($language.EnglishName)" `
            -ForegroundColor Cyan


        foreach ($tip in $language.InputMethodTips) {

            Write-Host "    -> $(Get-TTKeyboardName $tip)"

            Write-Host "       $tip"
        }


        Write-Host ""

        $position++
    }


    Pause-TT
}