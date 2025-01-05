#!/bin/bash

set -euf -o pipefail

xdotool search --name "StartAndroidAuto" windowminimize

cd ~/SmartifyOS/AndroidAuto/ || exit

./start-android-auto.sh


