#!/bin/sh

# merge in defaults and keymaps
sysresources=/etc/X11/xinit/.Xresources
[ -f $sysresources ] && xrdb -merge $sysresources

sysmodmap=/etc/X11/xinit/.Xmodmap
[ -f $sysmodmap ] && xmodmap $sysmodmap

userresources=$HOME/.Xresources
[ -f "$userresources" ] && xrdb -merge "$userresources"

usermodmap=$HOME/.Xmodmap
[ -f "$usermodmap" ] && xmodmap "$usermodmap"

# start some nice programs when nothing else was specified
#xterm -geometry 80x43+0+0 -name login
xhost +			# enable authentication
xset -dpms		# disable monitor power management
xset s off		# disable screen saver
xset m 5/2 0	# tweak mouse

exec /usr/bin/attract
#exec /usr/bin/startlxde
