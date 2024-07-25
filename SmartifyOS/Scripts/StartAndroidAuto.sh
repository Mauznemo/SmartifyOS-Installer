#!/bin/bash

cd ~/SmartifyOs/AndroidAuto/ || exit

tmux new-session -d -s aa_session './start-android-auto.sh'


