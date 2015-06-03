#!/usr/bin/env zsh
#
#	extra.zsh
#
# Non critical tasks that have no effect on the shell environment.
#

compile_zcompdump() {
	setopt local_options
	setopt null_glob
	setopt extended_glob

	zmodload zsh/stat
	# Make sure zcompdump files have been compiled
	for zcd in ~/.zcompdump*~*.zwc; do
		if (( $(zstat +mtime "$zcd") > $(zstat +mtime "$zcd.zwc" 2>/dev/null || print 0) )); then
			zcompile "$zcd"
		fi
	done
}

compile_zcompdump
