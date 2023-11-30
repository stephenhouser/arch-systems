#!/bin/bash

# Mini Arcade Computer for Playing MAME and Arcade Games
# MacMini6,1
hostname=mini-mame
disk=/dev/sda
fstype=f2fs
system_packages="broadcom-wl-dkms "
wire_net=enp1s0f0
configure_wifi=true
wifi_net=wlp2s0
wifi_ssid="houser"
#wifi_psk= -- entered as part of setup in bootstrap
#rootpass= -- entered as part of setup in bootstrap
user=mame
#password= -- entered as part of setup in bootstrap

# Boostrap Arch Linux Base
# Name of the repo (in GitHub) to pull from
REPO_NAME=system-setup
REPO_URL=https://github.com/stephenhouser/${REPO_NAME}.git
REPO_RAW=https://raw.githubusercontent.com/stephenhouser/${REPO_NAME}/master/
source <(curl -L ${REPO_RAW}/arch-bootstrap/bootstrap.sh)

# Base system tools
# xorg				-- X windows
# xorg-xinit		-- xinit and startx
# xorg-fonts-misc	-- we need some basic fonts for X11
# xterm				-- you need some sort of terminal
# alsa-utils		-- audio drivers
# pulseaudio		-- for more complex than alsa <<- Don't use any longer
# fuseiso			-- Enable user mounting of ISO images
# lxde				-- lightweight window manager

# Enable multilib 32-bit binaries (for Wine)
# update package indicies
cp /mnt/etc/pacman.conf /tmp/pacman.conf
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /tmp/pacman.conf > /mnt/etc/pacman.conf
arch-chroot /mnt pacman -Syy --noconfirm

# Audio and general utils
arch-chroot /mnt pacman --noconfirm -S \
	alsa-utils \
	fuseiso unzip xdialog

# Xorg
arch-chroot /mnt pacman --noconfirm -S \
	xorg xorg-xinit \
	xf86-video-ati xf86-video-amdgpu xf86-video-intel xf86-video-nouveau xf86-video-fbdev \
	xorg-fonts-misc xterm xorg-mkfontdir \
	openbox
	# removed: lxde

# Wayland, not quite where I want it to be.
# arch-chroot /mnt pacman --noconfirm -S \
# 	wayland hyprland \
# 	kitty

# Enable automatic login to the console
# https://wiki.archlinux.org/index.php/Getty
mkdir -p /mnt/etc/systemd/system/getty@tty1.service.d
cat >> /mnt/etc/systemd/system/getty@tty1.service.d/override.conf <<- EOF
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin ${user} --noclear %I $TERM
EOF

# Enable sudo w/o password to install, will revert later in script
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers

# Clone this repo to build and install local packages and skeleton
arch-chroot /mnt su ${user} -c "cd ~; git clone --depth=1 ${REPO_URL}"
TOOLS="~${user}/${REPO_NAME}/${hostname}/tools"

# Copy user skeleton, setting up desktop, screen background, etc.
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/mini-mame; rsync -av ./skeleton/ ~${user}"

# Pikaur
arch-chroot /mnt su ${user} -c "cd /tmp; git clone https://github.com/actionless/pikaur.git; cd /tmp/pikaur; makepkg -si --noconfirm"

# RetroArch (libretro for MAME)..."
arch-chroot /mnt su ${user} -c "${TOOLS}/install-retroarch.sh"

# MAME
arch-chroot /mnt su ${user} -c "${TOOLS}/install-mame.sh"

# MAME v0227 -- FOR SPECIFIC VERSION 0.227
# Disabled as this takes a *long* time
#arch-chroot /mnt su ${user} -c "${TOOLS}/install-mame0227.sh"

# ScummVM 
arch-chroot /mnt su ${user} -c "${TOOLS}/install-scummvm.sh"

# Daphne (laser disc games)..."
arch-chroot /mnt su ${user} -c "${TOOLS}/install-daphne.sh"

# Hypseus Singe
arch-chroot /mnt su ${user} -c "${TOOLS}/install-hypseus-singe.sh"

# Wine for windows games (future)
arch-chroot /mnt su ${user} -c "${TOOLS}/install-wine.sh"

# Attract Mode
arch-chroot /mnt su ${user} -c "${TOOLS}/install-attract-mode.sh"

# Remove staging repo
#arch-chroot /mnt su ${user} -c 'rm -rf ~/${REPO_NAME}'

# echo ""
# echo "Unmute ALSA Audio..."
# amixer sset Master unmute
# amixer sset Master '100%'
# amixer sset Speaker unmute
# amixer sset Speaker '100%'
# amixer sset Headphone unmute
# amixer sset Headphone '100%'

# Remove nopassword sudoer for wheel, revert
echo ""
echo "Disable ${user} sudo without a password."
sed -i "s/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers


echo ""
echo "Setup startup..."

# Non-graphical -- we start X by ourselves
arch-chroot /mnt systemctl set-default multi-user.target

[ -d /sys/firmware/efi ] && firmware=UEFI || firmware=BIOS

# Set systemd-boot to boot our entry
if [ "${firmware}" == "UEFI" ]; then
	cat >> /mnt/boot/loader/entries/mini-mame.conf <<- EOF
		title   Mini Mame
		linux   /vmlinuz-linux
		initrd  /intel-ucode.img
		initrd  /initramfs-linux.img
		options root=${part_root} rw quiet splash
	EOF

	cat >> /mnt/boot/loader/loader.conf <<- EOF
		default mini-mame.conf
		timeout 1
		console-mode auto
		editor yes
	EOF
fi

# Done.
cat /tmp/bootstrap.txt

echo ""
echo "Mini-MAME setup complete. Reboot now."
echo ""

