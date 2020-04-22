#!/bin/bash


# Enable hibernation (passing kernel parameters thru GRUB)
swappart=$(lsblk | grep "SWAP" | cut -d " " -f 1 | sed "s/.*s/s/g")
sed -i -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash resume=UUID=$(blkid /dev/$swappart | cut -d '"' -f 2)\"/g" /etc/default/grub
# Configure the initramfs
sed -i -e "s/^HOOKS.*/HOOKS=\"base udev resume keyboard autodetect modconf block fsck filesystems\"/g" /etc/mkinitcpio.conf
# Rebuild the initramfs
mkinitcpio -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img


# Set up the boot loader (GRUB) ‒ note: this system uses GPT
grub-install --target=i386-pc /dev/sda
echo -e "menuentry \"Reboot\" {
	echo \"System rebooting...\"
	reboot
}\n
menuentry \"Shutdown\" {
	echo \"System shutting down...\"
	halt
}" > /etc/grub.d/40_custom
grub-mkconfig -o /boot/grub/grub.cfg


# Set the root password
echo "Let's set the root password."
read -s -p "New password: " password; echo
read -s -p "Again, please: " password2; echo -e "\n"
while [[ $password != $password2 ]] ; do
  echo "The passwords do not match. Please, try again."
  read -s -p "New password: " password; echo
  read -s -p "Again, please: " password2; echo -e "\n"
done
echo "root:$password" | chpasswd
echo -e "The root password has been set.\n"


# Create user
echo "Now we'll create a new user."
read -p "What will be your user's name? " username
confirm=n
while [[ $confirm != y && $confirm != Y ]]; do
  read -p "'$username'? Is that right? (y/n) " confirm
  if [[ $confirm != y && $confirm != Y ]]; then
    echo; read -p "What's your username? " username
  fi
done
useradd -m -g users -G wheel,storage,power -s /bin/bash $username
read -s -p "New password for $username: " password; echo
read -s -p "Again, please: " password2; echo -e "\n"
while [[ $password != $password2 ]] ; do
  echo "Sorry, try again."
  read -s -p "New password for $username: " password; echo
  read -s -p "Again, please: " password2; echo -e "\n"
done
echo "$username:$password" | chpasswd
echo -e "User '$username' has been created.\n"


# Allow members of 'wheel' group to use sudo
sed -i -e "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers


# Set the locale
sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo -e "LANG=\"en_US.UTF-8\"\nLC_ALL=\"en_US.UTF-8\"" > /etc/environment


# Create a hook for every time pacman-mirrorlist upgrades
mkdir -p /etc/pacman.d/hooks/
echo -e "[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist\n
[Action]
Description = Updating pacman-mirrorlist with reflector and removing pacnew...
When = PostTransaction
Depends = reflector
Exec = /bin/sh -c \"reflector --country 'United States' --latest 200 --age 24 --sort rate --save /etc/pacman.d/mirrorlist; rm -f /etc/pacman.d/mirrorlist.pacnew\"" \
  > /etc/pacman.d/hooks/mirrorupgrade.hook


# Change the hostname; configure hosts file
echo "crgdesktop" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1	crgdesktop.localdomain	crgdesktop" >> /etc/hosts


# Make sure everything is up to date
pacman -Syu


################################################################################


# Enable the multilib repository for pacman
multilib=$(awk "/\#\[multilib\]/{ print NR; exit }" /etc/pacman.conf)
sed -i -e "$multilib s/\#//g" /etc/pacman.conf
sed -i -e "$((multilib+1)) s/\#//g" /etc/pacman.conf
# Enable color option for pacman
sed -i -e "s/#Color/Color/g" /etc/pacman.conf


# Limit the amount of logs retained by systemd/journalctl to 64M
sed -i -e "s/#SystemMaxUse=/SystemMaxUse=64M/g" /etc/systemd/journald.conf


# Start certain daemons on boot
systemctl enable tlp.service
systemctl enable tlp-sleep.service


# Mask certain systemd services so that TLP power management works correctly
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket


################################################################################

# Switch from root to user
wget https://raw.githubusercontent.com/djpalumbo/arch-install-crg/master/arch-user-setup.sh
chmod +x arch-user-setup.sh
su $username -c ./arch-user-setup.sh

