#!/usr/bin/env zsh

# Output from: direnv hook zsh
_direnv_hook() {
	trap -- '' SIGINT;
	eval "$(direnv export zsh)";
	trap - SIGINT;
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_direnv_hook]+1}" ]]; then
	precmd_functions=( _direnv_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_direnv_hook]+1}" ]]; then
	chpwd_functions=( _direnv_hook ${chpwd_functions[@]} )
fi
