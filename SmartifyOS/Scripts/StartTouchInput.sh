#!/bin/bash

set -euf -o pipefail

cd ~/SmartifyOS/Scripts/ || exit

sudo python3 TouchInput.py
