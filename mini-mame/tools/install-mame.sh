#!/bin/bash
# Install  version in PKGBUILD

echo ""
echo "*** Installing MAME (default version)..."
echo ""

arch-chroot /mnt pacman -S --noconfirm mame

echo ""
echo "Done."
