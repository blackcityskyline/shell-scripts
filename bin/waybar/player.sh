#!/bin/bash

player_status=$(playerctl --player=kew,playerctld,%any status 2>/dev/null)

if [[ "$player_status" == "Playing" || "$player_status" == "Paused" ]]; then
	title=$(playerctl --player=kew,playerctld,%any metadata title 2>/dev/null)
	artist=$(playerctl --player=kew,playerctld,%any metadata artist 2>/dev/null)

	text="${title} – ${artist}"
	max_length=20
	[[ ${#text} -gt $max_length ]] && text="${text:0:$max_length}..."

	echo " $text"
else
	echo ""
fi
