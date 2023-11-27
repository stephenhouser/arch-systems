#!/bin/bash

content_src=${1:-houser@sahmaxi.lan:/srv/systems/mini-mame}
systems="daphne fbneo mame scummvm"

cd ~

for system in ${systems} ; do
	echo "Installing [$system]..."
	rsync -rv --chmod=D775,F664 "${content_src}/${system}/" ~

	for ver in ~/${system}* ; do
		echo " link artwork [$ver]..."
		for art in ~/shared/${system}/* ; do
			ln -s "${art}" ~/$(basename ${ver})/$(basename ${art})
		done
	done
done

# Link content to current versions...
[ -d ~/mame ] && rm ~/mame
[ -d ~/mame0.227 ] && ln -s ~/mame0.227 ~/mame

[ -d ~/scummvm ] && rm ~/scummvm
[ -d ~/scummvm2.2 ] && ln -s ~/scummvm2.2 ~/scummvm

[ -d ~/daphne ] && rm ~/daphne
[ -d ~/daphne1.0 ] && ln -s ~/daphne1.0 ~/daphne

if [ -d ~/fbneo ]; then
	# ln -s ~/fbneo ~/fbneo
	for art in ~/shared/mame/*; do
		ln -s "${art}" ~/$(basename ${ver})/$(basename ${art})
	done
fi
