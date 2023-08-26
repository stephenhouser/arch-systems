#!/bin/bash

BP_DIR=~/src/bezelproject-MAME

echo ""
echo "Install Overlay Bezels for libRetro..."
if [ ! -d ~/src/bezelproject-MAME ]; then
	echo "	Clone bezels..."
	git clone https://github.com/thebezelproject/bezelproject-MAME.git ${BP_DIR}
else
	echo "	Update bezels..."
	cd ${BP_DIR}
	git pull
	cd -
fi

# 'FB Alpha'  'FinalBurn Neo'   MAME  'MAME 2003 (0.78)'  'MAME 2003-Plus'  'MAME 2010'
#!/bin/bash

BP_DIR=/home/mame/src/bezelproject-MAME/retroarch
RA_DIR=/home/mame/.config/retroarch
function install_bezel() {
	core="$1"
	rom="$2"
	if [ -f "${BP_DIR}/config/${core}/${rom}.cfg" ] ; then
		# /opt/retropie/configs/all/retroarch/
		sed "s|/opt/retropie/configs/all/retroarch|${BP_DIR}|" \
			"${BP_DIR}/config/${core}/${rom}.cfg" \
			> "${RA_DIR}/config/${core}/${rom}.cfg"
	fi
}

# FBNeo
for rom in ~/fbneo/arcade/*; do
	rom=$(basename $rom .zip)
	echo $rom
	install_bezel "FinalBurn Neo" ${rom}
done