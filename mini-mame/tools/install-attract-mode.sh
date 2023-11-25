#!/bin/bash

echo ""
echo "*** Installing Attract Mode frontend..."
echo ""

# Attract Mode
sudo pacman -S --noconfirm gnu-free-fonts

#su ${user} -c "pikaur -Syu --noconfirm attract-git"
pikaur -Syu --noconfirm attract-git

echo ""
echo "Done."
