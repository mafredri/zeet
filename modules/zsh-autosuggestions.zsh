#!/usr/bin/env zsh

# Preventing async is part of the fix to prevent zsh-asug form causing
# havoc on every precmd. If enabled, the "server" will be recreated on
# every prompt.
unset ZSH_AUTOSUGGEST_USE_ASYNC

source $ZSH/modules/zsh-autosuggestions/zsh-autosuggestions.zsh

# This hook replaces _zsh_autosuggest_start so that we can remove the
# hook for rebinding widgets on every prompt...
_custom_zsh_autosuggest_start() {
	add-zsh-hook -d precmd _custom_zsh_autosuggest_start

	_zsh_autosuggest_start
	add-zsh-hook -d precmd _zsh_autosuggest_bind_widgets
}

# Prevent zsh-autosuggestions from rebinding widgets on every prompt.
add-zsh-hook -d precmd _zsh_autosuggest_start
add-zsh-hook precmd _custom_zsh_autosuggest_start
