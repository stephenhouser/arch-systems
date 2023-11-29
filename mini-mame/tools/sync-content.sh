#!/bin/bash

content_src=${1:-houser@sahmaxi.lan:/srv/systems/mini-mame}
systems="daphne fbneo mame scummvm"

cd ~

for system in ${systems} ; do
	echo "Installing [$system]..."
	#rsync -aiv --chmod=D775,F664 "${content_src}/${system}/" ~
	rsync -aiv "${content_src}/${system}/" ~

	for ver in ~/${system}* ; do
		# fbneo uses MAME artwork
		[[ ${system} == "fbneo" ]] && system="mame"

		# don't copy to the symlinked current version
		if [[ "$(basename ${ver})" == "${system}" ]] ; then
			continue
		fi

		echo " link shared artwork [$ver]..."
		for art in ~/shared/${system}/* ; do
			dst=~/$(basename ${ver})/$(basename ${art})

			# delete any previous link to shared artwork
			[[ $(readlink -f "${dst}") == *"shared"* ]] && rm "${dst}"

			# link art directories only
			[[ -d "${art}" && ! -d "${dst}" ]] && ln -s "${art}" "${dst}"
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

# fbneo is not versioned the same way as others
# [ -d ~/fbneo ] && rm ~/fbneo
# [ -d ~/fbneo1.0 ] && ln -s ~/fbneo1.0 ~/fbneo

# Touch when we last pulled content
touch ~/content.timestamp
