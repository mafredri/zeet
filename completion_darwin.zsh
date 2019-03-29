#!/usr/bin/env zsh

if [[ -d /Applications/Docker.app/Contents/Resources/etc ]]; then
	mkdir -p /Applications/Docker.app/Contents/Resources/etc/zfunctions
	(
		cd /Applications/Docker.app/Contents/Resources/etc/zfunctions
		for comp in ../*.zsh-completion; do
			file=${comp:t}
			ln -sf ../$file ./_${file:r}
		done
	)
	fpath+=(/Applications/Docker.app/Contents/Resources/etc/zfunctions)
fi
