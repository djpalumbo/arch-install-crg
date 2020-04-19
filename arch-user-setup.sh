#!/bin/bash


# Make sure WiFi network is accessible
while [[ "0%" != $(ping -c 3 8.8.8.8 | grep "packet loss" | cut -d " " -f 6) ]]
do
  echo -e "Connect to a WiFi network\n"
  wifi-menu
done


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

