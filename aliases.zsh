#!/usr/bin/env zsh

alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# Feature test the --color parameter since busybox
# doesn't support it.
if grep --color=auto test<<<test &>/dev/null; then
	alias grep='grep --color=auto'
fi

# wget http://nion.modprobe.de/mostlike.txt
# tic mostlike.txt && rm mostlike.txt
if test ! $(find $HOME/.terminfo -name mostlike 2>/dev/null); then
	tic $ZSH/misc/mostlike.txt
fi
man() {
	TERMINFO=$HOME/.terminfo LESS=C TERM=mostlike PAGER=less command man $@
}

case $OSTYPE in
	darwin*)
		alias ls='ls -GFh'
		alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
		;;
	linux-gnu)
		alias ls='ls --color=auto -Fh'
		;;
esac
