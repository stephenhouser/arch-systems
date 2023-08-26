#!/bin/bash

contnet_dev=${1:-/dev/sdb2}
content_dir=/mnt
systems="daphne mame scummvm fbneo"

sudo mount ${contnet_dev} ${content_dir}

for system in ${systems} ; do
	echo "Copy [$system]..."
	if [ -d "${content_dir}/${system}" ]; then
		echo "	shared files..."		
		rsync -rv --chmod=D775,F664 "${content_dir}/${system}/shared" ~
		for ver in ${content_dir}/${system}/${system}*; do
			echo "   version [$ver]..."
			rsync -rv --chmod=D775,F664 "${ver}" ~
			echo "   link artwork..."
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
cp -Rv ${content_dir}/assets/the_great_theme_collection-v10.3/* ~/.attract/

# Unmount content disk
sudo umount ${content_dir}


