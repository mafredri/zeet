#!/usr/bin/env zsh

HISTFILE=~/.zsh_history
HISTSIZE=4096
SAVEHIST=4096

setopt append_history         # append to $HISTFILE instead of replace
setopt extended_history       # save additional info to $HISTFILE
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space      # do not save history when line is prefixed with space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history     # append every single command to $HISTFILE immediately after hitting ENTER.
setopt share_history          # always import new commands from $HISTFILE (see 'inc_append_history')

# set alias for history to show all history
alias history="fc -il 1"
