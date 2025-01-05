#!/bin/bash

set -euf -o pipefail

ENABLE=$1

if [ -z "$ENABLE" ]; then
    echo "Usage: SetCursor.sh <enable|disable>"
    exit 1
fi

if [ "$ENABLE" = "enable" ]; then
    sudo sed -i 's/xserver-command=X/xserver-command=X -nocursor/' /etc/lightdm/lightdm.conf
else
    sudo sed -i 's/xserver-command=X -nocursor/xserver-command=X/' /etc/lightdm/lightdm.conf
fi

echo "Reboot your computer to apply the changes."
