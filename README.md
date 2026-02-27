# ParchLinux WSL

Parch Linux WSL image builder

## Installation

### PowerShell (Recommended)

Run the following command in PowerShell as Administrator:

```powershell
irm https://raw.githubusercontent.com/parchlinux/parchlinux-wsl/main/scripts/install-parchlinux-wsl.ps1 | iex
```

Or download and run manually:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/parchlinux/parchlinux-wsl/main/scripts/install-parchlinux-wsl.ps1 -OutFile install-parchlinux-wsl.ps1
.\install-parchlinux-wsl.ps1
```

### Manual Installation

1. Download the latest WSL image from the [releases](https://github.com/parchlinux/parchlinux-wsl/releases)
2. Import with WSL:
   ```powershell
   wsl --import ParchLinux <path> <path\to\parchlinux-wsl-latest.wsl> --version 2
   ```
3. Launch:
   ```powershell
   wsl -d ParchLinux
   ```

## Build from Source

```bash
make build
```

Output will be in `workdir/output/`

## Requirements

- Windows 10 version 1903 or later / Windows 11
- WSL 2 enabled
