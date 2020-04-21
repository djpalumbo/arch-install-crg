#!/bin/bash


# Remove boot files if previous install
rm /mnt/boot/vmlinuz-linux
rm /mnt/boot/intel-ucode.img


# Sync database, update keyring, and update pacman mirrorlist
pacman -Sy
pacman -S --noconfirm archlinux-keyring  reflector
reflector --verbose --country 'United States' --sort rate --save /etc/pacman.d/mirrorlist


# Install packages
pacstrap -i /mnt --noconfirm                                                   \
  base  linux  linux-firmware                                                  \
\
  linux-headers                                                                \
\
  reflector                                                                    \
\
  wget                                                                         \
\
  grub  intel-ucode  exfat-utils                                               \
\
  tlp                                                                          \
\
  xf86-video-nouveau                                                           \
  xorg-server  xorg-xinit  xorg-xprop  mesa                                    \
\
  libinput  xf86-input-libinput  xf86-input-synaptics                          \
  xorg-xinput  xorg-xev                                                        \
  xclip                                                                        \
\
  pulseaudio  pulseaudio-alsa  pavucontrol  alsa-utils                         \
\
  plasma-meta                                                                  \
\
  tree                                                                         \
  htop  powertop                                                               \
\
  git  hub                                                                     \
  termite  zsh                                                                 \
  neovim                                                                       \
  ranger                                                                       \
\
  p7zip                                                                        \
\
  xdg-user-dirs                                                                \
\
  chromium                                                                     \
  libreoffice                                                                  \
  audacity                                                                     \
  gimp                                                                         \
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

