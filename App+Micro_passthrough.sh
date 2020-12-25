#!/bin/bash

# This is a handy script to pass audio from game/browser/etc to your microphone consumer
# To list sinks write in terminal: pactl list short sinks
# To list sources write in terminal: pactl list short sources
# To list modules (including loopbacks) write in terminal: pactl list short modules
# To unload module use id of sink/source/module from above and write in terminal: pactl unload-module id
#
# Change microphone_source and main_sound_sink to yours (you can get them using commands above)
#
# To use this script, you need to run it inside terminal (or else you will have a bad time cleaning all loopbacks/null sinks and etc)
# and then using something like Pavucontrol reroute game/browser/anything Playback (pavucontrol) to Recording_Output
# after that, you need to use Combined_Output in your Recording (pavucontrol) of your app (discord is WebRtc while you in voice chat)
# Upd: Now you can use $remapped_combined_source as microphone in any app without pavucontrol/etc! (though, you still need to choose app to record from in pavucontrol/etc)
# Upd: You can now use this with just icon! Left click for load/unload modules on-the-go
#
# Hope this script helped you!

combined_output="CombinedOutput"
recording_output="RecordingOutput"
remapped_combined_source="RemappedCombinedSource"
# Microphone source name
microphone_source="alsa_input.pci-0000_08_00.3.analog-stereo"
# Main sound sink choose
echo "Choose sink, 1 - bluetooth, 2 - cable input"
read sink
if [[ $sink == "1" ]]; then
	main_sound_sink="bluez_sink.18_11_24_27_08_DD.a2dp_sink"
else 
	main_sound_sink="alsa_output.pci-0000_08_00.3.analog-stereo"
fi

modules_error_array=()

switch_modules=false

unload_modules(){
    pactl list short modules | grep "source_name=$remapped_combined_source master=$combined_output.monitor"             | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "source=$recording_output.monitor sink=$main_sound_sink"                            | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "source=$recording_output.monitor sink=$combined_output"                            | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "source=$microphone_source sink=$combined_output"                                   | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "source_name=$microphone_source"                                                    | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "sink_name=$recording_output sink_properties=device.description=$recording_output"  | cut -f1 | xargs -L1 pactl unload-module
    pactl list short modules | grep "sink_name=$combined_output sink_properties=device.description=$combined_output"    | cut -f1 | xargs -L1 pactl unload-module
    sleep 1
    pactl set-source-volume $microphone_source "$microphone_volume%"
}
microphone_volume=$(pactl list sources | grep '^[[:space:]]Volume:' | head -n $(( $(pactl list short sources | grep "$microphone_source" | cut -f1) + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
load_modules(){
        microphone_volume=$(pactl list sources | grep '^[[:space:]]Volume:' | head -n $(( $(pactl list short sources | grep "$microphone_source" | cut -f1) + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
        #echo "Volume is: $microphone_volume%"
        # Combined output which would accept sound from microphone and recording output (game/browser/app)
        pactl load-module module-null-sink      sink_name=$combined_output              sink_properties=device.description=$combined_output
        modules_error_array+=($?)
        # Recording output which would have monitor that would accept sound from (game/browser/app)
        pactl load-module module-null-sink      sink_name=$recording_output             sink_properties=device.description=$recording_output
        modules_error_array+=($?)
        # Loopback from microphone to combined output
        pactl load-module module-loopback       source=$microphone_source               sink=$combined_output
        modules_error_array+=($?)
        # Loopack from recording (game/browser/app) to combined output
        pactl load-module module-loopback       source="$recording_output.monitor"      sink=$combined_output
        modules_error_array+=($?)
        # Loopback from recording (game/browser/app) to headphones/main sound
        pactl load-module module-loopback       source="$recording_output.monitor"      sink=$main_sound_sink                                         
        modules_error_array+=($?)
        # Final module, now you can use this as real microphone anywhere
        pactl load-module module-remap-source   source_name=$remapped_combined_source   master="$combined_output.monitor"
        modules_error_array+=($?)
        # Fix volume of microphone to be as needed
        sleep 1
        pactl set-source-volume $microphone_source "$microphone_volume%"
        modules_error_array+=($?)
        i=0
        for module_err in "${modules_error_array[@]}"; do
            (( i++ ))
            if [[ $module_err -ne 0 ]]; then
                echo "Module $i error $module_err, unloading all modules."
                modules_exit_unload 1
            fi
        done
        modules_error_array=()
}

modules_exit_unload(){
    if [ "$switch_modules" = false ]; then
        echo "Exiting, modules unloaded, just exit"
        exit $1
    else
        echo "Exiting, modules loaded, unloading"
        unload_modules
        exit $1
    fi
}

echo "Initial modules unload"
unload_modules

# Unload modules in case of program terminates
trap modules_exit_unload ERR EXIT

while true; do
    if [ "$switch_modules" = false ]; then
        yad --notification --menu='Modules unloaded, left click on icon to load'
        load_modules 
        switch_modules=true
    else 
        yad --notification  --menu='Modules loaded, left click on icon to load'
        unload_modules
        switch_modules=false
    fi
done
