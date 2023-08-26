#!/bin/bash
# Script to install mini-mame arcade cabinet with (minimal) Arch Linux.
#
# This assumes you have run the `arch-bootstrap.sh` script prior to this
# and have a working (networked) base system.
#
# 2020/12/31 - Stephen Houser <stephenhouser@gmail.com>
#

# consider packages
# from libretro
# bluez-libs-5.55-1 bluez-libs-5.55-1  enet-1.3.16-1  fmt-7.1.3-1  libzip-1.7.3-1  mbedtls-2.16.7-1 miniupnpc-2.1.20191224-3  minizip-1:1.2.11-4  snappy-1.1.8-2

game_user=mame

# If I am *not* the mame user, create the *mame* user and run as them.
if [ "${USER}" != "${game_user}" ]; then
	if $(whiptail --yesno "You are not ${game_user}. Continue anyway?" 0 0); then
		:	# simply continues after the if...
	else
		exit 0
	fi
fi

# Get ourselves root via sudo if we are not running with sudo already...
# if [[ "$EUID" != 0 ]]; then
# 	ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
# 	sudo ${ABSOLUTE_PATH}
# 	exit 1
# fi

# Full system update and upgrade to latest rolling release!
sudo pacman -Syy --noconfirm		# update package indicies
sudo pacman -Syu --noconfirm 		# upgrade the packages.

# Base system tools
# xorg				-- X windows
# xorg-xinit		-- xinit and startx
# xorg-fonts-misc	-- we need some basic fonts for X11
# xterm				-- you need some sort of terminal
# alsa-utils		-- audio drivers
# pulseaudio		-- for more complex than alsa <<- Don't use any longer
# fuseiso			-- Enable user mounting of ISO images
# lxde				-- lightweight window manager
sudo pacman --noconfirm -S \
	xorg xorg-xinit \
	xf86-video-ati xf86-video-amdgpu xf86-video-intel xf86-video-nouveau xf86-video-fbdev \
	xorg-fonts-misc xterm xorg-mkfontdir \
	lxde \
	alsa-utils \
	fuseiso

echo ""
echo "Unmute ALSA Audio..."
amixer sset Master unmute
amixer sset Master '100%'
amixer sset Speaker unmute
amixer sset Speaker '100%'
amixer sset Headphone unmute
amixer sset Headphone '100%'

# lwm				-- super tiny window manager that only managers windows!
# xorg-twm			-- minimal window manager
# fbdia				-- display images on the console framebuffer
#	fbdia

# Was experimenting with CDEmu. Don't seem to need it (yet)
# vhba-module 	-- emulates SCSI devices (for CDEmu)
# cdemu-clinet	-- emulates real CD drives with ISO images
#pacman --noconform -S cdemu-client vhba-module
#systemctl enable cdemu-daemon.service


echo ""
echo "Install and configure RetroArch (MAME)..."
# Mutliple Arcade Machine Emulator via RetroArch
# mame				-- the emulator; use this just to have a mame exe around
# retroarch			-- frontend and CLI for libretro and launching cores
# libretro-core-info	-- needed by retroarch to run cores
# libretro-overlays		-- graphic overlays
# retroarch-assets-xmb	-- graphic elements of retroarch UI

# Install RetroArch -- really for libretro and the "cores" that will allow
# running earlier versions of MAME arcade games. This is just a very
# basic install as I don't use the frontend of RetroArch, I just want the
# ability to use it to launch the libretro-mame games and get the nice
# benefits of libretro.
sudo pacman -S --noconfirm \
	retroarch libretro-core-info libretro-overlays retroarch-assets-ozone

# Run one time to get the template configuration setup
#sudo retroarch
# Change some retroarch settings to my liking
#sed -i 's|menu_show_core_updater = "false"|menu_show_core_updater = "true"|' ~/.config/retroarch/retroarch.cfg
# Leave audio as pulse otherwise I get no sound in games when launching from attract mode as X manager
#sed -i 's|audio_driver = "pulse"|audio_driver = "alsa"|' ~/.config/retroarch/retroarch.cfg
#sed -i 's|video_threaded = "false"|video_threaded = "true"|' ~/.config/retroarch/retroarch.cfg
#sed -i 's|video_fullscreen = "false"|video_fullscreen = "true"|' ~/.config/retroarch/retroarch.cfg

# Make directory for libretro cores (not created by default)
sudo mkdir /usr/lib/libretro
sudo chgrp wheel /usr/lib/libretro
sudo chmod g+ws /usr/lib/libretro

