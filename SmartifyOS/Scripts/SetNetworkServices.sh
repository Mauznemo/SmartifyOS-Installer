#!/bin/bash

set -euf -o pipefail

ENABLE=$1

if [ -z "$ENABLE" ]; then
    echo "Usage: SetNetworkServices.sh <enable|disable>"
    exit 1
fi

if [ "$ENABLE" = "enable" ]; then
    sudo systemctl enable networking.service
else
    sudo systemctl disable networking.service
fi
