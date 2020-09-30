#!/usr/bin/env zsh

source $ZSH/modules/zsh-autosuggestions/zsh-autosuggestions.zsh

# Preventing async is part of the fix to prevent zsh-asug form causing
# havoc on every precmd. If enabled, the "server" will be recreated on
# every prompt.
unset ZSH_AUTOSUGGEST_USE_ASYNC
# Prevent zsh-autosuggestions from rebinding widgets on every prompt.
typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=
