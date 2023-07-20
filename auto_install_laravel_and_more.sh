#!/bin/bash

# Fonction pour vérifier si une commande existe
function command_exists() {
    type "$1" > /dev/null 2>&1
}

# Vérifier si WSL est installé
if ! command_exists wsl; then
  echo "Ce script doit être exécuté dans Windows Subsystem for Linux (WSL)."
  exit 1
fi

# Vérifier si le script est exécuté depuis WSL ou Windows
if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
    IS_WSL=true
else
    IS_WSL=false
fi

# Fonction pour exécuter une commande dans WSL
function run_in_wsl() {
    wsl "$@"
}

# Vérifier si Composer existe et l'installer si nécessaire
if ! command_exists composer; then
    if [ "$IS_WSL" = true ]; then
        echo "Installation de Composer sur WSL..."
        # Ajoutez ici le code pour installer Composer sur WSL.
        # Vous pouvez utiliser la commande run_in_wsl pour exécuter des commandes dans WSL depuis Windows.
    else
        echo "Ce script nécessite l'installation de Composer dans WSL."
        exit 1
    fi
fi

# Vérifier si PHP, Artisan et PHP 8.1 existent et les installer si nécessaire
if ! command_exists php || ! command_exists php8.1; then
    if [ "$IS_WSL" = true ]; then
        echo "Installation de PHP et PHP 8.1 sur WSL..."
        # Ajoutez ici le code pour installer PHP et PHP 8.1 sur WSL.
    else
        echo "Ce script nécessite l'installation de PHP et PHP 8.1 dans WSL."
        exit 1
    fi
fi

# Vérifier si npm existe et l'installer si nécessaire
if ! command_exists npm; then
    if [ "$IS_WSL" = true ]; then
        echo "Installation de npm sur WSL..."
        # Ajoutez ici le code pour installer npm sur WSL.
    else
        echo "Ce script nécessite l'installation de npm dans WSL."
        exit 1
    fi
fi

# Vérifier si MailHog existe et l'installer si nécessaire
if ! command_exists mailhog; then
    if [ "$IS_WSL" = true ]; then
        echo "Installation de MailHog sur WSL..."
        # Ajoutez ici le code pour installer MailHog sur WSL.
    else
        echo "Ce script nécessite l'installation de MailHog dans WSL."
        exit 1
    fi
fi

# Fonction pour installer les packages utiles
function install_laravel_dependencies() {
    if [ "$IS_WSL" = true ]; then
        echo "Les packages utiles seront installés sur Windows..."
        # Ajoutez ici le code pour installer les packages utiles sur Windows.
    else
        echo "Installation des packages utiles sur Linux..."
        sudo apt update
        sudo apt install -y git curl php php-mbstring php-xml php-zip unzip
    fi
}

# Fonction pour installer Laravel
function install_laravel() {
    composer global require laravel/installer
    export PATH="$PATH:$HOME/.composer/vendor/bin"
}

# Fonction pour installer des packages personnalisés via Composer
function require_packages() {
    if [ ! -z "$packages" ]; then
        composer require $packages
    fi
}

# Fonction pour démarrer les serveurs (à exécuter manuellement dans les terminaux WSL)
function start_servers() {
    echo "Pour démarrer le serveur Laravel, exécutez :"
    echo "cd $project_path"
    echo "php artisan serve"

    if [ "$start_mail_system" = "y" ]; then
        echo "Pour démarrer le serveur SMTP (mailhog), exécutez :"
        echo "cd $project_path"
        echo "mailhog"
    fi

    if [ "$start_server" = "y" ]; then
        echo "Pour démarrer Vite.js, exécutez :"
        echo "cd $project_path"
        echo "npm run dev"
    fi
}

# Récupérer le nom du projet
read -p "Entrez le nom de votre projet Laravel : " project_name

# Appeler les fonctions pour installer les dépendances et Laravel
install_laravel_dependencies
install_laravel

# Création d'un nouveau projet Laravel
cd "$HOME"
composer create-project laravel/laravel "$project_name"

# Installation de packages personnalisés via Composer
read -p "Voulez-vous installer des packages via Composer ? (y/n) : " install_packages
if [ "$install_packages" = "y" ]; then
    echo "Choisissez les packages que vous souhaitez installer en entrant les numéros séparés par des espaces :"
    echo "1. Intervention Image"
    echo "2. Laravel Debugbar"
    echo "3. Laravel UI"
    echo "4. Laravel Telescope"
    echo "5. Laravel Livewire"
    echo "6. Laravel Sanctum"
    echo "7. Laravel Socialite"
    echo "8. Laravel Excel"
    echo "9. Laravel Permissions"
    echo "10. Laravel Breeze"
    echo "11. Laravel Nova"
    echo "12. Laravel Dusk"
    echo "13. Laravel Horizon"
    echo "14. Laravel Scout"
    echo "15. Laravel Backup"

    read -p "Entrez les numéros des packages que vous souhaitez installer (séparés par des espaces) : " package_numbers
    package_names=""
    for num in $package_numbers; do
        case $num in
            1) package_names+=" intervention/image";;
            2) package_names+=" barryvdh/laravel-debugbar";;
            3) package_names+=" laravel/ui";;
            4) package_names+=" laravel/telescope";;
            5) package_names+=" livewire/livewire";;
            6) package_names+=" laravel/sanctum";;
            7) package_names+=" laravel/socialite";;
            8) package_names+=" maatwebsite/excel";;
            9) package_names+=" spatie/laravel-permission";;
            10) package_names+=" laravel/breeze";;
            11) package_names+=" laravel/nova";;
            12) package_names+=" laravel/dusk";;
            13) package_names+=" laravel/horizon";;
            14) package_names+=" laravel/scout";;
            15) package_names+=" spatie/laravel-backup";;
            *) echo "Option invalide, le package #$num sera ignoré.";;
        esac
    done
    require_packages "$package_names"
fi

# Configuration du .env
project_path="$HOME/$project_name"
cd "$project_path"
cp .env.example .env
sed -i "s/APP_NAME=Laravel/APP_NAME=$env_app_name/g" .env
sed -i "s/DB_USERNAME=homestead/DB_USERNAME=$env_db_username/g" .env
sed -i "s/DB_PASSWORD=secret/DB_PASSWORD=$env_db_password/g" .env
sed -i "s/DB_DATABASE=homestead/DB_DATABASE=$env_db_database/g" .env
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=$env_db_host/g" .env

# Lancement des serveurs
read -p "Voulez-vous démarrer les serveurs (Laravel, SMTP, Vite.js) ? (y/n) : " start_servers_option
if [ "$start_servers_option" = "y" ]; then
    read -p "Démarrer le serveur Laravel ? (y/n) : " start_server
    read -p "Démarrer le serveur SMTP (MailHog) ? (y/n) : " start_mail_system
    start_servers
fi
