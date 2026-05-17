# Configuration Dotfiles en Mode Utilisateur (Sans Droits Admin)

## Table des matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Cartographie des scripts compatibles](#cartographie-des-scripts-compatibles)
4. [Configuration des IDE et Éditeurs](#configuration-des-ide-et-éditeurs)
5. [Shell, Alias et Liens Symboliques](#shell-alias-et-liens-symboliques)
6. [Procédure d'installation pas à pas](#procédure-dinstallation-pas-à-pas)
7. [Outils ignorés](#outils-ignorés)
8. [Dépannage](#dépannage)

---

## Introduction

Ce guide vous permet de configurer votre environnement de développement à partir de votre répertoire `dotfiles` **sans aucun droit d'administrateur**. Tout se fait exclusivement dans votre espace utilisateur (`%USERPROFILE%` sur Windows, `$HOME` sur Linux/WSL).

**Contexte** : Vous travaillez sur Windows avec WSL2/Linux, disposant d'un compte utilisateur standard. Vous ne pouvez donc pas :

- Installer des outils globalement (via `winget` ou gestionnaires système)
- Créer des liens symboliques sans Developer Mode
- Modifier les dossiers systèmes

**Solutions** :

- Utiliser les liens symboliques en mode utilisateur (avec Developer Mode activé sur Windows)
- Copier les configurations directement dans les emplacements utilisateur
- Sourcer les fichiers de shell localement
- Exécuter les scripts dans WSL/Linux quand nécessaire

---

## Prérequis

### Sur Windows (hôte)

1. **Developer Mode activé** (pour les liens symboliques sans admin)
   - Paramètres → Système → À propos → Options de développeur → Activer le mode Développeur

2. **Git installé** (ou Git Bash disponible)

3. **WSL2 configuré** (Bash/Zsh pour les scripts Linux)

### Sur WSL2/Linux

1. `bash` ou `zsh` disponible
2. Accès au répertoire `~/dotfiles` (copie ou lien du répertoire Windows)

---

## Cartographie des scripts compatibles

### Scripts exécutables en mode utilisateur

| Script                          | Plateforme           | Dépendances                 | Modification requise          | Notes                                    |
| ------------------------------- | -------------------- | --------------------------- | ----------------------------- | ---------------------------------------- |
| `symlink.ps1`                   | PowerShell (Windows) | Developer Mode activé       | Aucune                        | Crée les liens symboliques en user-space |
| `symlink.sh`                    | Bash/Zsh (WSL/Linux) | Aucune                      | Aucune                        | Version Linux — À exécuter dans WSL      |
| `install-vscode-extensions.ps1` | PowerShell (Windows) | VS Code CLI (`code`)        | Aucune                        | Ne nécessite pas d'admin                 |
| `push.ps1`                      | PowerShell (Windows) | Git, WSL (check-secrets.sh) | Aucune                        | Sync vers GitHub — user-space compatible |
| `check-secrets.sh`              | Bash (WSL)           | Git                         | Aucune                        | Vérification de sécurité — user-space    |
| `check-stack.sh`                | Bash (WSL)           | Docker CLI, Docker Compose  | Aucune (si Docker disponible) | Diagnostic pile applicative — user-space |

### Scripts À ÉVITER sans droits admin

| Script              | Raison                                           | Alternative                      |
| ------------------- | ------------------------------------------------ | -------------------------------- |
| `bootstrap.ps1`     | Appelle `install-tools.ps1` qui utilise `winget` | Exécutez les scripts individuels |
| `install-tools.ps1` | `winget` peut nécessiter des droits admin        | Installation portable ou WSL     |
| `update.sh`         | Peut nécessiter des droits systèmes              | Adapté pour user-space           |

---

## Configuration des IDE et Éditeurs

### 1. VS Code

#### 1.1 Copier la configuration (méthode simple)

**Localisation des fichiers utilisateur sur Windows** :

```
%APPDATA%\Code\User\
```

**Commande PowerShell** :

```powershell
# Créer le dossier utilisateur s'il n'existe pas
$VSCodeUserDir = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Path $VSCodeUserDir -Force | Out-Null

# Copier settings et keybindings
Copy-Item "$env:USERPROFILE\dotfiles\vscode\settings.json" "$VSCodeUserDir\settings.json" -Force
Copy-Item "$env:USERPROFILE\dotfiles\vscode\keybindings.json" "$VSCodeUserDir\keybindings.json" -Force

Write-Host "[OK] VS Code configuration copied to user directory"
```

#### 1.2 Créer des liens symboliques (méthode avancée)

**Avec Developer Mode activé** (Windows 10/11) :

```powershell
# Developer Mode doit être activé (voir prérequis)
$VSCodeUserDir = "$env:APPDATA\Code\User"
$DOTFILES = "$env:USERPROFILE\dotfiles"

New-Item -ItemType Directory -Path $VSCodeUserDir -Force | Out-Null

# Remplacer les fichiers existants par des liens
if (Test-Path "$VSCodeUserDir\settings.json") {
    Remove-Item "$VSCodeUserDir\settings.json" -Force
}
New-Item -ItemType SymbolicLink -Path "$VSCodeUserDir\settings.json" `
    -Value "$DOTFILES\vscode\settings.json" -Force | Out-Null

if (Test-Path "$VSCodeUserDir\keybindings.json") {
    Remove-Item "$VSCodeUserDir\keybindings.json" -Force
}
New-Item -ItemType SymbolicLink -Path "$VSCodeUserDir\keybindings.json" `
    -Value "$DOTFILES\vscode\keybindings.json" -Force | Out-Null

Write-Host "[OK] VS Code configuration linked"
```

#### 1.3 Installer les extensions VS Code

**Commande simple** (ne nécessite pas d'admin) :

```powershell
# À exécuter hors d'une session VS Code (pas de terminal intégré)
$DOTFILES = "$env:USERPROFILE\dotfiles"
$extensionsFile = "$DOTFILES\vscode\extensions.txt"

# Lire chaque ligne du fichier et installer l'extension
Get-Content $extensionsFile | Where-Object { $_.Trim() -and -not $_.StartsWith("#") } | ForEach-Object {
    $extension = $_.Trim()
    Write-Host "Installing: $extension..."
    & code --install-extension $extension --force
}

Write-Host "[OK] All extensions installed"
```

**Ou utiliser le script fourni** :

```powershell
& "$env:USERPROFILE\dotfiles\scripts\install-vscode-extensions.ps1"
```

**Récupérer les extensions actuelles** (mise à jour de la liste) :

```powershell
code --list-extensions > "$env:USERPROFILE\dotfiles\vscode\extensions.txt"
```

---

### 2. IntelliJ IDEA & IdeaVim

#### 2.1 Appliquer la configuration IdeaVim

**Localisation du fichier IdeaVim sur Windows** :

```
%USERPROFILE%\.ideavimrc
```

**Méthode 1 : Copier le fichier**

```powershell
Copy-Item "$env:USERPROFILE\dotfiles\vim\ideavimrc" `
    "$env:USERPROFILE\.ideavimrc" -Force
```

**Méthode 2 : Créer un lien symbolique**

```powershell
# Avec Developer Mode
if (Test-Path "$env:USERPROFILE\.ideavimrc") {
    Remove-Item "$env:USERPROFILE\.ideavimrc" -Force
}
New-Item -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.ideavimrc" `
    -Value "$env:USERPROFILE\dotfiles\vim\ideavimrc" -Force | Out-Null
```

#### 2.2 Importer les préférences IntelliJ

1. Ouvrir IntelliJ IDEA
2. Aller à **File → Manage IDE Settings → Import Settings**
3. Naviguer vers votre répertoire `dotfiles`
4. Sélectionner une configuration exportée (si disponible)

**Ou manuellement** :

1. **File → Settings** (ou **Preferences** sur macOS)
2. Configurer les keybindings : **Editor → Vim**
3. Charger le fichier `~/.ideavimrc` si applicable

---

### 3. Vim / Neovim

#### 3.1 Configuration Vim

**Localisation sur Windows/WSL** :

```
~/.vimrc
```

**Créer le lien** :

```bash
# Dans WSL ou Git Bash
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
```

**Ou copier directement** :

```bash
cp ~/dotfiles/vim/vimrc ~/.vimrc
```

#### 3.2 Configuration Neovim

**Structure Neovim** :

```
~/.config/nvim/
  ├── init.vim
  ├── lua/
  └── plugins/
```

**Créer le répertoire et le lien** :

```bash
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
```

**Ou créer un lien vers le dossier entier** :

```bash
ln -sf ~/dotfiles/nvim ~/.config/nvim
```

#### 3.3 Charger la configuration partagée

Votre `init.vim` inclut déjà `source ~/.vimrc`, donc une fois le lien créé, tout devrait fonctionner.

**Vérifier que Vim/Neovim charge la configuration** :

```bash
# Depuis Vim/Neovim
:set runtimepath?
:source ~/.vimrc
```

---

## Shell, Alias et Liens Symboliques

### 1. Bash (Bash sur WSL ou Git Bash Windows)

#### 1.1 Lier le fichier `.bashrc`

```bash
# Dans WSL ou Git Bash
ln -sf ~/dotfiles/shell/bashrc ~/.bashrc
```

**Vérifier le chargement** :

```bash
# Recharger le shell
source ~/.bashrc

# Afficher les alias disponibles
alias
```

#### 1.2 Ajouter le dotfiles à la variable `$PATH`

Dans `~/.bashrc`, vérifiez la ligne :

```bash
export DOTFILES="$HOME/dotfiles"
```

### 2. Zsh (Zsh sur WSL ou macOS)

#### 2.1 Lier le fichier `.zshrc`

```bash
ln -sf ~/dotfiles/shell/zshrc ~/.zshrc
```

#### 2.2 Recharger la configuration

```bash
exec zsh
# ou
source ~/.zshrc
```

### 3. PowerShell (Windows)

#### 3.1 Localiser le profil PowerShell

```powershell
# Afficher le chemin du profil actuel
$PROFILE

# Créer le dossier s'il n'existe pas
New-Item -ItemType Directory (Split-Path $PROFILE) -Force | Out-Null
```

**Emplacements typiques** :

- PowerShell 5 : `%USERPROFILE%\Documents\PowerShell\profile.ps1`
- PowerShell 7 : `%USERPROFILE%\Documents\PowerShell\profile.ps1`

#### 3.2 Lier le profil ou sourcer le fichier dotfiles

**Option A : Créer un lien symbolique**

```powershell
# Avec Developer Mode activé
$profileDir = Split-Path $PROFILE
$DOTFILES = "$env:USERPROFILE\dotfiles"

New-Item -ItemType SymbolicLink `
    -Path $PROFILE `
    -Value "$DOTFILES\shell\Microsoft.PowerShell_profile.ps1" `
    -Force | Out-Null
```

**Option B : Sourcer depuis votre profil existant**

```powershell
# Ajouter cette ligne à votre $PROFILE
. "$env:USERPROFILE\dotfiles\shell\Microsoft.PowerShell_profile.ps1"
```

#### 3.3 Recharger le profil

```powershell
# Recharger immédiatement
. $PROFILE

# Ou utiliser la fonction définie dans le profil
reload
```

### 4. Configuration Git

#### 4.1 Lier `.gitconfig`

**Sur Windows PowerShell** :

```powershell
$DOTFILES = "$env:USERPROFILE\dotfiles"
New-Item -ItemType SymbolicLink `
    -Path "$env:USERPROFILE\.gitconfig" `
    -Value "$DOTFILES\git\gitconfig" `
    -Force | Out-Null
```

**Sur WSL/Linux** :

```bash
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
```

#### 4.2 Vérifier la configuration Git

```bash
git config --list
git config user.name
git config user.email
```

### 5. Tmux (WSL/Linux uniquement)

#### 5.1 Lier `.tmux.conf`

```bash
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
```

#### 5.2 Recharger Tmux

```bash
# Depuis une session tmux existante
tmux source-file ~/.tmux.conf

# Ou redémarrer tmux
tmux kill-server
tmux new-session
```

### 6. Script automatisé pour créer tous les liens (WSL/Linux)

**Créer un fichier `~/.local/bin/link-dotfiles.sh`** :

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${HOME}/dotfiles"

# Fonction utilitaire
create_link() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "⚠ Source not found: $src"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        local backup="${dst}.backup.$(date +%s)"
        echo "  Backing up: $backup"
        mv "$dst" "$backup"
    fi

    ln -sf "$src" "$dst"
    echo "✓ Linked: $dst"
}

# Créer les liens
create_link "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
create_link "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
create_link "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
create_link "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
create_link "$DOTFILES/vim/ideavimrc" "$HOME/.ideavimrc"
create_link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
create_link "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "[OK] All symlinks created successfully"
```

**Utilisation** :

```bash
chmod +x ~/.local/bin/link-dotfiles.sh
~/.local/bin/link-dotfiles.sh
```

### 7. Alias et fonctions personnalisés

Vos fichiers de shell (`bashrc`, `zshrc`) contiennent déjà :

- Alias Git : `gs`, `gc`, `ga`, `gd`, etc.
- Alias Navigation : `..`, `la`, `ll`
- Alias Maven : `mc`, `mt`, `mp`, `ms`
- Alias Docker : `dcu`, `dcub`, `dcd`, `dcl`
- Fonctions : `mkcd`, `parse_git_branch`

**Une fois les liens créés, tout est automatiquement disponible** lors du chargement du shell.

---

## Procédure d'installation pas à pas

### Phase 1 : Préparation (Windows)

```powershell
# 1. Vérifier que Developer Mode est activé
Start-Process "ms-settings:developers"

# 2. Copier ou cloner le répertoire dotfiles
cd $env:USERPROFILE
if (-not (Test-Path "dotfiles")) {
    # Option A : Si vous avez git
    git clone <votre_repo_dotfiles> dotfiles

    # Option B : Copie manuelle depuis une source
    Copy-Item -Recurse "C:\path\to\dotfiles" "$env:USERPROFILE\dotfiles"
}

# 3. Vérifier l'existence de VS Code CLI
code --version
```

### Phase 2 : Configuration VS Code (Windows PowerShell)

```powershell
# Copier ou lier la configuration
$VSCodeUserDir = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Path $VSCodeUserDir -Force | Out-Null

# Option simple : copier
Copy-Item "$env:USERPROFILE\dotfiles\vscode\settings.json" "$VSCodeUserDir\settings.json" -Force
Copy-Item "$env:USERPROFILE\dotfiles\vscode\keybindings.json" "$VSCodeUserDir\keybindings.json" -Force

# Option avancée : lier (avec Developer Mode)
# New-Item -ItemType SymbolicLink -Path "$VSCodeUserDir\settings.json" ...

# Installer les extensions
& "$env:USERPROFILE\dotfiles\scripts\install-vscode-extensions.ps1"
```

### Phase 3 : Configuration Shell (PowerShell)

```powershell
# 1. Vérifier le profil PowerShell
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File $PROFILE -Force | Out-Null
}

# 2. Ajouter une ligne pour sourcer le profil dotfiles
$line = '. "$env:USERPROFILE\dotfiles\shell\Microsoft.PowerShell_profile.ps1"'
if (-not (Select-String -Path $PROFILE -Pattern $line -SimpleMatch)) {
    Add-Content $PROFILE $line
}

# 3. Recharger
. $PROFILE
```

### Phase 4 : Configuration WSL/Linux (dans WSL)

```bash
cd ~

# 1. Créer les liens
ln -sf ~/dotfiles/shell/bashrc ~/.bashrc
ln -sf ~/dotfiles/shell/zshrc ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
ln -sf ~/dotfiles/vim/ideavimrc ~/.ideavimrc
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.config
ln -sf ~/dotfiles/nvim ~/.config/nvim

# 2. Recharger bash/zsh
source ~/.bashrc
# ou
exec zsh

# 3. Vérifier les alias
alias
```

### Phase 5 : Configuration IDE (selon vos outils)

**IntelliJ IDEA** :

```powershell
# Depuis Windows
Copy-Item "$env:USERPROFILE\dotfiles\vim\ideavimrc" "$env:USERPROFILE\.ideavimrc" -Force
```

**Vim/Neovim** :

```bash
# Dans WSL
nvim --version  # Vérifier l'installation
vim --version
```

### Phase 6 : Vérification finale

```bash
# Depuis WSL/Linux
echo "=== Git Config ==="
git config user.name

echo "=== Aliases ==="
alias | head -10

echo "=== Editor ==="
echo $EDITOR
which vim
which nvim

echo "=== Dotfiles Path ==="
echo $DOTFILES
```

---

## Outils ignorés

### Pourquoi ces outils ne peuvent pas être installés sans droits admin

| Outil                         | Raison                                       | Workaround                                             |
| ----------------------------- | -------------------------------------------- | ------------------------------------------------------ |
| **PowerShell 7** (via winget) | `winget` peut nécessiter des droits systèmes | Utiliser PowerShell 5 (préinstallé) ou WSL             |
| **Git** (via winget)          | Nécessite installation systèmes              | Git est souvent préinstallé ou disponible via WSL      |
| **Neovim** (via winget)       | Installation globale systèmes                | Installer dans WSL ou télécharger une version portable |
| **Docker Desktop**            | Nécessite droits systèmes                    | Utiliser Docker dans WSL2 (si disponible)              |
| **pyenv-win** (via winget)    | Gestion globale des versions Python          | Utiliser WSL + pyenv natif                             |
| **Ripgrep** (via winget)      | Installation systèmes                        | Installer dans WSL ou télécharger binaire portable     |

### Installations portables (sans admin)

#### Python + Pyenv

```bash
# Dans WSL
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
eval "$(~/.pyenv/bin/pyenv init -)"
```

#### Neovim portable

```bash
# Télécharger la version AppImage
cd ~/.local/bin
wget https://github.com/neovim/neovim/releases/download/latest/nvim.appimage
chmod +x nvim.appimage
```

---

## Dépannage

### Issue 1 : "Permission denied" sur les symlinks (Windows)

**Cause** : Developer Mode n'est pas activé

**Solution** :

```powershell
# 1. Activer Developer Mode manuellement :
# Paramètres → Système → À propos → Options de développement → Mode Développeur

# 2. Ou utiliser la copie plutôt que les liens
Copy-Item "$src" "$dst" -Force
```

### Issue 2 : VS Code ne charge pas la configuration

**Cause** : Le chemin utilisateur est incorrect

**Solution** :

```powershell
# Vérifier le chemin correct
$env:APPDATA

# Copier ou lier manuellement
dir "$env:APPDATA\Code\User"
```

### Issue 3 : Les alias Bash ne se chargent pas

**Cause** : `bashrc` n'est pas sourcé au démarrage

**Solution** :

```bash
# Vérifier que ~/.bashrc est sourcé depuis ~/.bash_profile
cat ~/.bash_profile | grep bashrc

# Sinon, ajouter :
echo "[ -f ~/.bashrc ] && source ~/.bashrc" >> ~/.bash_profile
```

### Issue 4 : PowerShell profile ne se charge pas

**Cause** : ExecutionPolicy restrictive

**Solution** :

```powershell
# Vérifier la politique
Get-ExecutionPolicy

# Autoriser les scripts utilisateur (sans admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 5 : Extensions VS Code ne s'installent pas

**Cause** : VS Code CLI ne trouve pas certaines extensions offline

**Solution** :

```powershell
# Installer une par une avec feedback
code --list-extensions | ForEach-Object {
    code --install-extension $_
}

# Ou ignorer les erreurs et continuer
$extensions = Get-Content "extensions.txt"
$extensions | ForEach-Object -Continue { code --install-extension $_ }
```

### Issue 6 : Git config n'est pas reconnue

**Cause** : Le lien symbolique pointe vers le mauvais chemin

**Solution** :

```bash
# Vérifier le lien
ls -la ~/.gitconfig

# Ou utiliser la copie
cp ~/dotfiles/git/gitconfig ~/.gitconfig
```

---

## Résumé des commandes principales

### Setup complet Windows PowerShell

```powershell
# 1. Configuration VS Code
$VSCodeUserDir = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Path $VSCodeUserDir -Force | Out-Null
Copy-Item "$env:USERPROFILE\dotfiles\vscode\settings.json" "$VSCodeUserDir\settings.json" -Force
Copy-Item "$env:USERPROFILE\dotfiles\vscode\keybindings.json" "$VSCodeUserDir\keybindings.json" -Force

# 2. Extensions VS Code
& "$env:USERPROFILE\dotfiles\scripts\install-vscode-extensions.ps1"

# 3. Configuration PowerShell
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
Add-Content $PROFILE '. "$env:USERPROFILE\dotfiles\shell\Microsoft.PowerShell_profile.ps1"'
. $PROFILE
```

### Setup complet WSL/Linux

```bash
# 1. Créer les liens
ln -sf ~/dotfiles/shell/bashrc ~/.bashrc
ln -sf ~/dotfiles/shell/zshrc ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
ln -sf ~/dotfiles/vim/ideavimrc ~/.ideavimrc
mkdir -p ~/.config && ln -sf ~/dotfiles/nvim ~/.config/nvim

# 2. Recharger
source ~/.bashrc
# ou
exec zsh
```

---

## Notes supplémentaires

### Variables d'environnement importantes

```powershell
# PowerShell
$env:USERPROFILE    # Dossier utilisateur (C:\Users\YourUsername)
$env:APPDATA         # C:\Users\YourUsername\AppData\Roaming
$env:LOCALAPPDATA    # C:\Users\YourUsername\AppData\Local
$PROFILE             # Fichier profil PowerShell
```

```bash
# Bash/Zsh
$HOME                # Dossier utilisateur
~/.config            # Dossier configuration XDG (Linux)
$EDITOR              # Éditeur par défaut
```

### Maintenance régulière

```powershell
# Mettre à jour la liste des extensions VS Code
code --list-extensions | Out-File "$env:USERPROFILE\dotfiles\vscode\extensions.txt"
```

```bash
# Mettre à jour les alias depuis les fichiers shell
source ~/.bashrc
# ou
source ~/.zshrc
```

---

**Dernière mise à jour** : Mai 2026
**Auteur** : Configuration personnelle optimisée pour compte utilisateur standard
