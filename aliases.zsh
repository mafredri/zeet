#!/usr/bin/env zsh

alias grep='grep --color=auto'

alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

if [[ $OSTYPE == darwin* ]]; then
	alias ls='ls -GFh'
fi

if [[ $OSTYPE == linux-gnu ]]; then
	alias ls='ls --color=auto -Fh'
fi
