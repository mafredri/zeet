#!/usr/bin/env zsh

alias sshf='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# Feature test the --color parameter since busybox
# doesn't support it.
if grep --color=auto test<<<test &>/dev/null; then
	alias grep='grep --color=auto'
fi

# wget http://nion.modprobe.de/mostlike.txt
# tic mostlike.txt && rm mostlike.txt
if test ! $(find $HOME/.terminfo -name mostlike 2>/dev/null); then
	tic $ZSH/misc/mostlike.txt
fi
man() {
	TERMINFO=$HOME/.terminfo LESS=C TERM=mostlike PAGER=less command man $@
}

case $OSTYPE in
	darwin*)
		alias ls='ls -GFh'
		alias srm='rm -P'
		alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
		alias code='code --goto'
		PSQL_EDITOR='code --wait'
		export LESS='-R'

		# Prefer `df` from Homebrew `coreutils`.
		(( $+commands[gdf] )) && alias df=gdf
		(( $+commands[trash] )) && alias trash='trash -F'

		# A site that has previously requested HTTP Strict Transport
		# Security (HSTS) will permanently remain and removing
		# HSTS.plist alone is insufficient as it's cached by
		# nsurlstoraged... real handy. This is annyoing because you can
		# no longer navigate to a http:// URL for the HSTS enabled site,
		# even if the web server is running on a different port.
		_reset_hsts() {
			killall nsurlstoraged
			rm ~/Library/Cookies/HSTS.plist
			launchctl start /System/Library/LaunchAgents/com.apple.nsurlstoraged.plist
		}
		alias reset_hsts='_reset_hsts'

		_battery() {
			# 100%; charged; 0:00 remaining present: true
			# 99%; charged; 0:00 remaining present: true
			# 94%; AC attached; not charging present: true
			pmset -g batt | egrep -o '[0-9:]+ remaining'
		}
		alias battery='_battery'

		# For Homebrew packages.
		export HOMEBREW_EDITOR='code --wait'
		export ANDROID_HOME=/usr/local/opt/android-sdk  # android
		export MONO_GAC_PREFIX=/usr/local               # mono

		if [[ -e /Applications/OpenSCAD.app ]]; then
			alias openscad=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
		fi
		if [[ -e /Applications/YubiKey\ Manager.app ]]; then
			path+=(/Applications/YubiKey\ Manager.app/Contents/MacOS)
		fi
		;;
	linux-gnu*)
		alias ls='ls --color=auto -Fh'
		PSQL_EDITOR='vim'
		;;
esac

# Copy to clipboard on remote machines using OSC 52.
#
# For iTerm2 we must enable:
# Preferences > General > "Applications in terminal may access clipboard"
#
# OSC 52 works in iTerm2, but we could also use the iTerm specific:
# print -n "\e]1337;Copy=;$(base64 $args /dev/stdin)\007"
remote_pbcopy() {
	local copy args=()
	if [[ $OSTYPE != darwin* ]]; then
		# The base64 must be a single line.
		args+=(--wrap=0)
	fi

	# OSC 52 operates the clipboard, c is for copy.
	copy="\e]52;c;$(base64 $args /dev/stdin)"

	if [[ -n $TMUX ]]; then
		# Inside tmux, we must escape the construct.
		copy="\ePtmux;\e$copy\e\e\\\\"
	fi
	print -n "${copy}\e\\"
}

(( $+commands[pbcopy] )) || alias pbcopy=remote_pbcopy
(( $+commands[nvim] )) && alias vim=nvim
(( $+commands[hub] )) && alias git=hub

export PSQL_EDITOR
alias psql='PAGER="less --chop-long-lines" psql'

_godoc-open() {
	open http://localhost:6060/pkg/${PWD#$GOPATH/src/}
}
alias godoc-open="_godoc-open"

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
alias logssh="_logssh"

_todo_or_note() {
	local action=$1; shift
	{rg $action' ?(\([^)]*\)|:)' --pretty "$@" || print "No ${action}s found.\n"} \
		| ${PAGER:-less} -C -R
}
alias todo='_todo_or_note TODO --glob "!vendor/**/*.go"'
alias todo-c='todo -B 3 -A 5'
alias note='_todo_or_note NOTE --glob "!vendor/**/*.go"'
alias note-c='note -B 3 -A 5'

_chrome_runner() { _chrome "$@" &; }
_chrome() {
	setopt localoptions localtraps noshwordsplit

	local chrome=$1; shift
	local userdata=$(mktemp -d)
	local -a default_args=(
		--remote-debugging-port=9222
		--disable-gpu
		--disable-translate
		--disable-sync
		--disable-default-apps
		--no-first-run
		--no-default-browser-check
		--user-data-dir=$userdata
		--window-size=1000,600
	)

	trap 'exit 0' INT
	trap "print chrome: cleaning up...; rm -rf '$userdata'" EXIT
	$chrome $default_args "$@" about:blank
}

alias chrome='_chrome_runner /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias chrome-canary='_chrome_runner /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'

asdev() {
	(source ~/Projects/asustor-packages/.envrc; command asdev $@)
}

install_go() {
	parse() {
		grep -E -o "(go1[^>]*\ \(released [0-9]{4}/[0-9]{2}/[0-9]{2}\))" \
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
	(cd /usr/local && unlink go && ln -s $version go)
	(cd /usr/local/bin || exit 1;
		for bin in ../go/bin/*; do
			unlink ${bin:t}
			ln -s $bin ./
		done
	)
	print "Done!"
}
