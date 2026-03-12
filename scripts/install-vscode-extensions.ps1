# install-vscode-extensions.ps1 - Install VS Code extensions on Windows
$ErrorActionPreference = "Stop"

# --- RECURSION GUARD ---
if ($env:TERM_PROGRAM -eq "vscode") {
    Write-Host ">>> Already inside VS Code terminal. Skipping installation to prevent infinite loop." -ForegroundColor Cyan
    exit 0
}

# --- Détection du chemin ---
$DOTFILES = $env:DOTFILES
if (-not $DOTFILES) {
    # Si la variable d'environnement manque, on calcule : script est dans scripts/, donc parent du parent
    $DOTFILES = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)
}

# Vérifier si VS Code est accessible
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "WARNING: VS Code CLI (code) not found. Skipping extension installation." -ForegroundColor Yellow
    exit 0
}

$extensionsFile = "$DOTFILES\vscode\extensions.txt"

if (-not (Test-Path $extensionsFile)) {
    Write-Host "ERROR: $extensionsFile not found at $extensionsFile" -ForegroundColor Red
    exit 1
}

# Lecture et nettoyage de la liste des extensions
$extensions = Get-Content $extensionsFile | Where-Object { $_.Trim() -and -not $_.StartsWith("#") }

if ($null -eq $extensions -or $extensions.Count -eq 0) {
    Write-Host "No extensions found in extensions.txt." -ForegroundColor Yellow
    exit 0
}

# Récupérer la liste des extensions déjà installées
Write-Host "Fetching list of already installed extensions..." -ForegroundColor Gray
$installedExtensions = code --list-extensions

Write-Host "Installing VS Code extensions..." -ForegroundColor Green

$failedCount = 0
$successCount = 0
$skippedCount = 0

foreach ($extension in $extensions) {
    $extension = $extension.Trim()
    
    # Comparaison insensible à la casse pour plus de fiabilité
    if ($installedExtensions -match "^$([Regex]::Escape($extension))$") {
        Write-Host "[SKIP] $extension is already installed" -ForegroundColor Gray
        $skippedCount++
        continue
    }
    
    Write-Host "Installing: $extension..." -ForegroundColor Yellow
    
    try {
        # --force est utilisé pour garantir l'installation/mise à jour sans prompt
        $null = code --install-extension $extension --force
        Write-Host "[OK] Installed $extension" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "[!] Failed to install $extension" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host ""
Write-Host "--- Summary ---" -ForegroundColor Green
Write-Host "  Success: $successCount" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount (Already present)" -ForegroundColor Gray
Write-Host "  Failed:  $failedCount" -ForegroundColor Red