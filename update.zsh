#!/usr/bin/env zsh

_zeet_update() {
	cd "$*"
	command git -c gc.auto=0 fetch --quiet

	# Add some delay, we don't want updates to trigger too fast
	sleep 1

	local behind
	behind=$(command git rev-list --right-only --count HEAD...@'{u}')
	if (( behind > 0 )); then
		command git pull --quiet
		command git submodule init --quiet
		command git submodule update --quiet
		return 0
	fi
	return 1
}

_zeet_update_re_source() {
	source ~/.zshrc
}

_zeet_update_callback() {
	if [[ $2 == 0 ]]; then
		zmodload zsh/sched
		sched +1 _zeet_update_re_source
	fi
}

_zeet_update_init() {
	autoload -Uz async && async

	async_start_worker "zeet" -n
	async_register_callback "zeet" _zeet_update_callback
	_ZEET_UPDATE_INIT=1
}

zeet_check_for_updates() {
	async_job "zeet" _zeet_update "$ZSH"
}

if (( ! _ZEET_UPDATE_INIT )); then
	_zeet_update_init
	zeet_check_for_updates
fi
