# .bashrc for mini-mame arcade system
#
# Start attract mode under Hyprland, Wayland, on Arch Linux
#
# Also give an option to enter the shell when attract mode exits
#

# from skeleton
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# local changes
alias vi=vim

export PATH="${HOME}/bin:$PATH"

# Unmute ALSA Audio...
amixer sset Master unmute
amixer sset Master '100%'
amixer sset Speaker unmute
amixer sset Speaker '100%'
amixer sset Headphone unmute
amixer sset Headphone '100%'

# Only run attract mode when we are on the console and not already in a window
if [[ ! ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	#startx -- -nocursor
	startx -- -quiet
fi
