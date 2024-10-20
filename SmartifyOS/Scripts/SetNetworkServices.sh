#!/bin/bash

set -euf -o pipefail

ENABLE=$1

if [ -z "$ENABLE" ]; then
    echo "Usage: SetNetworkServices.sh <enable|disable>"
    exit 1
fi

if [ "$ENABLE" = "enable" ]; then
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable networkd-dispatcher.service
    sudo systemctl enable wpa_supplicant.service
else
    sudo systemctl disable NetworkManager.service
    sudo systemctl disable networkd-dispatcher.service
    sudo systemctl disable wpa_supplicant.service
fi
