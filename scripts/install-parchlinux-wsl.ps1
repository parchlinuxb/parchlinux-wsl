#Requires -RunAsAdministrator

param(
    [string]$InstallPath = "$env:USERPROFILE\ParchLinux",
    [string]$DownloadUrl = "https://mirror.parchlinux.ir/wsl/parchlinux-wsl-latest.wsl"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[+] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[-] $Message" -ForegroundColor Red
}

function Test-WslEnabled {
    Write-Step "Checking if WSL is enabled..."

    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
    } catch {
        Write-Fail "Unable to check WSL status. Please run this script as Administrator."
        exit 1
    }

    if ($wslFeature.State -eq "Enabled") {
        Write-Success "WSL is already enabled"
        return $true
    } else {
        Write-Warn "WSL is not enabled"
        return $false
    }
}

function Enable-WslFeature {
    Write-Step "Enabling WSL features..."

    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -WarningAction SilentlyContinue
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -WarningAction SilentlyContinue
        Write-Success "WSL features enabled. Restart required."
    } catch {
        Write-Fail "Failed to enable WSL: $_"
        exit 1
    }
}

function Install-ParchLinuxWsl {
    param([string]$Url, [string]$Path)

    Write-Step "Downloading ParchLinux WSL..."
    $fileName = Split-Path $Url -Leaf
    $tempPath = Join-Path $env:TEMP $fileName

    try {
        Invoke-WebRequest -Uri $Url -OutFile $tempPath -UseBasicParsing
        $fileSize = (Get-Item $tempPath).Length / 1MB
        Write-Success "Downloaded ($([math]::Round($fileSize, 2)) MB)"
    } catch {
        Write-Fail "Failed to download: $_"
        exit 1
    }

    Write-Step "Installing ParchLinux WSL..."

    $existing = wsl -l -q 2>$null
    if ($existing -contains "ParchLinux") {
        Write-Warn "ParchLinux already installed, unregistering..."
        wsl --unregister ParchLinux 2>$null
    }

    try {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        wsl --import ParchLinux $Path $tempPath --version 2
        Write-Success "ParchLinux WSL installed"
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Fail "Failed to import WSL: $_"
        exit 1
    }
}

function Set-WslIcon {
    Write-Step "Setting ParchLinux icon..."

    $iconPath = Join-Path $InstallPath "parch.ico"
    $iconUrl = "https://raw.githubusercontent.com/parchlinux/parchlinux-wsl/main/rootfs/usr/lib/wsl/parch.ico"

    try {
        Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath -UseBasicParsing
        Write-Success "Icon downloaded"
    } catch {
        Write-Warn "Could not download icon, trying to copy from WSL..."
    }

    try {
        $wslGuid = (Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -ErrorAction SilentlyContinue | Where-Object { (Get-ItemProperty $_.PSPath).DistributionName -eq "ParchLinux" }).PSChildName
        
        if ($wslGuid) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\$wslGuid" -Name "DefaultIcon" -Value $iconPath -ErrorAction SilentlyContinue
            Write-Success "Icon set successfully"
        } else {
            Write-Warn "Could not find ParchLinux WSL GUID"
        }
    } catch {
        Write-Warn "Could not set icon: $_"
    }
}

Write-Host @"

  ParchLinux WSL Installer
  =========================

"@ -ForegroundColor Magenta

$wslEnabled = Test-WslEnabled

if (-not $wslEnabled) {
    $enable = Read-Host "Enable WSL now? (y/n)"
    if ($enable -eq "y" -or $enable -eq "Y") {
        Enable-WslFeature
        Write-Warn "Please restart your computer and run this script again."
        exit 0
    } else {
        Write-Fail "WSL must be enabled. Exiting."
        exit 1
    }
}

Write-Step "Downloading from: $DownloadUrl"
Install-ParchLinuxWsl -Url $DownloadUrl -Path $InstallPath
Set-WslIcon

Write-Host @"

  Installation Complete!
  ======================

  To start ParchLinux WSL:
    wsl -d ParchLinux

"@ -ForegroundColor Green
