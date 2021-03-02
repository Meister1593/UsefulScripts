
#!/bin/bash

current_dir="$(dirname "$(readlink -f "$0")")"

pkill xidlehook

rm "/tmp/xidlehook.socket"

xidlehook \
	--not-when-fullscreen \
	--not-when-audio \
    --socket "/tmp/xidlehook.socket" \
	--timer 300 "i3lock -n -i $1 --screen 1 --clock --timecolor=#32cd32 --datecolor=#32cd32" "" \
	--timer 15 "xset dpms force off" ""
