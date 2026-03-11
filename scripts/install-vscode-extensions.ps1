# install-vscode-extensions.ps1 - Install VS Code extensions on Windows
# Usage: powershell -ExecutionPolicy Bypass -File scripts\install-vscode-extensions.ps1

$ErrorActionPreference = "Stop"

# --- RECURSION GUARD ---
# Si le script détecte qu'il est exécuté DEPUIS un terminal VS Code, il s'arrête immédiatement.
if ($env:TERM_PROGRAM -eq "vscode") {
    Write-Host ">>> Already inside VS Code terminal. Skipping installation to prevent infinite loop." -ForegroundColor Cyan
    exit 0
}

$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = Split-Path -Parent -Path $SCRIPT_DIR

# Check if code command is available
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: VS Code CLI (code) not found. Skipping extension installation." -ForegroundColor Yellow
    exit 0
}

Write-Host "Installing VS Code extensions..." -ForegroundColor Green

$extensionsFile = "$DOTFILES\vscode\extensions.txt"

if (-not (Test-Path $extensionsFile)) {
    Write-Host "ERROR: $extensionsFile not found" -ForegroundColor Red
    exit 1
}

$extensions = @(Get-Content $extensionsFile | Where-Object { $_ -and -not $_.StartsWith("#") })

if ($extensions.Count -eq 0) {
    Write-Host "No extensions to install." -ForegroundColor Yellow
    exit 0
}

$failedCount = 0
$successCount = 0

foreach ($extension in $extensions) {
    $extension = $extension.Trim()
    
    if (-not $extension -or $extension.StartsWith("#")) {
        continue
    }
    
    Write-Host "Installing: $extension" -ForegroundColor Yellow
    
    try {
        # L'ajout de --force est crucial pour éviter les prompts bloquants
        $output = code --install-extension $extension --force 2>&1
        Write-Host "[OK] Installed $extension" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "[!] Failed to install $extension" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host ""
Write-Host "[OK] Extensions installation complete." -ForegroundColor Green
Write-Host "  Installed: $successCount | Failed: $failedCount" -ForegroundColor Cyan