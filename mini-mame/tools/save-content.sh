#!/bin/bash

echo "Untested, don't run this"
exit

function sync() {
	sudo rsync -v --progress --modify-window=1 --update --recursive --no-links --times "$1" "$2"
}

sync ~/daphne1.0 /mnt/daphne/
sync ~/shared/daphne /mnt/daphne/shared/

sync ~/scummvm2.2 /mnt/scummvm/
sync ~/shared/scummvm /mnt/scummvm/shared/

sync ~/fbneo /mnt/fbneo/
#sync ~/shared/fbneo /mnt/fbneo/shared/

sync ~/mame0.37b5	/mnt/mame/
sync ~/mame0.78+ /mnt/mame/
sync ~/mame0.227 /mnt/mame/
sync ~/shared/mame /mnt/mame/shared/

sync ~/.attract/ /mnt/frontend/attract
sync ~/.config/retroarch /mnt/frontend/
sync ~/.config/scummvm /mnt/frontend/
sync ~/.mame/ /mnt/frontend/mame
