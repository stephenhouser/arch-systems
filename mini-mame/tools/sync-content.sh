#!/bin/bash

content_src=${1:-houser@sahmaxi.lan:Archive/mini-mame}
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

# Link current versions...
if [ -d ~/mame0.227 ]; then
	ln -s ~/mame0.227 ~/mame		
fi

if [ -d ~/daphne1.0 ]; then
	rm ~/daphne
	ln -s ~/daphne1.0 ~/daphne
fi

if [ -d ~/scummvm2.2 ]; then
	rm ~/scummvm
	ln -s ~/scummvm2.2 ~/scummvm
fi

if [ -d ~/fbneo ]; then
	# ln -s ~/fbneo ~/fbneo
	for art in ~/shared/mame/*; do
		ln -s "${art}" ~/$(basename ${ver})/$(basename ${art})
	done
fi
