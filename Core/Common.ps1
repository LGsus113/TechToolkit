function Write-Log {
    param([string]$Message)

    if (-not (Test-Path $script:LogDir)) {
        New-Item -ItemType Directory -Force -Path $script:LogDir | Out-Null
    }

    Add-Content -Path $script:LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

function Test-TTAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Require-TTAdmin {
    if (-not (Test-TTAdmin)) {
        Write-Host "Esta opcion requiere permisos de administrador." -ForegroundColor Yellow
        Pause-TT
        return $false
    }
    return $true
}

function Invoke-TTCommand {
    param(
        [Parameter(Mandatory)]
        [string]$File,

        [string[]]$Arguments = @()
    )

    Write-Log "$File $($Arguments -join ' ')"
    & $File @Arguments
}
