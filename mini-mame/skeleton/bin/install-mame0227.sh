#!/bin/bash
cd /tmp
git clone https://aur.archlinux.org/mame-git.git
cd mame
# force mame0227 version in PKGBUILD
sed -i 's|https://github.com/mamedev/mame.git|https://github.com/mamedev/mame.git#tag=mame0227|' PKGBUILD
makepkg -si --noconfirm
