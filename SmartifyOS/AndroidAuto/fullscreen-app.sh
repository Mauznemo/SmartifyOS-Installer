#!/bin/bash

sleep $1

WINDOW_ID=$(xdotool search --class $2)

if [ -z "$WINDOW_ID" ]; then
    echo "Window $2 not found"
    exit 0
fi

echo "Found $WINDOW_ID"

xprop -id "$WINDOW_ID" -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS 2,0,0,0,0

#sudo apt install wmctrl
wmctrl -ir "$WINDOW_ID" -b add,fullscreen
