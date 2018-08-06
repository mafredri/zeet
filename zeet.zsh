#!/usr/bin/env zsh

ZSH=~/.zsh
# Configure Z before initializing below
_Z_NO_RESOLVE_SYMLINKS=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Faster response for VI-mode.
export KEYTIMEOUT=1

# Set fpath and fignore for compinit (completions)
fpath=(
	$ZSH/functions(N)
	$ZSH/completions(N)
	$ZSH/modules/zsh-completions/src(N)
	$ZSH/modules/go-zsh-completions/src(N)
	$fpath
)
fignore=(.DS_Store $fignore)

source $ZSH/aliases.zsh
source $ZSH/completion.zsh
source $ZSH/history.zsh
source $ZSH/update.zsh
source $ZSH/dircycle.zsh
source $ZSH/completions/_ng

# Modules
zmodload zsh/terminfo
autoload -Uz promptinit; promptinit
autoload -Uz colors; colors
autoload -Uz select-word-style; select-word-style bash
autoload -Uz url-quote-magic
autoload -Uz bracketed-paste-magic
autoload -Uz zmv

zle -N hst
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

setopt auto_name_dirs
setopt auto_cd              # automatically cd into directory without even when 'cd' is not present
setopt cdable_vars          # enable cd VARNAME/dir/inside/var (without needing $)

setopt no_transient_rprompt # do not remove right prompt from display when accepting a command line.
setopt multios              # enable multiple redirections
setopt extended_glob
setopt glob_dots            # don't require a leading dot for matching "hidden" files
setopt interactive_comments
setopt no_beep              # disable beeping
setopt no_chase_links       # resolve symlinks
setopt no_rm_star_silent    # ask for confirmation for `rm *' or `rm path/*'

# by default: export WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
# we take out the slash, period, angle brackets, dash here.
export WORDCHARS='*?_[]~=&;!#$%^(){}'

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export CLICOLOR="yes"

# Set default editor based on SSH
if [[ -n $SSH_CONNECTION ]]; then
	# export EDITOR='rmate --wait'
else
	if (( $+commands[code] )); then
		export EDITOR='code --wait'
	elif (( $+commands[nvim] )); then
		export EDITOR=nvim
	fi
fi

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=$terminfo[khome]
key[End]=$terminfo[kend]
key[Insert]=$terminfo[kich1]
key[Delete]=$terminfo[kdch1]
key[Up]=$terminfo[kcuu1]
key[Down]=$terminfo[kcud1]
key[Left]=$terminfo[kcub1]
key[Right]=$terminfo[kcuf1]
key[PageUp]=$terminfo[kpp]
key[PageDown]=$terminfo[knp]
key[ShiftTab]=$terminfo[kcbt]

[[ -n $key[Home]     ]] && bindkey $key[Home]     beginning-of-line
[[ -n $key[End]      ]] && bindkey $key[End]      end-of-line
[[ -n $key[Insert]   ]] && bindkey $key[Insert]   overwrite-mode
[[ -n $key[Delete]   ]] && bindkey $key[Delete]   delete-char
[[ -n $key[Left]     ]] && bindkey $key[Left]     backward-char
[[ -n $key[Right]    ]] && bindkey $key[Right]    forward-char
[[ -n $key[PageUp]   ]] && bindkey $key[PageUp]   up-line-or-history
[[ -n $key[PageDown] ]] && bindkey $key[PageDown] down-line-or-history
[[ -n $key[ShiftTab] ]] && bindkey $key[ShiftTab] reverse-menu-complete

# [Ctrl-r] - Reverse search
bindkey '^r' history-incremental-search-backward
bindkey '^f' history-incremental-search-forward

# [Esc-e] - Edit command line in $EDITOR
autoload -U edit-command-line && zle -N edit-command-line
bindkey '\ee' edit-command-line

# [Esc-w] - Kill from the cursor to the beginning of line
bindkey '\ew' kill-region

# Set [Opt+Right] to forward word
bindkey '\e[1;9C' forward-word
# Set [Opt+Left] to backward word
bindkey '\e[1;9D' backward-word

if [[ -n $TMUX ]]; then
	bindkey "\e[1;3C" forward-word
	bindkey "\e[1;3D" backward-word
fi

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
	function zle-line-init() {
		echoti smkx
	}
	function zle-line-finish() {
		echoti rmkx
	}
	zle -N zle-line-init
	zle -N zle-line-finish
fi

# Source a local zshrc if available
[[ -e ~/.zshrc.local ]] && source ~/.zshrc.local

# Activate extras in a disowned child process
$ZSH/extra.zsh &!

IS_SERIAL=0
case $TTY in
	/dev/ttyS[0-9]*|/dev/ttyUSB[0-9]*)
		IS_SERIAL=1
		;;
esac

# Enable iTerm2 shell integration
(( !IS_SERIAL )) && source $ZSH/misc/iterm2_shell_integration.zsh

# Load direnv hook before Pure (hook order).
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Load pure prompt
prompt pure

(( IS_SERIAL )) && {
	PROMPT_PURE_SYMBOL='>'
	prompt_pure_set_title() {}
}

source $ZSH/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
if [[ $ZSH_VERSION > 5.1 ]]; then
	# Only use async suggestions on more modern versions of ZSH.

	# Disable, seems to prevent Ctrl+C in som instances.
	# ZSH_AUTOSUGGEST_USE_ASYNC=true
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
bindkey '^ ' autosuggest-accept

source $ZSH/modules/z/z.sh

source $ZSH/modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
FAST_HIGHLIGHT[use_async]=1
source $ZSH/modules/history-search-multi-word/history-search-multi-word.plugin.zsh
# source $ZSH/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/modules/zsh-history-substring-search/zsh-history-substring-search.zsh

[[ -n $key[Up]   ]] && bindkey $key[Up]   history-substring-search-up
[[ -n $key[Down] ]] && bindkey $key[Down] history-substring-search-down
