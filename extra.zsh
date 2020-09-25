#!/usr/bin/env zsh
#
#	extra.zsh
#
# Non critical tasks that have no effect on the shell environment.
#

compile_zcompdump() {
	setopt local_options null_glob extended_glob no_sh_word_split

	zmodload -F zsh/stat b:zstat
	# Make sure zcompdump files have been compiled
	for zcd in ~/.zcompdump*~*.zwc; do
		if (( $(zstat +mtime $zcd) > $(zstat +mtime $zcd.zwc 2>/dev/null || print 0) )); then
			# zcompile does not support file names with a ’-character, so this
			# might produce an error on Macs that seem to have it by default in
			# their hostname.
			zcompile $zcd
		fi
	done
}

zmodload zsh/sched

# Schedule to run after 1 second to avoid slowing down initial prompt rendering.
sched +1 compile_zcompdump
