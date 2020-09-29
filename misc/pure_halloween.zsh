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
	typeset -A pure_theme=(${(kv)pure_halloween_kiss_color_scheme})

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

typeset -A current_date
current_date=($(date +'month '%m' day '%d))
if (( current_date[month] == 10 )) && (( current_date[day] >= 20 )); then
	pure_set_halloween_color_scheme
fi
