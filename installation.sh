# !/bin/bash

function install_environment() {
    # Update and Upgrade System
    sudo pacman -Syu --noconfirm
    sudo pacman -S kitty zsh zsh-syntax-highlighting zsh-autosuggestions lsd bat git wget nano zip --noconfirm

    # Change default $SHELL
    sudo chsh -s /usr/bin/zsh
    sudo chsh -s /usr/bin/zsh root

    # Download Arch Linux dotfiles
    git clone https://github.com/ilyvsc/arch-linux-installation.git ~/installation

    # Setup custom .zshrc and restart SHELL
    cp ~/installation/files/.zshrc ~/.zshrc
    sudo ln -s -f ~/.zshrc /root/.zshrc

    # Install powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
    cp ~/installation/files/.p10k.zsh ~/.p10k.zsh
    sudo ln -s -f ~/.p10k.zsh /root/.p10k.zsh

    # Install zsh-sudo
    sudo mkdir /usr/share/zsh/plugins/zsh-sudo
    sudo wget -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

    # Install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; ~/.fzf/install

    # Setup Kitty terminal
    cp -rf ~/installation/files/config/kitty ~/.config/
    rm -rf ~/installation

    # Install keyrings and packages managers
    mkdir ~/.repos; cd ~/.repos
    sudo pacman -S --needed base-devel

    # Install AUR
    git clone https://aur.archlinux.org/paru.git; cd paru; makepkg -si
    paru -Syu --noconfirm

    # Install blackarch keyrings
    wget -o ~/.repos/strap.sh https://blackarch.org/strap.sh; chmod +x strap.sh; ./strap.sh
}

function install_fonts() {
    # Create and Download Fonts
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

    # Install Noto fonts
    paru -S noto-fonts --noconfirm
}

function install_apps() {
    # Install necessary applications
    paru -S 1password telegram-desktop brave-bin vivaldi visual-studio-code-bin spotify --noconfirm

    # Install extra applications
    packages="beekeeper-studio obs-studio discord slack-desktop zoom"

    # Prompt user for installation confirmation
    read -p "Do you want to install the following packages: $packages? (Y/n): " confirm

    if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]; then
        paru -S $packages --noconfirm

        echo "Packages installed successfully."
    else
        echo "Installation aborted."
    fi
}

function install_dev() {
    # Setup Git config
    git config --global user.name "Luis Diaz"
    git config --global user.email "machadodiazluis@gmail.com"
    git config --global init.defaultBranch main

    # Install Docker
    sudo pacman -S docker docker-compose --noconfirm
    paru -S docker-desktop --noconfirm
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Install Poetry
    curl -sSL https://install.python-poetry.org | python3 -

    if [ "$confirm" == "Y" ] || [ "$confirm" == "y" ]; then
        paru -S jetbrains-toolbox github-cli --noconfirm
        sudo pacman -S tree htop neofetch python python-pip --noconfirm

        echo "Development tools installed successfully."
    else
        echo "Installation aborted."
    fi
}

function install_desktop(){
    # Install desktop environment
    pacman -S gnome xorg-xprop gnome-{tweaks,browser-connector,shell-extensions} --noconfirm
    paru -S extension-manager-git --noconfirm
    systemctl enable gdm; systemctl start gdm
}

function main() {
    install_environment
    install_fonts
    install_apps
    install_dev
    install_desktop
}

main
zsh