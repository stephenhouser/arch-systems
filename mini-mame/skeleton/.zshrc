#!/usr/bin/zsh

alias vi=vim
alias ls='ls --color=auto'

if [ -d "\${HOME}/bin" ] ; then
		PATH="\${HOME}/bin:$PATH"
fi

if [ -z "\${DISPLAY}" ] && [ -n "\${XDG_VTNR}" ] && [ "\${XDG_VTNR}" -eq 1 ]; then
	exec /usr/bin/startx -- -nocursor
fi
