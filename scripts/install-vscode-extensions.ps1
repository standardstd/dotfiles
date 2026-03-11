# install-vscode-extensions.ps1 - Install VS Code extensions on Windows
# Usage: powershell -ExecutionPolicy Bypass -File scripts\install-vscode-extensions.ps1

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = Split-Path -Parent -Path $SCRIPT_DIR

# Check if code command is available
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: VS Code CLI (code) not found. Skipping extension installation." -ForegroundColor Yellow
    Write-Host "Make sure VS Code is installed and 'code' is in your PATH." -ForegroundColor Yellow
    Write-Host "Typically added automatically after VS Code install. Restart your terminal." -ForegroundColor Yellow
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
    
    # Skip empty lines and comments
    if (-not $extension -or $extension.StartsWith("#")) {
        continue
    }
    
    Write-Host "Installing: $extension" -ForegroundColor Yellow
    
    try {
        $output = code --install-extension $extension --force 2>&1
        # Remplacement du symbole ✓ par [OK]
        Write-Host "[OK] Installed $extension" -ForegroundColor Green
        $successCount++
    }
    catch {
        # Remplacement du symbole ⚠ par [!]
        Write-Host "[!] Failed to install $extension" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host ""
# Remplacement du symbole ✓ par [OK]
Write-Host "[OK] Extensions installation complete." -ForegroundColor Green
Write-Host "  Installed: $successCount | Failed: $failedCount" -ForegroundColor Cyan