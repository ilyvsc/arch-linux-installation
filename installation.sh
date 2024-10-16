#!/bin/bash

function partition_disks() {
    # TODO: make it dynamic
    lsblk -f /dev/nvme0n1

    echo "You need to partition the disks now."
    echo "Please use `cfdisk` to partition the disk. When you are finished, press Enter to continue."

    cfdisk /dev/nvme0n1

    read -p "Press Enter to continue with the installation process after partitioning is complete..."

    mkfs.fat -F32 -n "UEFI" /dev/nvme0n1p1
    mkfs.btrfs -f -L "root" -R free-space-tree -n 32k /dev/nvme0n1p2
}

function install_arch_system() {
    partition_disks

    mount /dev/nvme0n1p2 /mnt
    mount /dev/nvme0n1p1 /mnt/efi

    pacstrap /mnt base{,-devel} linux{,-{headers,firmware}} grub os-prober efibootmgr \
    ntfs-3g nano gvfs-{mtp,afc,gphoto2} xdg-user-dirs intel-ucode amd-ucode usbutils openresolv

    genfstab -U /mnt >> /mnt/etc/fstab
    arch-chroot /mnt

    # Localization
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf

    # Network
    echo arch > /etc/hostname

    HOSTS="""
    127.0.0.1    localhost
    ::1          localhost
    127.0.1.1    arch.localdomain   arch
    """
    echo "$HOSTS" > /etc/hosts

    # Recreate images and install grub bootloader
    echo "Recreating initramfs images..."
    mkinitcpio -p

    echo "Installing GRUB bootloader..."
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id='Arch Linux'

    read -p "Do you want to detect any OS installed on other partitions? (y/N)? " detect_os

    if [[ "$detect_os" =~ ^[Yy]$ ]]; then
        GRUB_FILE="/etc/default/grub"
        sudo cp "$GRUB_FILE" "$GRUB_FILE.bak"

        if grep -q '^#GRUB_DISABLE_OS_PROBER' "$GRUB_FILE"; then
            echo "Uncommenting 'os-prober' option..."
            sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' "$GRUB_FILE"
        else
            echo "'os-prober' option already uncommented."
        fi
        echo "Updating GRUB configuration to detect other operating systems..."
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "Skipping GRUB configuration update for detecting other operating systems."
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

    # Define groups and users
    read -p "Enter the username to create: " username
    GROUPS="power,wheel,storage,input,video,audio"
    SHELL="/bin/bash"

    if useradd -mG $GROUPS -s $SHELL "$username"; then
        echo "User '$username' created and added to groups: $GROUPS"
    else
        echo "Failed to create user '$username'."
        return 1
    fi

    if passwd "$username"; then
        echo "Password set for user '$username'."
    else
        echo "Failed to set password for user '$username'."
        return 1
    fi
}

function install_environment() {
    # Update and Upgrade System
    sudo pacman -Sy --needed archlinux-keyring && sudo pacman -Su --noconfirm

    # Install blackarch keyrings
    read -p "Do you want to install the BlackArch Keyrings? (y/N): " blackarch
    if [[ "$blackarch" =~ ^[Yy]$ ]]; then
        wget -o ~/.repos/strap.sh https://blackarch.org/strap.sh && chmod +x strap.sh && sudo ./strap.sh
    fi

    sudo pacman -S git wget zip openssh lsd bat fzf \
        zsh zsh-syntax-highlighting zsh-autosuggestions --noconfirm

    # Setup custom .zshrc and restart SHELL
    cp ~/installation/files/.zshrc ~/.zshrc && \
    sudo ln -s -f ~/.zshrc /root/.zshrc

    # Install zsh-sudo plugin from ohmyzsh
    sudo mkdir /usr/share/zsh/plugins/zsh-sudo
    sudo wget -O /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

    # Change default $SHELL
    chsh -s /usr/bin/zsh $USER
    sudo chsh -s /usr/bin/zsh root

    mkdir ~/.repos && cd ~/.repos

    # Install `paru-git`
    git clone https://aur.archlinux.org/paru-git.git && cd paru-git && makepkg -si
    paru -Syu --noconfirm
}

bash ./wifi.sh
if [ $? -eq 0 ]; then
    install_arch_system
    install_environment
fi
