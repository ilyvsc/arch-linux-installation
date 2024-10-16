#!/bin/bash

function install_dev() {
    sudo pacman -S python3 python-poetry rust nodejs pnpm --noconfirm

    # Install and Setup Docker Engine
    sudo pacman -S docker docker-compose --noconfirm
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    ## Manage Docker as a non-root user
    sudo usermod -aG docker $USER
    newgrp docker
}

function install_desktop() {
    sudo pacman -S gnome{,-{tweaks,browser-connector,shell-extensions}} xorg{,-{server,xprop}} \
    nvidia nvidia-{prime,settings,utils} opencl-nvidia --noconfirm
    sudo systemctl enable gdm.service

    flatpak install org.telegram.desktop org.telegram.desktop.webview com.brave.Browser \
        com.spotify.Client io.beekeeperstudio.Studio com.obsproject.Studio \
        com.discordapp.Discord -y --noninteractive
}

function install_fonts() {
    directory="/usr/local/share/fonts"

    if [ ! -d "$directory" ]; then
        sudo mkdir -p $directory
    fi

    # Install Nerd Fonts
    declare -a fonts=("Hack" "Iosevka" "Meslo")

    for font in "${fonts[@]}"; do
        sudo wget -O "$directory/$font.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/$font.zip" && \
        sudo unzip "$directory/$font.zip" -d "$directory/$font" && \
        sudo rm "$directory/$font.zip"
    done

    # Install FiraCode
    sudo wget -O "$directory/Fira_Code.zip" "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" && \
    sudo unzip "$directory/Fira_Code.zip" -d "$directory/Fira_Code" && \
    sudo rm "$directory/Fira_Code.zip"

    # Install Noto fonts for multilanguage support
    pacman -S noto-fonts noto-fonts-emoji --noconfirm

    # Cache fonts on the system
    fc-cache -f
}

install_dev
install_desktop

read -p "Do you want to install fonts on the system (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    install_fonts
fi
