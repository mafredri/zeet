#!/usr/bin/env zsh

_zeet_update() {
	# cd -q prevents side-effects of changing directory
	cd -q $1
	# prevent git garbage collection for performance reasons
	command git -c gc.auto=0 fetch --quiet

	local behind
	behind=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null)
	if (( ${behind:-0} > 0 )); then
		command git pull --quiet
		command git submodule update --init --quiet
		return 0
	fi
	return 1
}

_zeet_update_re_source() {
	source ~/.zshrc
}

_zeet_update_callback() {
	if [[ $2 == 0 ]]; then
		# use zsh/sched to schedule re-sourcing of .zshrc 1 second from now,
		# prevents current execution context from being interrupted
		zmodload zsh/sched
		sched +1 _zeet_update_re_source
	fi
	async_stop_worker "zeet"
}

_zeet_update_init() {
	autoload -Uz async && async

	async_start_worker "zeet" -n
	async_register_callback "zeet" _zeet_update_callback
	_ZEET_UPDATE_INIT=1
}

zeet_check_for_updates() {
	async_job "zeet" _zeet_update $ZSH
}

if (( ! _ZEET_UPDATE_INIT )); then
	_zeet_update_init
	zeet_check_for_updates
fi
