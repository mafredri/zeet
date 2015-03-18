#!/usr/bin/env zsh

alias grep='grep --color=auto'
alias ls='-Fh'

if [[ $OSTYPE == darwin* ]]; then
	alias ls='ls -G'
fi

if [[ $OSTYPE == linux-gnu ]]; then
	alias ls='ls --color=auto'
fi
