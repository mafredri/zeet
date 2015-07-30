#!/usr/bin/env zsh

ZSH=~/.zsh
# Configure Z before initializing below
_Z_NO_RESOLVE_SYMLINKS=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Set fpath and fignore for compinit (completions)
fpath=(
	$ZSH/functions(N)
	$ZSH/completions(N)
	$ZSH/modules/zsh-completions/src(N)
	$fpath
)
fignore=(.DS_Store $fignore)

source $ZSH/aliases.zsh
source $ZSH/completion.zsh
source $ZSH/history.zsh
source $ZSH/update.zsh

# Modules
zmodload zsh/terminfo
autoload -Uz promptinit && promptinit
autoload -Uz colors && colors
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
autoload -Uz select-word-style && select-word-style bash
autoload -Uz zmv
zle -N hst

autoload brew-cask && brew-cask

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

setopt auto_name_dirs
setopt auto_cd              # automatically cd into directory without even when 'cd' is not present
setopt cdablevars           # enable cd VARNAME/dir/inside/var (without needing $)

setopt no_transient_rprompt # do not remove right prompt from display when accepting a command line.
setopt prompt_subst         # turn on various expansions in prompts
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

# export PROMPT_EOL_MARK='%{$bg[red]%}%{$fg[white]%}%%%{$reset_color%}'

# Set default editor based on SSH
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='rmate --wait'
else
  export EDITOR='subl --wait'
fi

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
# key[Up]='^[[A'
# key[Down]='^[[B'
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
key[ShiftTab]=${terminfo[kcbt]}

# setup key accordingly
[[ -n "${key[Home]}"     ]] && bindkey "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]] && bindkey "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]] && bindkey "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]] && bindkey "${key[Delete]}"   delete-char
# [[ -n "${key[Up]}"       ]] && bindkey "${key[Up]}"       history-substring-search-up
# [[ -n "${key[Down]}"     ]] && bindkey "${key[Down]}"     history-substring-search-down
# [[ -n "${key[Up]}"       ]] && bindkey "${key[Up]}"       history-incremental-search-backward
# [[ -n "${key[Down]}"     ]] && bindkey "${key[Down]}"     history-incremental-search-forward
[[ -n "${key[Left]}"     ]] && bindkey "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]] && bindkey "${key[Right]}"    forward-char
# [[ -n "${key[PageUp]}"   ]] && bindkey "${key[PageUp]}"   beginning-of-buffer-or-history
# [[ -n "${key[PageDown]}" ]] && bindkey "${key[PageDown]}" end-of-buffer-or-history
[[ -n "${key[ShiftTab]}" ]] && bindkey "${key[ShiftTab]}" reverse-menu-complete

# [Ctrl-r] - Reverse search
bindkey '^r' history-incremental-search-backward
bindkey '^f' history-incremental-search-forward

# [Esc-e] - Edit command line in $EDITOR
autoload -U edit-command-line && zle -N edit-command-line
bindkey '\ee' edit-command-line
# [Esc-w] - Kill from the cursor to the beginning of line
bindkey '\ew' kill-region

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
function zle-line-init () {
        echoti smkx
}
function zle-line-finish () {
        echoti rmkx
}
zle -N zle-line-init
zle -N zle-line-finish

# Source a local zshrc if available
[[ -e ~/.zshrc.local ]] && source ~/.zshrc.local

$ZSH/extra.zsh &!

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# Load pure prompt
prompt pure

# source $ZSH/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source $ZSH/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
source $ZSH/modules/z/z.sh
