#!/bin/bash


# Set the timezone
timedatectl set-timezone America/New_York
# Make time/date auto-sync
timedatectl set-ntp true


# Install yay, an AUR package manager and pacman companion
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si
cd ~
rm -rf /tmp/yay


# Install packages from the AUR
yay -S --noconfirm                                                             \
  ttf-iosevka  ttf-font-awesome-4  ttf-material-design-icons  ttf-ms-fonts     \
\
  chromium-widevine                                                            \
\


################################################################################

# Create user directories
xdg-user-dirs-update


# Use zsh instead of bash
chsh -s $(which zsh)


################################################################################

# Done!
reboot

