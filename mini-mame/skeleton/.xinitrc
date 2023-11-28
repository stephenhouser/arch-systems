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

xhost +			# enable authentication
xset -dpms		# disable monitor power management
xset s off		# disable screen saver
xset m 5/2 0	# tweak mouse

# for troublshooting, can exec lxde and get full window system
# if there is a file named "debug" in the home directory
if [ -f ~/debug ] ; then
	xterm -geometry 80x43+0+0 -name login &
	exec /usr/bin/startlxde
fi

# start openbox window manager in the background
# This is so ScummVM works properly. Otherwise it is not able
# to resize the display (or its window) and you can't play games!
# Start attract mode front end, when it exits, we exit
/usr/bin/openbox &
exec /usr/bin/attract
