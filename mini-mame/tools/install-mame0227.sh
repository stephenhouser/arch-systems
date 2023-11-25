#!/bin/bash
# force mame0227 version in PKGBUILD

echo ""
echo "*** Installing MAME v0.277..."
echo ""

cd /tmp
git clone https://aur.archlinux.org/mame-git.git && \
	cd mame-git && \
	sed -i 's|https://github.com/mamedev/mame.git|https://github.com/mamedev/mame.git#tag=mame0227|' PKGBUILD && \
	makepkg -si --noconfirm

echo ""
echo "Done."
