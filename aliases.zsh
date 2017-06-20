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
		alias srm='rm -P'
		alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
		alias code='code --goto'
		PSQL_EDITOR='code --wait'

		# Prefer `df` from Homebrew `coreutils`.
		(( $+commands[gdf] )) && alias df=gdf

		# For Homebrew packages.
		export HOMEBREW_EDITOR='code --wait'
		export ANDROID_HOME=/usr/local/opt/android-sdk  # android
		export MONO_GAC_PREFIX=/usr/local               # mono
		;;
	linux-gnu*)
		alias ls='ls --color=auto -Fh'
		PSQL_EDITOR='vim'
		;;
esac

(( $+commands[nvim] )) && alias vim=nvim
(( $+commands[hub] )) && alias git=hub

export PSQL_EDITOR
alias psql='PAGER="less --chop-long-lines" psql'

# Add types to ripgrep.
alias rg='rg --type-add "scss:*.scss" --type-add "sass:*.sass"'
