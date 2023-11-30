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

# For when things are being installed and there are no games yet
if [ ! -d ~/shared ] ; then
	echo ""
	echo ""
	echo "*** No Games Installed ***"
	echo ""

	return 
fi

# Only run attract mode when we are on the console and not already in a window
if [[ ! ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	Hyprland
	startx -- -nocursor

	# Here's where we give the option to exit to the shell
	echo ""
	echo ""
	echo "*** Press RETURN to exit to shell ***"
	echo ""

	timeout=5
	should_logout=1
	while [[ $timeout -gt 0 ]] ; do
		# Bash's read uses '-p' for prompt and returns > 128 on timeout
		read -t 1 -p "${timeout} seconds... "
		if [[ $? -lt 128 ]]; then
			should_logout=0
			break
		fi

		timeout=$(($timeout - 1))
	done

	if [[ $should_logout -eq 1 ]]; then
		logout
	fi
fi
