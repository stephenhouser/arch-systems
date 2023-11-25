#!/bin/bash
# Mutliple Arcade Machine Emulator via RetroArch
# mame				-- the emulator; use this just to have a mame exe around
# retroarch			-- frontend and CLI for libretro and launching cores
# libretro-core-info	-- needed by retroarch to run cores
# libretro-overlays		-- graphic overlays
# retroarch-assets-xmb	-- graphic elements of retroarch UI

echo ""
echo "*** Installing RetroArch and Cores..."
echo ""

# Install RetroArch -- really for libretro and the "cores" that will allow
# running earlier versions of MAME arcade games. This is just a very
# basic install as I don't use the frontend of RetroArch, I just want the
# ability to use it to launch the libretro-mame games and get the nice
# benefits of libretro.
sudo pacman -S --noconfirm \
	retroarch libretro-core-info libretro-overlays retroarch-assets-ozone

# Run one time to get the template configuration setup
#sudo retroarch
# Change some retroarch settings to my liking
#sed -i 's|menu_show_core_updater = "false"|menu_show_core_updater = "true"|' ~/.config/retroarch/retroarch.cfg
# Leave audio as pulse otherwise I get no sound in games when launching from attract mode as X manager
#sed -i 's|audio_driver = "pulse"|audio_driver = "alsa"|' ~/.config/retroarch/retroarch.cfg
#sed -i 's|video_threaded = "false"|video_threaded = "true"|' ~/.config/retroarch/retroarch.cfg
#sed -i 's|video_fullscreen = "false"|video_fullscreen = "true"|' ~/.config/retroarch/retroarch.cfg

# Make directory for libretro cores (not created by default)
sudo mkdir -p /usr/lib/libretro
sudo chgrp wheel /usr/lib/libretro
sudo chmod g+ws /usr/lib/libretro

# Download MAME 2000, MAME 2003+, and MAME 2010 cores for RetroARch / LibRetro
# Stable cores are in 7z format
# https://buildbot.libretro.com/stable/1.16.0/linux/x86_64/RetroArch_cores.7z
function download_core() {
	cd /usr/lib/libretro
	rm -f ${1}
	curl -LOJ https://buildbot.libretro.com/nightly/linux/x86_64/latest/${1}_libretro.so.zip && \
		unzip ${1}_libretro.so.zip && \
		rm ${1}_libretro.so.zip
}

download_core mame
download_core mame2000		# mame2000 and mame0.37b5
download_core mame2003		# mame2003
download_core mame2003_plus	# mame2003_plus and mame0.78+
#download_core mame2003_midway
download_core mame2010		# mame2010
#download_core mame2015		# not available in latest build (url above)
#download_core mame2016 	# not available in latest build (url above)
download_core fbneo			# FinalBurn NEO (MAME clone) for playability not reproduction

download_core scummvm		# for Windows games (PuttPutt, Pajama Sam, Freddie Fish)
download_core stella		# Atari 2600
#download_core atari800		# Atari 800
#download_core vice_x64		# Commodore 64 (fast/accurate)
#download_core vice_x64sc	# Commodore 64 SuperCPU
#download_core dosbox_core	# DOSBox
#download_core dosbox_pure	# DOSBox
#download_core bnes			# Nintendo Entertainment System (bNES)
#download_core quicknes		# Nintendo Entertainment System (bNES)
#download_core ffmpeg		# Videos

echo ""
echo "Done."
