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
	plasma konsole kcalc dolphin \
	flatpak fwupd packagekit-qt5 \
	nfs-utils samba refind \
	firefox inkscape \
	unzip wget

arch-chroot /mnt systemctl enable sddm.service

# set greeter theme
# set autologin to workshop
mkdir -p /mnt/etc/sddm.conf.d
cat > /mnt/etc/sddm.conf.d/kde_settings.conf <<- EOF
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

cat >> /mnt/etc/fstab <<- EOF
	# Shared Network Volumes
	# sahmaxi.lan:/home/houser	/home/houser/.nfs	nfs	defaults	0 0
	sahmaxi.lan:/srv/shared		/srv/shared		nfs	defaults	0 0
	sahmaxi.lan:/srv/public		/srv/public		nfs	defaults	0 0
EOF

# Enable sudo w/o password to install
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

# Pikaur
#arch-chroot /mnt su ${user} -c 'cd /tmp; git clone https://github.com/actionless/pikaur.git; cd /tmp/pikaur; makepkg -si --noconfirm'

# Local Packages to build and install
arch-chroot /mnt su ${user} -c 'git clone --depth=1 https://github.com/stephenhouser/arch-systems.git'

# F-Engrave
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm f-engrave'
arch-chroot /mnt su ${user} -c 'cd arch-systems/workshop/f-engrave; makepkg -si --noconfirm'

# K40 Whisperer
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm k40whisperer'
arch-chroot /mnt su ${user} -c 'cd arch-systems/workshop/k40_whisperer; makepkg -si --noconfirm'

# bCNC -- 2023-08-27: bCNC and bCNC-git are broken in AUR 
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm bcnc'
arch-chroot /mnt su ${user} -c 'cd arch-systems/workshop/bCNC; makepkg -si --noconfirm'

# Copy user skeleton, setting up desktop, screen background, etc.
arch-chroot /mnt su ${user} -c 'cd arch-systems/workshop; rsync -av ./skeleton/ ~${user}'

# Remove staging repo
#arch-chroot /mnt su ${user} -c 'rm -rf arch-systems'

# Remove nopassword sudoer for wheel, revert
sed -i "s/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

# Done.
echo ""
echo "Workshop setup complete. Reboot now."
echo ""
