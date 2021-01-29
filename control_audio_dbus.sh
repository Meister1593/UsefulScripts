#!/bin/bash
# Credits: tonyg - https://gist.github.com/tonyg/1aaf3b62bcb63dc6d626df9d12356125

if [ -z "$1" ]
then
    echo "Usage: MediaPlayer2-cmd { PlayPause | Next | Previous | Stop | ... } { OPTIONAL: All }"
    exit 1
fi

i=0

dbus-send \
	--session \
	--dest=org.freedesktop.DBus \
	--print-reply \
	/org/freedesktop/DBus \
	org.freedesktop.DBus.ListNames | \
	fgrep org.mpris.MediaPlayer2. | \
	awk '{print $2}' | \
       	sed -e 's:"::g' | \
	while read line; do
		echo $i
		if [ $i == 1 ]
		then
			if [ "$2" != "All" ]
			then
				break	
			fi
		fi
		echo $line
		dbus-send \
	    		--print-reply \
	    		--dest=$line \
	    		/org/mpris/MediaPlayer2 \
	    		org.mpris.MediaPlayer2.Player.$1
		let i+=1
	done


