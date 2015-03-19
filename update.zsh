#!/usr/bin/env zsh

_zeet_update() {
	cd $1
	command git fetch --quiet
	local behind=$(command git rev-list --right-only --count HEAD...@'{u}')
	if (( behind > 0 )); then
		command git pull --quiet
		command git submodule update --quiet
		return 0
	fi
	return 1
}

_zeet_update_callback() {
	if [[ $2 == 0 ]]; then
		source ~/.zshrc
	fi
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
