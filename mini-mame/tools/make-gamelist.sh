#!/bin/bash

for g in $(cat mame.txt | cut -d\; -f1); do
	if ls ~/mame0.78+/roms/${g}* &> /dev/null; then
		grep "^${g}\;" mame.txt >> mame0.78+.txt
	else
		echo MISSING: $g
	fi
done


for g in $(cat mame.tag); do
	if grep "^${g}\;" mame0.78+.txt; then
		echo ${g} >> mame0.78+.tag
	fi
done