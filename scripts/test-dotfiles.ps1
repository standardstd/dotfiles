# scripts/test-dotfiles.ps1
$ErrorActionPreference = "Continue"

Write-Host "--- 🔍 Diagnostic des Dotfiles (PowerShell) ---" -ForegroundColor Cyan
Write-Host ""

$DOTFILES = $env:DOTFILES
if (-not $DOTFILES) { $DOTFILES = "$HOME\dotfiles" }

# 1. Test des liens symboliques critiques
function Check-Link {
    param([string]$Path)
    Write-Host "🔗 $Path : " -NoNewline
    
    if (Test-Path $Path) {
        $item = Get-Item $Path
        if ($item.Attributes -match "ReparsePoint" -or $item.LinkType) {
            Write-Host "[OK]" -ForegroundColor Green -NoNewline
            Write-Host " (Pointe vers: $($item.Target))" -ForegroundColor Gray
        } else {
            Write-Host "[ERREUR]" -ForegroundColor Red -NoNewline
            Write-Host " (C'est un fichier réel, pas un lien)" -ForegroundColor Gray
        }
    } else {
        Write-Host "[MANQUANT]" -ForegroundColor Yellow
    }
}

Write-Host "📂 Vérification des liens Windows :"
Check-Link "$HOME\.gitconfig"
Check-Link "$HOME\.ideavimrc"
Check-Link "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# 2. Vérification des outils
Write-Host "`n🛠️  Disponibilité des outils :"
$tools = @("mvn", "docker", "nvim", "git")
foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "✅ $tool : Installé" -ForegroundColor Green
    } else {
        Write-Host "❌ $tool : Manquant" -ForegroundColor Red
    }
}

Write-Host "`n--- Fin du diagnostic ---"