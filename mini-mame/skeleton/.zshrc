#!/usr/bin/zsh

alias vi=vim
alias ls='ls --color=auto'

if [ -d "\${HOME}/bin" ] ; then
		PATH="\${HOME}/bin:$PATH"
fi

if [[ ! ${DISPLAY} && ${XDG_VTNR} -eq 1 ]]; then
	/usr/bin/startx -- -nocursor

	clear
	echo
	echo
	echo "*** Press RETURN to exit to shell ***"
	echo

	timeout=5
	should_logout=1
	while [[ $timeout -gt 0 ]] ; do
		read -t 1 -p "$timeout seconds... "
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
