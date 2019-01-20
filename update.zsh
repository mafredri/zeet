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
		command git submodule sync
		command git submodule update --init --quiet
		return 0
	fi
	return 1
}

_zeet_update_replace_shell() {
	exec $SHELL
}

_zeet_update_callback() {
	if [[ $2 == 0 ]]; then
		# Update config on next prompt.
		precmd_functions+=(_zeet_update_replace_shell)
	fi
	async_stop_worker "zeet"
	_ZEET_UPDATE_INIT=0
}

_zeet_update_init() {
	autoload -Uz async && async

	async_start_worker "zeet" -n
	async_register_callback "zeet" _zeet_update_callback
	_ZEET_UPDATE_INIT=1
}

_zeet_precmd_update_init() {
	add-zsh-hook -d precmd _zeet_precmd_update_init
	zeet_check_for_updates
}

zeet_check_for_updates() {
	if (( ! _ZEET_UPDATE_INIT )); then
		_zeet_update_init
	fi
	async_job "zeet" _zeet_update $ZSH
}

# Check for updates after the prompt has initialized, this gives time for user
# initialized environment variables to settle (say, SSH socket for example).
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zeet_precmd_update_init
