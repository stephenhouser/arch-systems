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

# Start openbox window manager, but don't put it in control
/usr/bin/openbox &

# Start front end, exec lets it control when we exit X11
# This also lets you `killall frontend` to terminate X11
exec ~/bin/frontend
