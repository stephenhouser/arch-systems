#!/bin/bash

REPO_URL=http://github.com/stephenhouser/arch-systems
REPO_RAW=https://raw.githubusercontent.com/stephenhouser/arch-systems/master/

# MacMini6,1
hostname=workshop
disk=/dev/sda
fstype=f2fs
wire_net=enp1s0f0
configure_wifi=true
wifi_net=wlp2s0
wifi_ssid="houser"
# wifi_psk="wpa-pre-shared-key"
system_packages="broadcom-wl-dkms "
#rootpass=root
user=workshop
#password=workshop

# Boostrap Arch Linux Base
source <(curl -L ${REPO_RAW}/bootstrap/bootstrap.sh)

# Full system update and upgrade to latest rolling release!
#arch-chroot /mnt pacman -Syy --noconfirm		# update package indicies
#arch-chroot /mnt pacman -Syu --noconfirm 		# upgrade the packages.

# Custom to Workshop Machine
arch-chroot /mnt pacman -Syu --noconfirm \
	plasma konsole kcalc \
	flatpak fwupd packagekit-qt5 \
	nfs-utils samba refind \
	firefox inkscape \
	unzip wget \

arch-chroot /mnt systemctl enable sddm.service

# Enable sudo w/o password to install
sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
sed -i 's/%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

#arch-chroot /mnt su ${user} -c 'cd /tmp; git clone https://github.com/actionless/pikaur.git; cd /tmp/pikaur; makepkg -si --noconfirm'
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm f-engrave'
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm k40whisperer'

# 2023-08-27: bCNC and bCNC-git are broken in AUR 
# arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm bcnc'

# clone repo 
# copy `share` to `/usr/share`
# copy skeleton to home

# set greeter theme
# set autologin to workshop
mkdir -p /mnt/etc/sddm.conf.d
cat > /mnt/etc/sddm.conf.d/kde_settings.conf << EOF
[Autologin]
Relogin=false
User=workshop
Session=plasma

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze
CursorTheme=breeze_cursors
Font=Noto Sans,10,-2,0,50,0,0,0,0,0

[Users]
MaximumUid=65536
MinimumUid=1000
EOF

# Remove nopassword sudoer for wheel, revert
sed -i "s/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /mnt/etc/sudoers
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
