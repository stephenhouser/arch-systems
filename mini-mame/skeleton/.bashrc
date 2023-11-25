# 
# Start attract mode to play games
#
# - give an option to end at shell when exit. Otherwise logout
#

# from skeleton
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# local changes
alias vi=vim

export PATH="${HOME}/bin:$PATH"

if [ ! -d ~/shared ] ; then
	echo ""
	echo ""
	echo "*** No Games Installed ***"
	echo ""

	exit 
fi

if [[ ! ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	/usr/bin/startx -- -nocursor

	clear
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
		killall -9 zsh
	fi
fi
