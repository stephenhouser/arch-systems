#!/bin/bash

rom_dir=~/mame0.37b5/roms
art_src=~/.attract/scraper/mame
art_dst=~/.attract/scraper/mame0.37b5

for d in snap wheel flyer marquee
do
	for r in $(ls -1 ${rom_dir})
	do
		rom=$(basename ${r} .zip)
		cp -r ${art_src}/${d}/${rom}* ${art_dst}/${d}/
	done
done