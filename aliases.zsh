#!/usr/bin/env zsh

alias grep='grep --color=auto'
alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

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
		;;
	linux-gnu)
		alias ls='ls --color=auto -Fh'
		;;
esac

nocoffee() {
	local sleep_time=${1:-7}
	echo "Notification in $sleep_time minutes..."
	sleep_time=$(( sleep_time * 60 ))
	(
		sleep $sleep_time
		osascript -e 'tell app "System Events" to display alert "Your coffee is done!" message "Go get your coffee!" as critical'
	) &>/dev/null &!
}

keepingyouawake() {
	open keepingyouawake:///activate
}
