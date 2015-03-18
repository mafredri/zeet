#!/usr/bin/env zsh

alias grep='grep --color=auto'

if [[ $OSTYPE == darwin* ]]; then
	alias ls='ls -GFh'
fi

if [[ $OSTYPE == linux-gnu ]]; then
	alias ls='ls --color=auto -Fh'
fi
