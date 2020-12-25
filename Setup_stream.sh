pactl load-module module-null-sink sink_name=game_sink sink_properties=device.d$
pacmd load-module module-loopback source="game_sink.monitor" sink="bluez_sink.1$

pactl load-module module-null-sink sink_name=discord_sink sink_properties=devic$
pacmd load-module module-loopback source="discord_sink.monitor" sink="bluez_sin$

