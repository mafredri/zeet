#!/usr/bin/env zsh

autoload -Uz compinit && compinit -i
zmodload zsh/complist
zmodload zsh/computil

setopt complete_in_word
setopt no_complete_aliases # complete_aliases breaks autocompletion in z
setopt always_to_end
setopt auto_menu           # show completion menu on succesive tab press

zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' insert-tab pending
zstyle ':completion:*' expand yes
# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*"
zstyle ':completion:*' list-colors ""
zstyle ':completion:*' menu select=2 _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:descriptions' format "%{${fg[yellow]}%}[ %d ]%{${reset_color}%}"
zstyle ':completion:*:corrections' format "%{${fg[yellow]}%}[ %d ]%{${reset_color}%} (errors %e)"
zstyle ':completion:*:messages' format $'\e[00;31m%d'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:rm:*' ignore-line yes

zstyle ':completion:*:*:*:processes'      command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*'           menu yes select
zstyle ':completion:*:kill:*'             force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=33=35=34'

#zstyle ':completion:*:*:*:processes' list-colors "=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01"
#zstyle ':completion:*:*:*:*:hosts' list-colors "=*=$color[cyan];$color[bg-black]"
zstyle ':completion:*:functions' ignored-patterns "_*"
zstyle ':completion:*:original' list-colors "=*=$color[red];$color[bold]"
zstyle ':completion:*:parameters' list-colors "=[^a-zA-Z]*=$color[red]"
zstyle ':completion:*:aliases' list-colors "=*=$color[green]"

zstyle ':completion:*:*:*:users' ignored-patterns "_*"

# Make sure zcompdump files have been compiled
(
	setopt extended_glob
	zmodload zsh/stat
	for zcd in ~/.zcompdump*~*.zwc; do
		if (( $(zstat +mtime $zcd) > $(zstat +mtime $zcd.zwc 2>/dev/null || print 0) )); then
			zcompile $zcd
		fi
	done
) &!
