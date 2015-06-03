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

# Detect and open sublime-project files in the provided path, if no parameters
# are provided, open the $PWD. If the parameter is not a directory, call subl
# normally.
_subl() {
	local params="$*"
	local project

	if test -z "$params"; then
		params=.
	fi

	if test -d "$params"; then
		project=$(ls "$params"/*.sublime-project 2>/dev/null) 2>/dev/null

		if test -n "$project"; then
			command subl --project "$project"
		else
			command subl "$params"
		fi
	else
		command subl "$@"
	fi
}

alias subl="_subl"
