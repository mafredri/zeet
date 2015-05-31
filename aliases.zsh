#!/usr/bin/env zsh

alias grep='grep --color=auto'

alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# wget http://nion.modprobe.de/mostlike.txt
# tic mostlike.txt && rm mostlike.txt
alias man="TERMINFO=~/.terminfo/ LESS=C TERM=mostlike PAGER=less man"

case $OSTYPE in
	darwin*)
		alias ls='ls -GFh'
		;;
	linux-gnu)
		alias ls='ls --color=auto -Fh'
		;;
esac
