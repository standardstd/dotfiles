========================================================================
             GUIDE DE DÉMARRAGE RAPIDE : TMUX SUR WSL
========================================================================

Ce guide explique comment installer, configurer et utiliser Tmux dans un 
environnement WSL (Windows Subsystem for Linux) pour remplacer un émulat-
eur graphique comme Terminator.

------------------------------------------------------------------------
1. INSTALLATION
------------------------------------------------------------------------
Mettez à jour vos paquets et installez Tmux via le terminal Linux :

    sudo apt update && sudo apt install tmux -y


------------------------------------------------------------------------
2. LE CONCEPT CLÉ : LA TOUCHE DE PRÉFIXE ("MAGIQUE")
------------------------------------------------------------------------
Pour exécuter une action dans Tmux, vous devez TOUJOURS appuyer sur le
préfixe par défaut en premier, relâcher, puis appuyer sur la commande.

    Préfixe par défaut :  [Ctrl] + [b]


------------------------------------------------------------------------
3. RACCOURCIS DE SURVIE (LES VOLETS / PANES)
------------------------------------------------------------------------
Pour découper votre écran actuel :

    * Split Vertical (gauche/droite) : [Ctrl]+[b] puis [%]
    * Split Horizontal (haut/bas)    : [Ctrl]+[b] puis ["]
    
Pour naviguer et interagir :

    * Changer de volet : [Ctrl]+[b] puis [Flèche directionnelle]
    * Fermer un volet  : Tapez 'exit' ou faites [Ctrl]+[d] dans le volet


------------------------------------------------------------------------
4. LES ONGLETS (LES WINDOWS)
------------------------------------------------------------------------
Si votre écran est trop encombré, créez un nouvel onglet plein écran :

    * Créer un onglet        : [Ctrl]+[b] puis [c]
    * Onglet suivant         : [Ctrl]+[b] puis [n]
    * Onglet précédent       : [Ctrl]+[b] puis [p]


------------------------------------------------------------------------
5. LE SUPER-POUVOIR : DÉTACHER / RATTACHER UNE SESSION
------------------------------------------------------------------------
Vous pouvez fermer votre terminal ou Windows sans perdre vos scripts ou 
votre disposition d'écran.

Pour vous détacher (laisser tourner en arrière-plan) :
    [Ctrl]+[b] puis [d]

Pour vous rattacher (retrouver votre session plus tard) :
    Exécutez la commande : tmux a


------------------------------------------------------------------------
6. CONFIGURATION : ACTIVER LA SOURIS
------------------------------------------------------------------------
Pour pouvoir redimensionner les volets et changer de fenêtre au clic comme 
sur Terminator, exécutez cette commande unique dans votre WSL :

    echo "set -g mouse on" >> ~/.tmux.conf && tmux source-file ~/.tmux.conf

========================================================================


------------------------------------------------------------------------
7. PAR EXTRA : RENOMMER LES VOLETS DUPLIQUÉS (PANE TITLES)
------------------------------------------------------------------------
Par défaut, Tmux ne montre pas le titre des fenêtres découpées. Pour 
afficher et modifier le nom de chaque terminal dupliqué :

Étape A : Activer l'affichage des titres (Bordure haute)
    Lancez cette commande une fois dans votre Tmux :
    tmux set -g pane-border-status top

Étape B : Renommer le volet actuel via l'interface interne
    1. Faites le préfixe : [Ctrl] + [b]
    2. Appuyez sur la touche : [:]  (deux-points)
    3. Dans la barre apparue en bas, tapez textuellement :
       select-pane -T "Votre Titre"
    4. Appuyez sur [Entrée]

Étape C : Raccourci magique (Recommandé)
    Pour pouvoir renommer à la volée vos duplications avec un raccourci,
    exécutez cette commande une bonne fois pour toutes dans votre WSL :

    echo 'bind-key T command-prompt -p "Nom du volet:" "select-pane -T %%"' >> ~/.tmux.conf && tmux source-file ~/.tmux.conf

    Désormais, pour renommer n'importe quelle zone, il vous suffira de faire :
    [Ctrl] + [b] puis [Maj] + [t]
------------------------------------------------------------------------