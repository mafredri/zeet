#!/usr/bin/env zsh

typeset -A pure_halloween_kiss_color_scheme
pure_halloween_kiss_color_scheme=(
        color1 "#E84000" # Tangelo
        color2 "#EB6123" # Halloween Orange
        color3 "#FFE5D5" # Flesh
        color4 "#F1B111" # Spanish Yellow
        color5 "#FF1A72" # Electric Pink
	color6 "#E40055" # Raspberry
)

typeset -A pure_halloween_love_color_scheme
pure_halloween_love_color_scheme=(
        color1 "#D94E49" # English Vermillion
        color2 "#363B3F" # Onyx
        color3 "#EE7867" # Coral Reef
        color4 "#F2C359" # Maize (Crayola)
        color5 "#E2B44E" # Sunray
        color6 "#494F55" # Quartz
)

pure_set_halloween_color_scheme() {
	typeset -A pure_theme
	pure_theme=("$@")

	zstyle :prompt:pure:execution_time      color $pure_theme[color3]
	zstyle :prompt:pure:git:arrow           color $pure_theme[color5]
	zstyle :prompt:pure:git:branch          color $pure_theme[color2]
	zstyle :prompt:pure:git:branch:cached   color $pure_theme[color1]
	zstyle :prompt:pure:git:dirty           color $pure_theme[color4]
	zstyle :prompt:pure:host                color $pure_theme[color6]
	zstyle :prompt:pure:path                color $pure_theme[color1]
	zstyle :prompt:pure:prompt:error        color $pure_theme[color1]
	zstyle :prompt:pure:prompt:success      color $pure_theme[color4]
	zstyle :prompt:pure:user                color $pure_theme[color4]
	zstyle :prompt:pure:user:root           color $pure_theme[color3]
	zstyle :prompt:pure:virtualenv          color $pure_theme[color6]
}

pure_unset_halloween_color_scheme() {
	# TODO(mafredri): Restore previous theme instead of resetting to defaults.
	zstyle -d :prompt:pure:execution_time      color
	zstyle -d :prompt:pure:git:arrow           color
	zstyle -d :prompt:pure:git:branch          color
	zstyle -d :prompt:pure:git:branch:cached   color
	zstyle -d :prompt:pure:git:dirty           color
	zstyle -d :prompt:pure:host                color
	zstyle -d :prompt:pure:path                color
	zstyle -d :prompt:pure:prompt:error        color
	zstyle -d :prompt:pure:prompt:success      color
	zstyle -d :prompt:pure:user                color
	zstyle -d :prompt:pure:user:root           color
	zstyle -d :prompt:pure:virtualenv          color
}

integer _pure_apply_custom_theme_init
typeset -A pure_apply_custom_theme_restore
pure_apply_custom_theme() {
	typeset -A current_date
	current_date=($(date +'month '%m' day '%d))
	if (( current_date[month] == 10 )) && (( current_date[day] >= 20 )); then
		pure_apply_custom_theme_restore[unset_theme]=pure_unset_halloween_color_scheme
		pure_set_halloween_color_scheme ${(kv)pure_halloween_kiss_color_scheme}
		if (( current_date[day] == 31 )); then
			pure_apply_custom_theme_restore+=(
				symbol "$PURE_PROMPT_SYMBOL"
				rprompt "$RPROMPT"
			)
			if [[ -z $TMUX ]]; then
				# 🧛🏻‍♀️
				RPROMPT=$'%2{\U1F9DB\U1F3FB\U200D\U2640\UFE0F%}'
				PURE_PROMPT_SYMBOL=$'%2{\U1F9DB\U1F3FB\U200D\U2640\UFE0F%} ❯'
			else
				# Tmux does not support ZWJ
				# 🧛
				RPROMPT=$'%2{\U1F9DB%}'
				PURE_PROMPT_SYMBOL=$'%2{\U1F9DB%} ❯'
			fi
		fi
	else
		$pure_apply_custom_theme_restore[unset_theme]
		if [[ -n $pure_apply_custom_theme_restore[symbol] ]]; then
			PURE_PROMPT_SYMBOL=$pure_apply_custom_theme_restore[symbol]
		else
			unset PURE_PROMPT_SYMBOL
		fi
		if [[ -n $pure_apply_custom_theme_restore[rprompt] ]]; then
			RPROMPT=$pure_apply_custom_theme_restore[rprompt]
		else
			unset RPROMPT
		fi
		pure_apply_custom_theme_restore=()
	fi
	if ((!_pure_apply_custom_theme_init)); then
		_pure_apply_custom_theme_init=1
		zmodload zsh/sched
	fi

	# Apply custom theme every day at midnight.
	sched 00:00 pure_apply_custom_theme
}

autoload -Uz is-at-least
# Avoid using hex colors on old version of zsh (not supported).
if is-at-least 5.7; then
	pure_apply_custom_theme
fi
