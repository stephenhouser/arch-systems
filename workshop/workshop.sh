#!/bin/bash

# Workshop Computer for CNC and Laser Engraving
# MacMini6,1
hostname=workshop
disk=/dev/sda
fstype=f2fs
system_packages="broadcom-wl-dkms "
wire_net=enp1s0f0
configure_wifi=true
wifi_net=wlp2s0
wifi_ssid="houser"
#wifi_psk=
#rootpass=
user=workshop
#password=

# Boostrap Arch Linux Base
# Name of the repo (in GitHub) to pull from
REPO_NAME=system-setup
REPO_URL=http://github.com/stephenhouser/${REPO_NAME}.git
REPO_RAW=https://raw.githubusercontent.com/stephenhouser/${REPO_NAME}/master/
source <(curl -L ${REPO_RAW}/arch-bootstrap/bootstrap.sh)

# Custom to Workshop Machine
# KDE Plasma Desktop with Dolphon, Konsole, kCalc
# Firefox web browser
# Inkscape for design editing
# NFS to connect to shared volumes
# Wine for carbide create and carbide motion (shapeoko CNC)
arch-chroot /mnt pacman -Syu --noconfirm \
	plasma konsole kcalc dolphin \
	flatpak fwupd packagekit-qt5 \
	nfs-utils samba refind \
	firefox inkscape code \
	unzip wget wine

# Enable SDDM greeter with autologin as workshop user
arch-chroot /mnt systemctl enable sddm.service

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

# Mount Shared network volumes
cat >> /mnt/etc/fstab <<- EOF
	# Shared Network Volumes
	# sahmaxi.lan:/home/houser	/home/houser/.nfs	nfs	defaults	0 0
	sahmaxi.lan:/srv/shared		/srv/shared		nfs	defaults	0 0
	sahmaxi.lan:/srv/public		/srv/public		nfs	defaults	0 0
EOF

# Enable sudo w/o password to install, will revert later in script
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

# Clone this repo to build and install local packages and skeleton
arch-chroot /mnt su ${user} -c "cd ~; git clone --depth=1 ${REPO_URL}"
# Copy user skeleton, setting up desktop, screen background, etc.
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/workshop; rsync -av ./skeleton/ ~${user}"

# Pikaur (not used)
#arch-chroot /mnt su ${user} -c "cd /tmp; git clone https://github.com/actionless/pikaur.git; cd /tmp/pikaur; makepkg -si --noconfirm"

# F-Engrave
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm f-engrave'
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/workshop/f-engrave; makepkg -si --noconfirm"

# K40 Whisperer
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm k40whisperer'
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/workshop/k40_whisperer; makepkg -si --noconfirm"

# bCNC -- 2023-08-27: bCNC and bCNC-git are broken in AUR 
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm bcnc'
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/workshop/bCNC; makepkg -si --noconfirm"
arch-chroot /mnt su ${user} -c "pipx install bCNC"

# Carbide Create and Carbide Motion use wine
arch-chroot /mnt su ${user} -c "curl -LO https://carbide-downloads.website-us-east-1.linodeobjects.com/cm/stable/618/CarbideMotion-618.exe"
arch-chroot /mnt su ${user} -c "curl -LO https://carbide-downloads.website-us-east-1.linodeobjects.com/cc/stable/757/CarbideCreate-757.exe"

# Remove staging repo
#arch-chroot /mnt su ${user} -c 'rm -rf ~/${REPO_NAME}'

# Remove nopassword sudoer for wheel, revert
sed -i "s/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

# Done.
echo ""
echo "Workshop setup complete. Reboot now."
echo ""
