#!/bin/bash

current_dir="$(dirname "$(readlink -f "$0")")"

pkill xidlehook

rm "$current_dir/xidlehook.socket"

xidlehook \
	--not-when-fullscreen \
	--not-when-audio \
	--timer 300 \
		"i3lock -i $1 --screen 1 --clock --timecolor=#32cd32 --datecolor=#32cd32" \
		'' \
	--timer 30 \
		'xset dpms force off' \
		'' \
		--socket "$current_dir/xidlehook.socket"
