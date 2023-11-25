#!/bin/bash

echo ""
echo "*** Installing Attract Mode frontend..."
echo ""

# Attract Mode
pacman -S --noconfirm gnu-free-fonts
#su ${user} -c "pikaur -Syu --noconfirm attract-git"
pikaur -Syu --noconfirm attract-git

echo ""
echo "Done."
