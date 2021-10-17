#!/usr/bin/env zsh

ZSH=~/.zsh

# Faster response for VI-mode.
export KEYTIMEOUT=1

# Set fpath and fignore for compinit (completions)
fpath=(
	$ZSH/functions(N)
	$ZSH/completions(N)
	$ZSH/modules/zsh-completions/src(N)
	$ZSH/modules/zchee-zsh-completions/src/{go,macOS,zsh}(N)
	$ZSH/modules/zsh-z(N)
	$fpath
)
fignore=(.DS_Store $fignore)

# Modules and extra functionality.
zmodload zsh/terminfo
autoload -Uz promptinit; promptinit
autoload -Uz colors; colors
autoload -Uz select-word-style; select-word-style bash
autoload -Uz url-quote-magic
autoload -Uz bracketed-paste-magic
autoload -Uz bracketed-paste-url-magic
autoload -Uz zmv

IS_CHROOT=0
case $OSTYPE in
	darwin*)
		source $ZSH/aliases_darwin.zsh
		source $ZSH/completion_darwin.zsh
		;;
	linux-gnu*)
		source $ZSH/aliases_linux.zsh

		if [[ $UID == 0 ]] && [[ $(stat -c %d:%i /) != $(stat -c %d:%i /proc/1/root/.) ]]; then
			IS_CHROOT=1
		fi
		;;
esac

IS_SERIAL=0
case $TTY in
	/dev/ttyS[0-9]*|/dev/ttyUSB[0-9]*)
		IS_SERIAL=1
		;;
esac

source $ZSH/aliases.zsh
source $ZSH/completion.zsh
source $ZSH/history.zsh
source $ZSH/update.zsh
source $ZSH/dircycle.zsh
source $ZSH/gpg.zsh

# Activate extra ZLE functionality.
zle -N hst
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-url-magic

# Misc options.
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

# Enable iTerm2 shell integration (before Pure).
# To update:
#   curl -L https://iterm2.com/shell_integration/zsh -o $ZSH/misc/iterm2_shell_integration.zsh
if (( !IS_SERIAL )); then
	source $ZSH/misc/iterm2_shell_integration.zsh
fi

# Load direnv hook before Pure (hook order).
(( $+commands[direnv] )) && source $ZSH/modules/direnv.zsh

# Load pure prompt
prompt pure

# This clear screen widget allows Pure to re-render with its initial
# newline by manually clearing the screen and placing the cursor on
# line 4 so that the prompt is redisplayed on lines 2 and 3.
custom_prompt_pure_clear_screen() {
	zle -I                   # Enable output to terminal.
	print -n '\e[2J\e[4;0H'  # Clear screen and move cursor to (4, 0).
	zle .redisplay           # Redraw prompt.
}
zle -N clear-screen custom_prompt_pure_clear_screen

source $ZSH/misc/pure_halloween.zsh

if (( IS_CHROOT )); then
	PURE_PROMPT_SYMBOL='(chroot) ❯'
fi
if (( IS_SERIAL )); then
	# Serial can't handle beautiful symbols or setting the title ;).
	PURE_PROMPT_SYMBOL='>'
	prompt_pure_set_title() {}
fi

# Source a local zshrc, if available.
[[ -e ~/.zshrc.local ]] && source ~/.zshrc.local

source $ZSH/modules/zsh-histdb.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
source $ZSH/modules/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

_Z_NO_RESOLVE_SYMLINKS=1
ZSHZ_NO_RESOLVE_SYMLINKS=1
ZSHZ_MAX_SCORE=18000  # Double the max score to keep entries longer.
ZSHZ_CASE=ignore      # Always ignore case because Darwin is case-insensitive.
ZSHZ_UNCOMMON=1
source $ZSH/modules/zsh-z/zsh-z.plugin.zsh

# source $ZSH/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source $ZSH/modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

source $ZSH/modules/zsh-history-substring-search/zsh-history-substring-search.zsh

[[ -n $key[Up]   ]] && bindkey $key[Up]   history-substring-search-up
[[ -n $key[Down] ]] && bindkey $key[Down] history-substring-search-down

# Run compinit last to catch all fpaths.
autoload -Uz compinit; compinit -i

# Load extras (like zcompdump to speed up opening a new shell).
source $ZSH/extra.zsh
