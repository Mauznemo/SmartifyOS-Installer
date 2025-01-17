#!/bin/bash

set -euf -o pipefail

sudo modprobe v4l2loopback exclusive_caps=1 card_label="Virtual Webcam" max_buffers=8 pixelformats=YUYV,RGB32

python3 "$HOME/SmartifyOS/Scripts/CameraConverter.py"