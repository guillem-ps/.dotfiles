# Función para preguntar al usuario y confirmar la acción
function Confirm-Action {
    param (
        [string]$message
    )

    $response = Read-Host "$message (y/n)"
    if ($response -eq "y") {
        return $true
    } else {
        return $false
    }
}

# Verificar si es Windows
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Output "Este script solo se puede ejecutar en Windows."
    exit
}

# Instalar o actualizar Chocolatey si no está instalado
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    # Configurar la política de ejecución para permitir la ejecución de scripts
    Set-ExecutionPolicy Bypass -Scope Process -Force
    # Configurar el protocolo de seguridad para la descarga
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    # Ejecutar el script de instalación de Chocolatey
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Función para instalar o actualizar un programa si no está instalado
function Install-OrUpgrade {
    param (
        [string]$program,
        [string]$packageName
    )

    # Verificar si el programa ya está instalado
    Write-Output "### $program ###"
    $packageStatus = Get-Command $program -ErrorAction SilentlyContinue
    if ($packageStatus -match "Installed") {
        $upgrade = Confirm-Action "¿Desea actualizar?"
        if ($upgrade) {
            Write-Output "Actualizando $program..."
            choco upgrade $packageName -y
        } else {
            Write-Output "Acción cancelada para $program."
        }
    } else {
        $install = Confirm-Action "¿Desea instalar?"
        if ($install) {
            Write-Output "Instalando $program..."
            choco install $packageName -y
        } else {
            Write-Output "Acción cancelada para $program."
        }
    }
}

# Instalar o actualizar programas
Install-OrUpgrade "Visual Studio Code" "vscode" # (https://chocolatey.org/packages/vscode)
Install-OrUpgrade "Docker Desktop" "docker-desktop" # (https://chocolatey.org/packages/docker-desktop)
Install-OrUpgrade "Discord" "discord" # (https://chocolatey.org/packages/discord)
Install-OrUpgrade "Postman" "postman" # (https://chocolatey.org/packages/postman)
Install-OrUpgrade "Spotify" "spotify" # (https://chocolatey.org/packages/spotify)
Install-OrUpgrade "Brave" "brave" # (https://chocolatey.org/packages/brave)
# Install-OrUpgrade "WhatsApp" "whatsapp" # No disponible en Chocolatey 
Install-OrUpgrade "Git" "git" # (https://chocolatey.org/packages/git)
Install-OrUpgrade "Python 3.11" "python --version 3.11.9" # Cambiar la versión si es necesario (https://chocolatey.org/packages/python)
Install-OrUpgrade "Windows Terminal" "microsoft-windows-terminal" # (https://chocolatey.org/packages/microsoft-windows-terminal)
Install-OrUpgrade "Spark Mail" "sparkmail" # (https://chocolatey.org/packages/sparkmail)
Install-OrUpgrade "Steam" "steam" # (https://chocolatey.org/packages/steam)
Install-OrUpgrade "Epic Games Launcher" "epicgameslauncher" # (https://chocolatey.org/packages/epicgameslauncher)

# Instalar oh-my-zsh si zsh está instalado
if (Get-Command zsh -ErrorAction SilentlyContinue) {
    if (-not (Test-Path "$HOME/.oh-my-zsh")) {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh'))
    }
}

Write-Output "Instalación de programas en Windows completada."
