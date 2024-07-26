#!/bin/bash

ENABLE=$1

if [ -z "$ENABLE" ]; then
    echo "Usage: SetNetworkServices.sh <enable|disable>"
    exit 1
fi

if [ "$ENABLE" = "enable" ]; then
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable networking.service
    sudo systemctl enable wpa_supplicant.service
else
    sudo systemctl disable NetworkManager.service
    sudo systemctl disable networking.service
    sudo systemctl disable wpa_supplicant.service
fi