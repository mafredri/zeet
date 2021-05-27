#!/usr/bin/env zsh

# Feature test the --color parameter since busybox
# doesn't support it.
if grep --color=auto test<<<test &>/dev/null; then
	alias grep='grep --color=auto'
fi

alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias logssh=_logssh
alias psql='PAGER="less --chop-long-lines" psql'
alias godoc-open=_godoc-open
alias remote_pbcopy=_remote_pbcopy
alias findi=_findi

alias todo='_todo_or_note TODO --glob "!vendor/**/*.go"'
alias todo-c='todo -B 3 -A 5'
alias note='_todo_or_note NOTE --glob "!vendor/**/*.go"'
alias note-c='note -B 3 -A 5'

alias install_go=_install_go
alias icanhazip=_icanhazip

(( $+commands[pbcopy] )) || alias pbcopy=remote_pbcopy
(( $+commands[nvim] )) && alias vim=nvim

(( $+commands[kubectl] )) && alias k=kubectl

# By using a function instead of alias we can prevent the environment variables
# being part of the command.
man() {
	_init_mostlike
	TERMINFO=$HOME/.terminfo LESS=C TERM=mostlike PAGER=less command man $@
}

# Mostlike color output for man pages.
# wget http://nion.modprobe.de/mostlike.txt && tic mostlike.txt && rm mostlike.txt
_init_mostlike() {
	if [[ ! -e $HOME/.terminfo/*/mostlike(#qN) ]]; then
		tic $ZSH/misc/mostlike.txt
	fi
}

# Copy to clipboard on remote machines using OSC 52.
#
# For iTerm2 we must enable:
# Preferences > General > "Applications in terminal may access clipboard"
#
# OSC 52 works in iTerm2, but we could also use the iTerm specific codes, like
# copy to pasteboard (system):
#   print -n "\e]1337;Copy=;$(base64 $args /dev/stdin)\007"
# Or via copy to clipboard:
#   print -n '\e]1337;CopyToClipboard=\a'
#   print 'My message without base64 encoding'
#   print -n '\e]1337;EndCopy\a'
_remote_pbcopy() {
	local begin end args=()
	if [[ $OSTYPE != darwin* ]]; then
		# The base64 must be a single line.
		args+=(--wrap=0)
	fi

	# OSC 52 operates the clipboard, c is for copy.
	begin='\e]52;c;'
	end='\a'

	if [[ -n $TMUX ]]; then
		# Inside tmux, we must escape the construct.
		begin="\ePtmux;\e${begin}"
		end="${end}\e\\"
	fi

	print -n $begin
	base64 $args /dev/stdin
	print -n $end
}

_findi() {
	local dir=$1
	if [[ $#@ -eq 1 ]]; then
		dir=.
	else
		shift
	fi
	command find $dir -iname "*${(j.*.)@}*"
}

_godoc-open() {
	open http://localhost:6060/pkg/${PWD#$GOPATH/src/}
}

_logssh() {
	[[ -d ~/.ssh/log ]] || mkdir ~/.ssh/log
	chmod 0700 ~/.ssh/log

	local -A config
	config=($(ssh -G $@ | awk '/^(user|hostname|port)\ /'))
	local file
	file=~/.ssh/log/$(date "+${config[hostname]}:${config[port]}@${config[user]}_%Y-%m-%dT%H:%M:%S.log")
	touch $file && chmod 0600 $file

	ssh $@ | tee -a $file
}

_todo_or_note() {
	local action=$1; shift
	{rg $action' ?(\([^)]*\)|:).*' --pretty "$@" || print "No ${action}s found.\n"} \
		| ${PAGER:-less} -C -R
}

_install_go() {
	parse() {
		tr -d $'\n' \
			| grep -E -o "(go1[^>]*\ *\(released [0-9]{4}/[0-9]{2}/[0-9]{2}\))" \
			| sed -e $'s/\t\t/ /g' \
			| sort -t. -k 1,1nr -k 2,2nr -k 3,3nr
	}
	if which curl >/dev/null; then
		fetch() { curl -s -L "$@"; }
	elif which wget >/dev/null; then
		fetch() { wget -q -O- "$@"; }
	else
		echo "error: curl or wget must be present"
		exit 1
	fi
	if [[ -z $1 ]] || [[ $1 == list ]]; then
		local release="https://golang.org/doc/devel/release.html"
		print "Fetching Go releases..."
		fetch "$release" | parse
		return
	fi

	local version="$1" os arch
	if ! echo $version | grep -q "^go"; then
		version="go${version}"
	fi
	os="$(uname -s | tr '[A-Z]' '[a-z]')"
	arch="$(uname -m)"
	case "$arch" in
	x86_64)
		arch=amd64
		;;
	armv[6-7]l)
		arch=armv6l
		;;
	aarch64)
		arch=arm64
		;;
	*)
		echo "error: unsupported arch $arch"
		exit 1
		;;
	esac

	if [[ ! -e /usr/local/$version ]]; then
		print "Fetching $version..."
		tmpdir="$(mktemp -d)"
		(cd $tmpdir;
			fetch https://dl.google.com/go/${version}.${os}-${arch}.tar.gz \
				| tar -xzf -
			mv go /usr/local/$version
			cd .. && rmdir $tmpdir
		)
	fi
	print "Linking $version..."
	(cd /usr/local && unlink go; ln -s $version go)
	(cd /usr/local/bin || exit 1;
		for bin in ../go/bin/*; do
			unlink ${bin:t}
			ln -s $bin ./
		done
	)
	print "Done!"
}

_icanhazip() {
	curl icanhazip.com
}

# ssh-key-modify-comment ~/.ssh/id_ed25519 "Watch out for space dust"
ssh-key-change-comment() {
	local keyfile=$1
	local comment=$2

	# Changing comment (-c) requires the new OpenSSH format (-o converts).
	ssh-keygen -f $keyfile -o -c -C $comment
}

gpg-ssh-list() {
	gpg-connect-agent 'KEYINFO --ssh-list --ssh-fpr' /bye
}
gpg-ssh-delete-key() {
	local keygrip=$1
	gpg-connect-agent "DELETE_KEY $keygrip" /bye
}
