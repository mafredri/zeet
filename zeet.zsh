#!/usr/bin/env zsh

ZSH=${ZDOTDIR:-~}/.zsh
if [[ -d $ZDOTDIR/zeet ]]; then
	ZSH=$ZDOTDIR/zeet
fi
if [[ -n $ZEETDIR ]]; then
	ZSH=$ZEETDIR
fi

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

# Fix common locale issues (e.g. less, tmux).
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"
export LC_LANG="${LC_LANG:-en_US.UTF-8}"
export LESSCHARSET="${LESSCHARSET:-utf-8}"

# Enable colorized otput (e.g. for `ls`).
export CLICOLOR="${CLICOLOR:-yes}"

IS_CHROOT=0
case $OSTYPE in
	darwin*)
		source $ZSH/aliases_darwin.zsh
		;;
	linux-gnu*)
		# Use 24h time format on Linux, causes issues on macOS.
		export LC_TIME="${LC_TIME:-C.UTF-8}"

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
if [[ -f ~/.config/op/plugins.sh ]]; then
	source ~/.config/op/plugins.sh
fi

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
setopt auto_cd              # Automatically cd into directory even when 'cd' is not present.
setopt cdable_vars          # Enable cd VARNAME/dir/inside/var (without needing $).

setopt no_transient_rprompt # Do not remove right prompt from display when accepting a command line.
setopt multios              # Enable multiple redirections.
setopt extended_glob
setopt glob_dots            # Don't require a leading dot for matching "hidden" files.
setopt interactive_comments
setopt no_beep              # Disable beeping.
setopt no_chase_links       # Resolve symlinks.
setopt no_rm_star_silent    # Ask for confirmation for `rm *' or `rm path/*'.

# Remove slash, period, angle brackets and dash from the
# default value for for more ganular word manipulation.
# Default: '*?_-.[]~=/&;!#$%^(){}<>'
export WORDCHARS='*?_[]~=&;!#$%^(){}'

# Create a zkbd compatible hash.
# See: zsh -f Functions/Misc/zkbd
# See: man 5 terminfo
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

typeset -A key_func=(
	Home     beginning-of-line
	End      end-of-line
	Insert   overwrite-mode
	Delete   delete-char
	Left     backward-char
	Right    forward-char
	Up       history-substring-search-up    # Via zsh-history-substring-search.
	Down     history-substring-search-down  # Via zsh-history-substring-search.
	# Up       atuin-history-up
	# Down     atuin-history-down
	PageUp   up-line-or-history
	PageDown down-line-or-history
	ShiftTab reverse-menu-complete
)

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

if [[ -z $HISTDB_FILE ]] && [[ ! -e ~/.histdb ]]; then
	# Keep home tidy, unless ~/.histdb already exists.
	typeset -g HISTDB_FILE=~/.config/histdb/zsh-history.db
fi
#source $ZSH/modules/zsh-histdb.zsh

if (($+commands[atuin])); then
	eval "$(atuin init zsh --disable-up-arrow | grep -v ZSH_AUTOSUGGEST_STRATEGY=)"

	# https://github.com/atuinsh/atuin/blob/6ab61e48d0d4e369a9109db326d08469a4bcb789/crates/atuin/src/shell/atuin.zsh#L14-L19
	# https://github.com/atuinsh/atuin/issues/1618#issuecomment-1956386045
	_zsh_autosuggest_strategy_atuin_auto() {
	    suggestion=$(atuin search --cwd . --cmd-only --limit 1 --search-mode prefix --filter-mode host -- "$1")
	}
	_zsh_autosuggest_strategy_atuin_global() {
	    suggestion=$(atuin search --cmd-only --limit 1 --search-mode prefix --filter-mode host -- "$1")
	}

	ZSH_AUTOSUGGEST_STRATEGY=(atuin_auto atuin_global)
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
source $ZSH/modules/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept

if [[ ! -f ~/.z ]]; then
	# Keep home tidy, unless ~/.z already exists.
	_Z_DATA=~/.config/z
	ZSHZ_DATA=$_Z_DATA
fi
_Z_NO_RESOLVE_SYMLINKS=1
ZSHZ_NO_RESOLVE_SYMLINKS=$_Z_NO_RESOLVE_SYMLINKS
ZSHZ_MAX_SCORE=18000  # Double the max score to keep entries longer.
ZSHZ_CASE=ignore      # Always ignore case because Darwin is case-insensitive.
ZSHZ_UNCOMMON=1
ZSHZ_TILDE=1
ZSHZ_TRAILING_SLASH=1
source $ZSH/modules/zsh-z/zsh-z.plugin.zsh

source $ZSH/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

source $ZSH/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
# Works a bit slow and not as I'd like, disable for now.
#source $ZSH/modules/atuin-omz-autocomplete/atuin-history-arrow.zsh
ATUIN_HISTORY_SEARCH_FILTER_MODE=host

# Source a local zshrc, if available (before compinit & zcompdump).
if [[ -n $ZDOTDIR ]] && [[ -e $ZDOTDIR/.zshrc.local ]]; then
	source ${ZDOTDIR:-~}/.zshrc.local
elif [[ -e ~/.zshrc.local ]]; then
	source ~/.zshrc.local
fi

# Bind keys after all modules are loaded.
for k fn in ${(kv)key_func}; do
	[[ -n $key[$k] ]] && bindkey $key[$k] $fn
done

# Run compinit last to catch all fpaths.
autoload -Uz compinit; compinit -i

# Load extras (like zcompdump to speed up opening a new shell).
source $ZSH/extra.zsh
