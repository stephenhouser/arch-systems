#!/bin/bash

# Workshop Computer for CNC and Laser Engraving
# MacMini6,1
hostname=mini-mame
disk=/dev/sda
fstype=f2fs
system_packages="broadcom-wl-dkms "
wire_net=enp1s0f0
configure_wifi=true
wifi_net=wlp2s0
wifi_ssid="houser"
#wifi_psk=
#rootpass=
user=mame
#password=

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

arch-chroot /mnt pacman --noconfirm -S \
	xorg xorg-xinit \
	xf86-video-ati xf86-video-amdgpu xf86-video-intel xf86-video-nouveau xf86-video-fbdev \
	xorg-fonts-misc xterm xorg-mkfontdir \
	lxde \
	alsa-utils \
	fuseiso unzip

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
# Copy user skeleton, setting up desktop, screen background, etc.
arch-chroot /mnt su ${user} -c "cd ~/${REPO_NAME}/mini-mame; rsync -av ./skeleton/ ~${user}"

# Pikaur
arch-chroot /mnt su ${user} -c "cd /tmp; git clone https://github.com/actionless/pikaur.git; cd /tmp/pikaur; makepkg -si --noconfirm"

# echo ""
# echo "Unmute ALSA Audio..."
# amixer sset Master unmute
# amixer sset Master '100%'
# amixer sset Speaker unmute
# amixer sset Speaker '100%'
# amixer sset Headphone unmute
# amixer sset Headphone '100%'

# RetroArch (libretro for MAME)..."
arch-chroot /mnt bash -c "~${user}/bin/install-retroarch.sh"

# MAME
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm mame-git'
arch-chroot /mnt pacman -S --noconfirm mame

# MAME v0227 -- FOR SPECIFIC VERSION 0.227
#arch-chroot /mnt su ${user} -c '~/bin/install-mame0227.sh''

# ScummVM 
#arch-chroot /mnt su ${user} -c 'pikaur -Syu --noconfirm scummvm-git'
arch-chroot /mnt pacman -S --noconfirm scummvm scummvm-tools

# Daphne (laser disc games)..."
arch-chroot /mnt su ${user} -c "cd /tmp; git clone https://github.com/stephenhouser/arch-daphne-git.git; cd arch-daphne-git; makepkg -si --noconfirm"

# Hypseus Singe
# https://github.com/DirtBagXon/hypseus-singe
# A drop-in replacement to daphne, to play laserdisc arcade games on a PC.
arch-chroot /mnt su ${user} -c "pikaur -Syu --noconfirm hypseus-singe-git"

# Attract Mode
arch-chroot /mnt su ${user} -c "pikaur -Syu --noconfirm attract-git"

# Microsoft Windows things...
# https://wiki.archlinux.org/index.php/Wine
# wine				-- not an emulator of windoes
# winetricks		-- for setting things up easier
# wine-mono			-- .NET framework
# wine-gecko		-- Internet Explorer widgets
# lib32-alsa-lib	-- for 32-bit windows
# lib32-libpulse	-- for 32-bit windows
# lib32-mpg123		-- MP3 for wine
# lib32-giflib		-- GIF for wine
# lib32-libpng		-- PNG for wine
# Enable multilib to get wine
arch-chroot /mnt pacman --noconfirm -S \
	wine winetricks wine-mono wine-gecko \
	lib32-alsa-lib lib32-libpulse \
	lib32-mpg123 lib32-giflib lib32-libpng

# to get a cmd prompt ... $ wineconsole cmd
# winetricks windowscodecs

echo ""
echo "*** Windows Games ***"
echo ""
echo "You still need need to run 'wine' and 'winecfg' under X to configure Wine"
echo "	startx /usr/bin/wine progman"
echo "	startx /usr/bin/winecfg"
echo "and install any packages it asks to install."
echo ""

# Remove staging repo
#arch-chroot /mnt su ${user} -c 'rm -rf ~/${REPO_NAME}'

# Remove nopassword sudoer for wheel, revert
echo ""
echo "Disable ${user} sudo without a password."
sed -i "s/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /mnt/etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

# Done.
echo ""
echo "Mini-MAME setup complete. Reboot now."
echo ""
