#!/usr/bin/bash
# Bluetooth for Wiimote as lightgun

echo "Untested, don't run this"
exit


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

