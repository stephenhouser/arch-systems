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

arch_user=workshop

# If I am *not* the mame user, create the *mame* user and run as them.
if [ "${USER}" != "${arch_user}" ]; then
	if $(whiptail --yesno "You are not ${arch_user}. Continue anyway?" 0 0); then
		:	# simply continues after the if...
	else
		exit 0
	fi
fi

echo ""
echo "Unmute ALSA Audio..."
amixer sset Master unmute
amixer sset Master '100%'
amixer sset Speaker unmute
amixer sset Speaker '100%'
amixer sset Headphone unmute
amixer sset Headphone '100%'

# Copy in dot files *after* everything else so we can overlay our
# configs onto the default ones created above...
echo ""
echo "Setup dot files..."
#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#cd ${dir}
rsync -avz ./skeleton/ ${HOME}

cat >> ${HOME}/.zshrc << EOF
alias vi=vim

if [ -d "\${HOME}/bin" ] ; then
        PATH="\${HOME}/bin:$PATH"
fi
EOF

# Enable automatic login to X11
# https://wiki.archlinux.org/title/SDDM
# echo ""
# echo "Enable auto-login as ${USER}..."
# mkdir -p /etc/sddm.conf.d
# sudo cat >> /etc/sddm.conf.d/autologin.conf << EOF
# /etc/sddm.conf.d/autologin.conf
# [Autologin]
# User=workshop
# Session=workshop
# EOF

# Get Pikaur
mkdir -p ~/src
cd ~/src
git clone https://github.com/actionless/pikaur.git
cd pikaur
makepkg -fsri

