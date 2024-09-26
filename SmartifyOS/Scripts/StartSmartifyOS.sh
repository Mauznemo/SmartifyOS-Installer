#!/bin/bash

set -euf -o pipefail

cd "$HOME/SmartifyOS/GUI/" || exit

nohup ./SmartifyOS.x86_64 &
