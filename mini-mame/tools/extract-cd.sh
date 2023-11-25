#!/bin/bash

gdir=game.$$

mkdir ${gdir}
fuseiso "${1}" "${gdir}"

