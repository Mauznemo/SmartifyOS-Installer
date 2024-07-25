#!/bin/bash

./fullscreen-app.sh 10 "desktop-head-unit" &

#sudo apt install adb libc++1 libc++abi1
./desktop-head-unit -u -c "config/default.ini"

