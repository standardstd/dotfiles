# install-tools.ps1 - Install development tools on Windows
$ErrorActionPreference = "Stop"

Write-Host "--- Installing base tools for Windows ---" -ForegroundColor Cyan

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Winget not found." -ForegroundColor Red
    exit 1
}

# Essential tools to install (Added pyenv-win)
$tools = @(
    @{ id = "Git.Git"; name = "Git" },
    @{ id = "Neovim.Neovim"; name = "Neovim" },
    @{ id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code" },
    @{ id = "pyenv-win.pyenv-win"; name = "pyenv-win" }
)

$optionalTools = @(
    @{ id = "DirtyRaccoon.Notepad"; name = "Notepad++" },
    @{ id = "BurntSushi.ripgrep.MSVC"; name = "ripgrep" }
)

Write-Host "Installing essential tools..." -ForegroundColor Green

foreach ($tool in $tools) {
    Write-Host "Installing $($tool.name)..." -ForegroundColor Yellow
    try {
        $null = winget install --exact --id $tool.id `
            --silent `
            --accept-source-agreements `
            --accept-package-agreements 2>&1
        Write-Host "[OK] Installed $($tool.name)" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Failed to install $($tool.name) (it might already be installed)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[OK] Tools installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "Note: For pyenv-win, you may need to restart your terminal to use 'pyenv' command." -ForegroundColor Cyan