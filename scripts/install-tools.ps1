# install-tools.ps1 - Install development tools on Windows
# Usage: powershell -ExecutionPolicy Bypass -File scripts\install-tools.ps1

$ErrorActionPreference = "Stop"

Write-Host "--- Installing base tools for Windows ---" -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Winget not found." -ForegroundColor Red
    Write-Host "Install Windows Package Manager from: https://www.microsoft.com/store/productId/9NBLGGH4NNS1" -ForegroundColor Red
    exit 1
}

# Essential tools to install
$tools = @(
    @{ id = "Git.Git"; name = "Git" },
    @{ id = "Neovim.Neovim"; name = "Neovim" },
    @{ id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code" }
)

# Optional tools (can help but not required)
$optionalTools = @(
    @{ id = "DirtyRaccoon.Notepad"; name = "Notepad++" },
    @{ id = "BurntSushi.ripgrep.MSVC"; name = "ripgrep" }
)

Write-Host "Installing essential tools..." -ForegroundColor Green

foreach ($tool in $tools) {
    Write-Host "Installing $($tool.name)..." -ForegroundColor Yellow
    
    try {
        $output = winget install --exact --id $tool.id `
            --silent `
            --accept-source-agreements `
            --accept-package-agreements 2>&1
        
        # Remplacement du symbole ✓ par [OK]
        Write-Host "[OK] Installed $($tool.name)" -ForegroundColor Green
    }
    catch {
        # Remplacement du symbole ⚠ par [!]
        Write-Host "[!] Failed to install $($tool.name): $_" -ForegroundColor Red
    }
}

Write-Host ""
# Remplacement du symbole ✓ par [OK]
Write-Host "[OK] Tools installation complete" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Add Git and Neovim to PATH if needed:" -ForegroundColor Cyan
Write-Host "  - Git Bash is typically at: C:\Program Files\Git\bin\bash.exe" -ForegroundColor Cyan
Write-Host "  - Neovim is typically at: C:\Users\<user>\AppData\Local\nvim" -ForegroundColor Cyan