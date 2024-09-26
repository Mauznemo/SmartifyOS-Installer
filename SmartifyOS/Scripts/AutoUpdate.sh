#!/bin/bash

set -euf -o pipefail

UPDATE_PATH=$1

if [ -z "$UPDATE_PATH" ]; then
    echo "Usage: AutoUpdate.sh <update_path>"
    exit 1
fi

# Wait for the Unity app to close
sleep 5

echo "Installing Update"

rsync -ah --info=progress2 "$UPDATE_PATH" "$HOME/SmartifyOS/GUI/"

echo "Making file executable"
chmod +x "$HOME/SmartifyOS/GUI/SmartifyOS.x86_64"

echo "Starting System"

sleep 1

cd "$HOME/SmartifyOS/GUI/" || exit
nohup ./SmartifyOS.x86_64 &
