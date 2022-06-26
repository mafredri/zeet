#!/usr/bin/env zsh

export LESS='-R'
export PSQL_EDITOR='code --wait'
export HOMEBREW_EDITOR='code --wait'

alias ls='ls -GFh'
alias srm='rm -P'
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias plcat='plutil -convert xml1 -o -'

alias code='_code'

alias reset_hsts='_reset_hsts'
alias battery='_battery'
alias backup_enable_NOS='_backup_enable_NOS'
alias flush_dns='_flush_dns'

alias chrome='_chrome_runner /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias chromium='_chrome_runner /Applications/Chromium.app/Contents/MacOS/Chromium'
alias chrome-canary='_chrome_runner /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'

if [[ -e /Applications/OpenSCAD.app ]]; then
	alias openscad=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
fi
if [[ -e /Applications/YubiKey\ Manager.app ]]; then
	path+=(/Applications/YubiKey\ Manager.app/Contents/MacOS)
fi

# Prefer `df` from Homebrew `coreutils`.
(($+commands[gdf])) && alias df=gdf
(($+commands[trash])) && alias trash='trash -F'

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

_battery() {
	# 100%; charged; 0:00 remaining present: true
	# 99%; charged; 0:00 remaining present: true
	# 94%; AC attached; not charging present: true
	pmset -g batt | egrep -o '[0-9:]+ remaining'
}

# Speed up Time Machine backups by allowing it to use
# more resources.
_backup_enable_NOS() {
	# TODO(maf): Start backup if one isn't running?
	sudo sysctl -w debug.lowpri_throttle_enabled=0
	sudo renice -19 -p $(pgrep backupd\$)
	sudo renice -19 -p $(pgrep backupd-helper\$)
	sudo renice -19 -p $(pgrep diskimages-helper\$)
	sudo renice -19 -p $(pgrep fsck_hfs\$)
	sudo renice -19 -p $(pgrep fsck_apfs\$)
	sudo renice -19 -p $(pgrep mds\$)
}

_flush_dns() {
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}

_code() {
	if ((${#@} == 0)); then
		if git rev-parse --is-inside-work-tree &>/dev/null; then
			# No args, open git root.
			command code "$(git rev-parse --show-toplevel)"
			return
		fi
		1=. # No args, open current folder.
	fi
	command code --goto "$@"
}

_chrome_runner() {
	_chrome "$@" &
}
_chrome() {
	setopt localoptions localtraps noshwordsplit

	local chrome=$1
	shift
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
