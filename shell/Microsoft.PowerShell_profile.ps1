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

# Cherche sh.exe dans le PATH, sinon utilise le chemin par défaut
$SH_PATH = Get-Command sh.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $SH_PATH) { $SH_PATH = "C:\Program Files\Git\bin\sh.exe" }

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

# --- Alias Git (PowerShell) ---
function ga { git add @args }
function gc { git commit -m $args }
function gs { git status }
function gp { git push }
function gl { git log --oneline -n 10 }
function gd { git diff }
function gco { git checkout @args }


# ============================================
# Aliases & Functions (Style Bash)
# ============================================

# Navigation rapide
function .. { cd .. }
function ... { cd ../.. }
function .... { cd ../../.. }

# Listing (Utilise les paramètres natifs de Get-ChildItem)
# Nota : 'ls' est déjà un alias vers Get-ChildItem sous Windows.
function ll { Get-ChildItem -Force | Format-Table }
function la { Get-ChildItem -Force }
function l  { Get-ChildItem }

# Surveillance des logs (Équivalent de tail -f)
function tail-logs { 
    Get-Content *.log -Wait -Tail 10 
}

# Bonus : Créer un dossier et y entrer (Très utile)
function mkcd ($dir) {
    New-Item -ItemType Directory -Path $dir
    Set-Location $dir
}

# --- Configuration Neovim (Auto-détection portable) ---

# 1. On cherche nvim.exe dans le PATH
$nvimPath = Get-Command nvim -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

# 2. Si non trouvé, on cherche dans les dossiers d'installation standards
if (-not $nvimPath) {
    $commonPaths = @(
        "C:\Program Files\Neovim\bin\nvim.exe",
        "$env:LOCALAPPDATA\nvim-win64\bin\nvim.exe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\neovim.neovim_Microsoft.Winget.Source_*\bin\nvim.exe"
    )
    foreach ($p in $commonPaths) {
        $resolved = Resolve-Path $p -ErrorAction SilentlyContinue
        if ($resolved) { $nvimPath = $resolved.Path; break }
    }
}

# 3. On crée la fonction vi seulement si nvim est trouvé
if ($nvimPath) {
    function vi { & $nvimPath $args }
} else {
    # Optionnel: avertir que nvim manque pour inciter à lancer le bootstrap
    # Write-Host "[!] Neovim non trouvé. Lancez bootstrap.ps1" -ForegroundColor Yellow
}

# ============================================
# Aliases & Functions (Style Bash)
# ============================================
function .. { cd .. }
function ... { cd ../.. }
function .... { cd ../../.. }

function check-stack { bash "$env:DOTFILES/scripts/check-stack.sh" }

# Listing (Utilise les paramètres natifs de Get-ChildItem)
function ll { Get-ChildItem -Force | Format-Table }
function la { Get-ChildItem -Force }
function l  { Get-ChildItem }

# Surveillance des logs (Équivalent de tail -f)
function tail-logs { Get-Content *.log -Wait -Tail 10 }

# ============================================
# Maven & Java (Ugram Project)
# ============================================
function mc { mvn clean compile }
function mt { mvn clean test }
function mp { mvn clean package -DskipTests }
function ms { mvn spring-boot:run }

# ============================================
# Docker & Docker Compose
# ============================================
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function dstop { docker stop $(docker ps -q) }
function dclean { docker system prune -a --volumes }

# Vérifier la santé des containers Ugram (Healthcheck)
function dch { 
    docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "ugram|health"
}

# Alias pour inspecter pourquoi un container est "Unhealthy"
function dci ($name) { docker inspect --format='{{json .State.Health}}' $name | ConvertFrom-Json }

# Docker Compose (Simplifié en 'dc')
function dcu { docker-compose up -d }                 # Up en arrière-plan
function dcub { docker-compose up -d --build }        # Force le build avant de monter
function dcd { docker-compose down }                  # Stop et retire les containers
function dcdv { docker-compose down -v }              # Stop et SUPPRIME les volumes (Reset DB)
function dcl { docker-compose logs -f }               # Tail des logs de tous les services
function dcv { docker-compose up }                    # Mode verbeux standard
function dcvv { docker-compose --verbose up }         # Mode ultra verbeux (Debug infra)

# ============================================
# System & Network
# ============================================
function myip { (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 2 }
function oo { explorer . }
function ps-find ($name) { Get-Process "*$name*" }
function kill-port ($port) {
    $id = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($id) { Stop-Process -Id $id -Force; echo "Port $port libéré (PID $id)" }
    else { echo "Aucun processus sur le port $port" }
}

# ============================================
# Git Aliases (PowerShell)
# ============================================
function ga { git add @args }
function gc { git commit -m $args }
function gs { git status }
function gp { git push }
function gl { git log --oneline -n 10 }
function gd { git diff }
function gco { git checkout @args }
function gca { git commit --amend --no-edit }
function gundo { git reset --soft HEAD~1 }

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