#!/bin/bash
# Install  version in PKGBUILD

echo ""
echo "*** Installing Wine..."
echo ""

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
sudo pacman --noconfirm -S \
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

echo ""
echo "Done."

