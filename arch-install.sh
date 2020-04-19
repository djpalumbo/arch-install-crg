#!/bin/bash


# Remove boot files if previous install
rm /mnt/boot/vmlinuz-linux
rm /mnt/boot/intel-ucode.img


# Make sure WiFi network is accessible
while [[ "0%" != $(ping -c 3 8.8.8.8 | grep "packet loss" | cut -d " " -f 6) ]]
do
  echo -e "Connect to a WiFi network\n"
  wifi-menu
done


# Sync database, update keyring, and update pacman mirrorlist
pacman -Sy
pacman -S --noconfirm archlinux-keyring reflector
reflector --verbose --country 'United States' --sort rate --save /etc/pacman.d/mirrorlist


# Install packages
pacstrap -i /mnt --noconfirm                                                   \
  base  base-devel                                                             \
\
  linux-headers                                                                \
\
  reflector                                                                    \
\
  wget                                                                         \
\
  efibootmgr  intel-ucode  exfat-utils                                         \
\
  tlp                                                                          \
\
  wpa_supplicant  dialog  wireless_tools                                       \
  networkmanager  network-manager-applet                                       \
  dhclient  gnome-keyring                                                      \
  networkmanager-openconnect                                                   \
\
  xorg-server  xorg-xinit  xorg-xprop  mesa                                    \
  xf86-video-intel                                                             \
\
  libinput  xf86-input-libinput  xf86-input-synaptics                          \
  xorg-xinput  xorg-xev                                                        \
  xclip                                                                        \
\
  pulseaudio  pulseaudio-alsa  pavucontrol  alsa-utils                         \
  blueman  pulseaudio-bluetooth  bluez  bluez-libs  bluez-utils                \
\
  tree                                                                         \
  htop  powertop                                                               \
\
  git  hub                                                                     \
  termite  zsh                                                                 \
  neovim                                                                       \
  ranger                                                                       \
\
  xdg-user-dirs                                                                \
\
  chromium                                                                     \
  pepper-flash                                                                 \
\
  libreoffice                                                                  \
\
  p7zip                                                                        \
\
  audacity                                                                     \
  gimp                                                                         \
\
  parted  gparted                                                              \
\
  neofetch                                                                     \
\


# Generate mount configuration file
genfstab -U -p /mnt > /mnt/etc/fstab


# Switch from USB to Arch root on your system
wget https://raw.githubusercontent.com/djpalumbo/arch-install-crg/master/arch-setup.sh
mv arch-setup.sh /mnt/
chmod +x /mnt/arch-setup.sh
arch-chroot /mnt ./arch-setup.sh

