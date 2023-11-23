#!/usr/bin/zsh

alias vi=vim
alias ls='ls --color=auto'

if [ -d "\${HOME}/bin" ] ; then
		PATH="\${HOME}/bin:$PATH"
fi

if [[ ! ${DISPLAY} && ${XDG_VTNR} -eq 1 ]; then
	/usr/bin/startx -- -nocursor

	T=5
	clear
	echo
	echo
	echo "*** Press RETURN to exit to shell ***"
	echo
	while [[ $T -gt 0 ]] ; do
		read -t 1 -p "$T seconds... "
		if [[ $? -ge 128 ]]; then
			logout
		fi

		T=$(($T - 1))
	done
fi
