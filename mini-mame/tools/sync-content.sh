#!/bin/bash

content_src=${1:-houser@sahmaxi.lan/house/Archive/mini-mame/}
systems="daphne mame scummvm fbneo"

cd ~

for system in ${systems} ; do
	echo "Installing [$system]..."
	if [ -d "${content_src}/${system}" ]; then
		echo "\tshared files..."		
		rsync -rv --chmod=D775,F664 "${content_src}/${system}/" ~
		for ver in ~/${system}/${system}* ; do
			echo "\tlink artwork [$ver]..."
			for art in ~/shared/${system}/*; do
				ln -s "${art}" ~/$(basename ${ver})/$(basename ${art})
			done
		done
	fi
done

# Link current versions...
if [ -d ~/mame0.227 ]; then
	ln -s ~/mame0.227 ~/mame		
fi

if [ -d ~/daphne1.0 ]; then
	ln -s ~/daphne1.0 ~/daphne
fi

if [ -d ~/scummvm2.2 ]; then
	ln -s ~/scummvm2.2 ~/scummvm
fi

if [ -d ~/fbneo ]; then
	# ln -s ~/fbneo ~/fbneo
	for art in ~/shared/mame/*; do
		ln -s "${art}" ~/$(basename ${ver})/$(basename ${art})
	done
fi

# Copy in The Great Theme Collection v10.3 files
#cp -Rv ${content_dir}/assets/the_great_theme_collection-v10.3/* ~/.attract/

