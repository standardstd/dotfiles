# --- Détection dynamique et robuste du chemin ---

# 1. On récupère le chemin du script actuel
$currentFile = $MyInvocation.MyCommand.Definition

# 2. Si c'est un lien symbolique (symlink), on récupère la cible réelle pour trouver le dossier dotfiles
$item = Get-Item $currentFile
if ($item.Attributes -match "ReparsePoint" -or $item.LinkType) {
    $currentFile = $item.Target
}

# 3. Calcul du chemin racine : ce script est dans 'shell/', donc le parent est la racine
$SHELL_DIR = Split-Path -Parent $currentFile
$DOTFILES_PATH = Split-Path -Parent $SHELL_DIR

$SH_PATH = "C:\Program Files\Git\bin\sh.exe"

# --- Fonctions Dotfiles ---

function dot-push {
    if (Test-Path "$DOTFILES_PATH\scripts\push.sh") {
        Push-Location $DOTFILES_PATH
        & $SH_PATH "$DOTFILES_PATH\scripts\push.sh"
        Pop-Location
    } else {
        Write-Host "[!] Script push.sh introuvable dans $DOTFILES_PATH" -ForegroundColor Red
    }
}

function dot-up {
    if (Test-Path "$DOTFILES_PATH\scripts\update.sh") {
        Push-Location $DOTFILES_PATH
        & $SH_PATH "$DOTFILES_PATH\scripts\update.sh"
        Pop-Location
    }
}

function dot-code {
    if (Test-Path $DOTFILES_PATH) { 
        code $DOTFILES_PATH 
    }
}

# --- Raccourcis classiques ---
New-Alias -Name ll -Value ls -Force
function .. { Set-Location .. }

Write-Host "[OK] Profil Dotfiles chargé (Path: $DOTFILES_PATH)" -ForegroundColor Cyan

# --- Personnalisation du Prompt (reagan@machine:dossier (branch)) ---

function prompt {
    # 1. Identité et Machine (en Vert)
    $user = $env:USERNAME
    $machine = $env:COMPUTERNAME
    Write-Host "$user@$machine" -NoNewline -ForegroundColor Green
    Write-Host ":" -NoNewline -ForegroundColor Gray

    # 2. Répertoire courant uniquement (en Bleu)
    # Split-Path -Leaf extrait uniquement le dernier nom du dossier
    $currentDir = Split-Path -Leaf $(Get-Location)
    # Si on est à la racine d'un disque ou dans le dossier home, on peut ajuster
    if ($currentDir -eq "") { $currentDir = $(Get-Location).Path } 
    
    Write-Host $currentDir -NoNewline -ForegroundColor Blue

    # 3. Branche Git (en Cyan)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git branch --show-current 2>$null
        if ($branch) {
            Write-Host " ($branch)" -NoNewline -ForegroundColor Cyan
        }
    }

    # 4. Le symbole final
    Write-Host "$ " -NoNewline -ForegroundColor Gray
    return " "
}