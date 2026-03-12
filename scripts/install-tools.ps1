# install-tools.ps1 - Install development tools on Windows
$ErrorActionPreference = "Stop"

Write-Host "--- Installing base tools for Windows ---" -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Winget not found. Please install App Installer from the Microsoft Store." -ForegroundColor Red
    exit 1
}

# Essential tools (Added PowerShell 7 and Docker for Ugram)
$tools = @(
    @{ id = "Microsoft.PowerShell"; name = "PowerShell 7" },
    @{ id = "Git.Git"; name = "Git" },
    @{ id = "Neovim.Neovim"; name = "Neovim" },
    @{ id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code" },
    @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" },
    @{ id = "pyenv.pyenv-win"; name = "pyenv-win" }
)

$optionalTools = @(
    @{ id = "Microsoft.OpenJDK.17"; name = "Microsoft OpenJDK 17" }, # Utile pour Maven/Ugram
    @{ id = "BurntSushi.ripgrep.MSVC"; name = "ripgrep" }
)

function Install-WithWinget($packageList) {
    foreach ($tool in $packageList) {
        Write-Host "Checking $($tool.name)... " -NoNewline -ForegroundColor Yellow
        
        # Vérifie si déjà installé pour éviter le message d'erreur de winget
        $isInstalled = winget list --exact --id $tool.id -e 2>$null
        
        if ($isInstalled) {
            Write-Host "[ALREADY INSTALLED]" -ForegroundColor Gray
        } else {
            Write-Host "Installing..." -ForegroundColor Yellow
            try {
                $null = winget install --exact --id $tool.id `
                    --silent `
                    --accept-source-agreements `
                    --accept-package-agreements
                Write-Host "[OK] Installed $($tool.name)" -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Failed to install $($tool.name)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "--- Essential Tools ---" -ForegroundColor Green
Install-WithWinget $tools

Write-Host "`n--- Optional Tools ---" -ForegroundColor Green
Install-WithWinget $optionalTools

Write-Host "`n[OK] Tools installation process complete" -ForegroundColor Green
Write-Host "Note: Restart your terminal or VS Code to refresh environment variables (pyenv, docker, etc.)." -ForegroundColor Cyan