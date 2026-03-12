# Forcer l'encodage UTF-8 par défaut
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# --- Détection dynamique du chemin ---
$DOTFILES_PATH = "$HOME\dotfiles"

# Sécurité : Si le dossier shell n'est pas trouvé, on recalcule via le lien symbolique
if (-not (Test-Path "$DOTFILES_PATH\shell")) {
    $currentFile = $MyInvocation.MyCommand.Definition
    $item = Get-Item $currentFile -ErrorAction SilentlyContinue
    if ($item.Attributes -match "ReparsePoint" -or $item.LinkType) {
        $currentFile = $item.Target
    }
    $SHELL_DIR = Split-Path -Parent $currentFile
    $DOTFILES_PATH = Split-Path -Parent $SHELL_DIR
}

$env:DOTFILES = $DOTFILES_PATH

# Localisation de sh.exe (Git Bash) pour les scripts .sh
$SH_PATH = Get-Command sh.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $SH_PATH) { $SH_PATH = "C:\Program Files\Git\bin\sh.exe" }

# --- Fonctions Dotfiles ---

function dot-push {
    if (Test-Path "$DOTFILES_PATH\scripts\push.ps1") {
        & "$DOTFILES_PATH\scripts\push.ps1"
    } else {
        Write-Host "[!] Script push.ps1 introuvable." -ForegroundColor Red
    }
}

function dot-up {
    if (Test-Path "$DOTFILES_PATH\scripts\bootstrap.ps1") {
        & "$DOTFILES_PATH\scripts\bootstrap.ps1"
    }
}

function dot-code { code $DOTFILES_PATH }

function reload { 
    & $profile 
    Write-Host "Profil PowerShell rechargé !" -ForegroundColor Cyan
}

# ============================================
# Aliases & Navigation
# ============================================

function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force }
function l  { Get-ChildItem }

function tail-logs { Get-Content *.log -Wait -Tail 10 }

function mkcd ($dir) {
    New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue | Out-Null
    Set-Location $dir
}

# --- Configuration Neovim (vi) ---
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    function vi { nvim $args }
}

function check-stack {
    wsl bash -c "~/dotfiles/scripts/check-stack.sh"
}

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
function dch { docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "ugram|health|Names" }
function dci ($name) { docker inspect --format='{{json .State.Health}}' $name | ConvertFrom-Json }

function dcu { docker-compose up -d }
function dcub { docker-compose up -d --build }
function dcd { docker-compose down }
function dcdv { docker-compose down -v }
function dcl { docker-compose logs -f }

# ============================================
# System & Network
# ============================================
function myip { (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*" }).IPAddress }
function oo { explorer . }
function kill-port ($port) {
    $id = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue).OwningProcess
    if ($id) { 
        Stop-Process -Id $id -Force
        Write-Host "Port $port libéré (PID $id)" -ForegroundColor Green
    } else { 
        Write-Host "Aucun processus sur le port $port" -ForegroundColor Yellow
    }
}

# ============================================
# Git Aliases
# ============================================
function ga { git add $args }
function gc { git commit -m "$args" }
function gs { git status }
function gp { git push }
function gl { git log --oneline -n 10 }
function gd { git diff }
function gco { git checkout $args }

# --- Fin du chargement ---
Write-Host "[OK] Profil Dotfiles chargé" -ForegroundColor Cyan

# --- Personnalisation du Prompt ---
function prompt {
    $user = $env:USERNAME
    $machine = $env:COMPUTERNAME
    $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, "~")
    
    Write-Host "$user@$machine" -NoNewline -ForegroundColor Green
    Write-Host ":" -NoNewline -ForegroundColor Gray
    Write-Host $path -NoNewline -ForegroundColor Blue

    $branch = git branch --show-current 2>$null
    if ($branch) {
        Write-Host " ($branch)" -NoNewline -ForegroundColor Cyan
    }

    Write-Host " PS> " -NoNewline -ForegroundColor Gray
    return " "
}

# --- Validation Totale (Windows + WSL) ---
function test-all {
    Write-Host "`n=== [VÉRIFICATION WINDOWS] ===" -ForegroundColor Cyan
    # On appelle le script PS1 s'il existe
    if (Test-Path "$DOTFILES_PATH\scripts\test-dotfiles.ps1") {
        & "$DOTFILES_PATH\scripts\test-dotfiles.ps1"
    } else {
        Write-Host "Script test-dotfiles.ps1 non trouvé." -ForegroundColor Yellow
    }

    Write-Host "`n=== [VÉRIFICATION WSL / LINUX] ===" -ForegroundColor Cyan
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash -c "~/dotfiles/scripts/test-dotfiles.sh"
    } else {
        Write-Host "WSL n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Red
    }
    
    Write-Host "`n=== Diagnostic Terminé ===" -ForegroundColor Cyan
}