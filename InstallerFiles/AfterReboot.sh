#!/bin/bash

set -euf -o pipefail

source "Utils.sh"

addStartup "SmartifyOS" "$HOME/SmartifyOS/Scripts/StartSmartifyOS.sh"

gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable no-overview@fthx
gnome-extensions enable disable-gestures@mauznemo.de

dconf write /org/gnome/shell/extensions/hidetopbar/mouse-sensitive true
dconf write /org/gnome/shell/extensions/hidetopbar/enable-intellihide false


sleep 5

removeStartup "Installer"

notify-send -a "SmartifyOS" "Installation complete! Please reboot one more time"
