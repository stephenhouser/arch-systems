#!/bin/bash
# Script to install additional emulated systems with (minimal) Arch Linux.
#
# This assumes you have run the `setup-mini-mame.sh` script prior to this
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

# Add some libRetro systems...
function download_core() {
	cd /usr/lib/libretro
	rm -f ${1}
	wget http://buildbot.libretro.com/nightly/linux/x86_64/latest/${1}_libretro.so.zip && unzip ${1}_libretro.so.zip && rm ${1}_libretro.so.zip
	cd -
}

download_core stella		# Atari 2600
download_core atari800
download_core fbneo			# FinalBurn Neo (MAME clone)
download_core vice_x64		# Commodore 64 (fast/accurate)
download_core vice_x64sc	# Commodore 64 SuperCPU
download_core dosbox_core	# DOSBox
download_core dosbox_pure	# DOSBox
download_core bnes			# Nintendo Entertainment System (bNES)
download_core quicknes		# Nintendo Entertainment System (bNES)
#download_core ffmpeg		# Videos

#
# Bluetooth for Wiimote as lightgun
#
# https://wiki.archlinux.org/index.php/XWiimote#Connect_the_Wii_Remote
sudo pacman --noconfirm -S bluez bluez-utils bluez-plugins
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Turn on and pair the one Wiimote I have
bluetoothctl agent on
bluetoothctl power on
#bluetoothctl devices
#bluetoothctl scan on
bluetoothctl pair 00:1B:7A:04:65:28
bluetoothctl trust 00:1B:7A:04:65:28
bluetoothctl connect 00:1B:7A:04:65:28

git clone https://aur.archlinux.org/xwiimote-git ~/src/
cd ~/src/xwiimote-git
makepkg --noconfirm -si
cd -

# Xorg driver
git clone https://aur.archlinux.org/xf86-input-xwiimote-git ~/src/
cd ~/src/xf86-input-xwiimote-git
makepkg --noconfirm -si
cd -

# Ask driver to use the IR sensor for mouse like motions...
# Add 'Option  "MotionSource"  "ir"' to /etc/X11/xorg.conf.d/60-xwiimote.conf

# Section "InputClass"
#         Identifier "Nintendo Wii Remote"
#         MatchProduct "Nintendo Wii Remote"
#         MatchDevicePath "/dev/input/event*"
#         Option "Ignore" "off"
# >>>        Option  "MotionSource"  "ir"
#         Driver "xwiimote"
# EndSection

