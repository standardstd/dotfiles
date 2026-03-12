# push.ps1 - Sync dotfiles to GitHub
$ErrorActionPreference = "Stop"

# --- Détection du chemin ---
$DOTFILES = $env:DOTFILES
if (-not $DOTFILES) {
    # Si la variable d'env n'existe pas, on prend le parent du dossier 'scripts'
    $DOTFILES = Split-Path -Parent -Path $PSScriptRoot
}
Set-Location $DOTFILES

Write-Host "--- Pushing Dotfiles to GitHub ---" -ForegroundColor Cyan

# 1. Vérifier s'il y a des changements avant de continuer
$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to push. Everything is up to date." -ForegroundColor Green
    exit 0
}

# 2. Préparation
git add .

# 3. Vérification de sécurité (Bridge vers WSL)
Write-Host "Running security checks..." -ForegroundColor Yellow
$checkSecrets = Join-Path $DOTFILES "scripts\check-secrets.sh"

if (Test-Path $checkSecrets) {
    # On convertit le chemin Windows vers le format Linux (ex: /mnt/c/Users/Reagan/...)
    # On remplace les \ par / pour éviter les problèmes d'échappement
    $cleanPath = $checkSecrets.Replace('\', '/')
    $wslPath = wsl wslpath $cleanPath
    
    # Exécution dans l'environnement Linux
    wsl bash $wslPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Push aborted. Please fix the security issues (secrets detected)." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  Warning: scripts/check-secrets.sh not found. Skipping security check." -ForegroundColor DarkYellow
}

# 4. Message de commit
$dateStr = Get-Date -Format 'yyyy-MM-dd HH:mm'
$msg = Read-Host "Commit message (Enter for 'Update $dateStr')"
if ([string]::IsNullOrWhiteSpace($msg)) { 
    $msg = "Update $dateStr" 
}

# 5. Sync
Write-Host "Syncing with GitHub..." -ForegroundColor Yellow
try {
    git commit -m $msg
    git push
    Write-Host "-------------------------------------------"
    Write-Host "✓ Changes pushed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error during git push. Check your connection or remote permissions." -ForegroundColor Red
}