#!/usr/bin/env zsh

export PSQL_EDITOR='code --wait'
export LESS='-R'

# For Homebrew packages.
export HOMEBREW_EDITOR='code --wait'
export ANDROID_HOME=/usr/local/opt/android-sdk # android
export MONO_GAC_PREFIX=/usr/local              # mono

alias ls='ls -GFh'
alias srm='rm -P'
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias code='code --goto'

alias reset_hsts='_reset_hsts'
alias battery='_battery'
alias backup_enable_NOS='_backup_enable_NOS'
alias flush_dns='_flush_dns'

if [[ -e /Applications/OpenSCAD.app ]]; then
	alias openscad=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
fi
if [[ -e /Applications/YubiKey\ Manager.app ]]; then
	path+=(/Applications/YubiKey\ Manager.app/Contents/MacOS)
fi

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
	sudo renice -n -19 -p $(pgrep backupd\$)
	sudo renice -n -19 -p $(pgrep diskimages-helper\$)
}

_flush_dns() {
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}