# Download MAME 2000, MAME 2003+, and MAME 2010 cores for RetroARch / LibRetro
function download_core() {
	cd /usr/lib/libretro
	rm -f ${1}
	wget http://buildbot.libretro.com/nightly/linux/x86_64/latest/${1}_libretro.so.zip && unzip ${1}_libretro.so.zip && rm ${1}_libretro.so.zip
	cd -
}

download_core mame2000
download_core mame2003
download_core mame2003_plus
download_core mame2010
#download_core mame2015	# not available in latest build (url above)
#download_core mame2016 # not available in latest build (url above)
#download_core mame		# not available in latest build (url above)
download_core scummvm
download_core fbneo

echo ""
echo "*** RetroArch Games ***"
echo ""
echo "It would be a really good idea to run RetroArch and update assets and such"
echo "    startx /usr/bin/retroarch"
echo ""

echo ""
echo "Install AUR source packages..."
mkdir -p src

# Install/build MAME from AUR -- USE SPECIFIC VERSION 0.227
echo ""
echo "Install Current MAME (arcade games)..."
sudo pacman -S --noconfirm mame
# git clone https://aur.archlinux.org/mame-git.git ~/src/mame
# cd ~/src/mame
# sed -i 's|https://github.com/mamedev/mame.git|https://github.com/mamedev/mame.git#tag=mame0227|' PKGBUILD
# makepkg -si
# cd -

# Install/build ScummVM from AUR
echo ""
echo "Install Current ScummVM (windows games)..."
sudo pacman -S --noconfirm scummvm scummvm-tools
# git clone https://aur.archlinux.org/scummvm-git.git ~/src/scummvm
# cd ~/src/scummvm
# sed -i 's|https://github.com/mamedev/mame.git|https://github.com/mamedev/mame.git#tag=mame0227|' PKGBUILD
# makepkg -si
# cd -


# Install/build attract mode from AUR
# Uses git://github.com/DavidGriffith/daphne.git
echo ""
echo "Install Daphne (laser disc games)..."
git clone https://github.com/stephenhouser/arch-daphne-git.git ~/src/daphne
cd ~/src/daphne
makepkg -si --noconfirm
cd -

# Install/build attract mode from AUR
echo ""
echo "Install Attract Mode (menu frontend for launching games)..."
git clone https://aur.archlinux.org/attract-git.git ~/src/attract
cd ~/src/attract
makepkg -si --noconfirm
cd -

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
echo ""
echo "Updating system... (adding multilib for Wine)..."
sudo cp /etc/pacman.conf /etc/pacman.conf.bak
awk '/^#\[multilib\]$/ {sub("#",""); print; getline; sub("#",""); print; next;} 1' < /etc/pacman.conf > /tmp/pacman.conf.$$
sudo mv /tmp/pacman.conf.$$ /etc/pacman.conf

sudo pacman -Syy --noconfirm		# update package indicies

sudo pacman --noconfirm -S \
	wine winetricks wine-mono wine-gecko \
	lib32-alsa-lib lib32-libpulse \
	lib32-mpg123 lib32-giflib lib32-libpng

# to get a cmd prompt ... $ wineconsole cmd
# winetricks windowscodecs

# Using old Kids-MAME Windows directory...
# Mount Windwos partition to /media/windows
# mkdir -p /media/windows
# echo "# Mount WindowsXP Partition" >> /etc/fstab
# echo "/dev/sda1		/media/windows		ntfs	ro	0 2" >> /etc/fstab

echo ""
echo "*** Windows Games ***"
echo ""
echo "You still need need to run 'wine' and 'winecfg' under X to configure Wine"
echo "	startx /usr/bin/wine progman"
echo "	startx /usr/bin/winecfg"
echo "and install any packages it asks to install."
echo ""


# Copy in dot files *after* everything else so we can overlay our
# configs onto the default ones created above...
echo ""
echo "Setup dot files..."
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#cd ${dir}
rsync -avz ./skeleton/ ${HOME}

cat >> ${HOME}/.zshrc << EOF
alias vi=vim
#alias ls='ls --color=auto'

if [ -d "\${HOME}/bin" ] ; then
        PATH="\${HOME}/bin:$PATH"
fi

if [ -z "\${DISPLAY}" ] && [ -n "\${XDG_VTNR}" ] && [ "\${XDG_VTNR}" -eq 1 ]; then
	exec /usr/bin/startx -- -nocursor
fi
EOF

echo ""
echo "Setting autologin account..."
# Enable automatic login to the console
# https://wiki.archlinux.org/index.php/Getty
echo ""
echo "Enable auto-login as ${USER}..."
cat >> /tmp/override.conf.$$ << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin ${USER} --noclear %I $TERM
EOF
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo mv /tmp/override.conf.$$ /etc/systemd/system/getty@tty1.service.d/override.conf
