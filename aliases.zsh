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

_todo() {
	rg 'TODO(\([^)]*\)|:)' --pretty "$@" | ${PAGER:-less} -r
}
alias todo='_todo --glob "!vendor/**/*.go"'
alias todo-c='todo -B 3 -A 5'

_chrome_runner() { _chrome "$@" &; }
_chrome() {
	setopt localoptions localtraps noshwordsplit

	local chrome=$1; shift
	local userdata=$(mktemp -d)
	local -a default_args=(
		--remote-debugging-port=9222
		--disable-gpu
		--disable-translate
		--disable-sync
		--disable-default-apps
		--no-first-run
		--no-default-browser-check
		--user-data-dir=$userdata
		--window-size=1000,600
	)

	trap 'exit 0' INT
	trap "print chrome: cleaning up...; rm -rf '$userdata'" EXIT
	$chrome $default_args "$@" about:blank
}

alias chrome='_chrome_runner /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias chrome-canary='_chrome_runner /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'
