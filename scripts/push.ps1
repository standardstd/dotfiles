$ErrorActionPreference = "Stop"

# Aller à la racine du dépôt
$DOTFILES = Split-Path -Parent -Path $PSScriptRoot
Set-Location $DOTFILES

Write-Host "--- Pushing Dotfiles to GitHub ---" -ForegroundColor Cyan

# 1. Préparation
git add .

# 2. Vérification de sécurité
Write-Host "Running security checks..." -ForegroundColor Yellow
if (Test-Path "$DOTFILES\scripts\check-secrets.sh") {
    # On utilise bash (via Git Bash) pour exécuter le check de sécurité
    sh "$DOTFILES\scripts\check-secrets.sh"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Push aborted. Please fix the security issues." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  Warning: scripts/check-secrets.sh not found." -ForegroundColor DarkYellow
}

# 3. Message de commit
$msg = Read-Host "Commit message (Enter for 'Daily dotfiles update')"
if ([string]::IsNullOrWhiteSpace($msg)) { 
    $msg = "Daily dotfiles update ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))" 
}

# 4. Sync
Write-Host "Syncing with GitHub..." -ForegroundColor Yellow
git commit -m $msg
git push

Write-Host "-------------------------------------------"
Write-Host "✓ Changes pushed successfully!" -ForegroundColor Green