#!/bin/bash
#Process names are not case sensitive.
#i.e Discord or NetworkManager, konsole

WindowLabel[0]="blender"
WindowLabel[1]="minecraft"
WindowLabel[2]="r5apex"
WindowLabel[3]="ksp"

# Prep mouse scrolling with button
Mouse='A4TECH USB Device'
xinput set-prop pointer:"$Mouse" 'libinput Button Scrolling Button' 2 

echo "[INFO] [CUSTOM] Starting DoWhileRunning script"

is_scroll_enabled=false

do_this_if_process_is_running() {
# Disable scrolling with middle mouse
xinput set-prop pointer:"$Mouse" 'libinput Scroll Method Enabled' 0 0 0
is_scroll_enabled=false
}

do_this_if_process_is_not_running() {
# Enable scrolling with middle mouse
xinput set-prop pointer:"$Mouse" 'libinput Scroll Method Enabled' 0 0 1
is_scroll_enabled=true
}

get_active_window_name() {
#     echo $(xdotool getactivewindow getwindowname)
#    echo $(xdotool getwindowname $(xdotool getmouselocation --shell | tail -1 | cut -d = -f 2))
	local process_name_unformatted=$(ps -p $(xdotool getwindowpid  $(xdotool getmouselocation --shell | tail -1 | cut -d = -f 2) 2>/dev/null) -o cmd= 2>/dev/null)
	echo	$process_name_unformatted | cut -d ' ' -f1
}

trap do_this_if_process_is_running ERR EXIT
shopt -s nocasematch

while :; do
    for process_name in "${WindowLabel[@]}"; do
        if [[ $(get_active_window_name) == *"$process_name"* ]]; then
            if [ "$is_scroll_enabled" = true ]; then 
                do_this_if_process_is_running 
            fi
            while [[ $(get_active_window_name) == *"$process_name"* ]]; do
                sleep 0.5s ## Sits here while the process is running
            done
        else
            if [ "$is_scroll_enabled" = false ]; then
                do_this_if_process_is_not_running
            fi
        fi
    done
    sleep 2.5s ## How often to delay checking for a process is running
done
