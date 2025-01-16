#!/bin/bash

set -euf -o pipefail

#xdotool search --name "StartAndroidAuto" windowminimize //This sometimes stops the script so removed for now

cd ~/SmartifyOS/AndroidAuto/ || exit

./start-android-auto.sh


