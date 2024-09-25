#!/bin/bash

set -euf -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m' 

printBold() {
    echo -e "${BOLD}$1${RESET}"
}

checkInternet() {
    wget -q --spider http://google.com

    return $?
}

checkOSDirectory() {
    local user_dir="$HOME/SmartifyOS"  # Path to the "OS" directory in the user's home directory

    if [ -d "$user_dir" ]; then
        return 0  # Directory exists
    else
        return 1  # Directory does not exist
    fi
}

removeStartup() {
    local PROGRAM_NAME=$1

    rm -f ~/.config/autostart/"${PROGRAM_NAME}".desktop
}

addStartup() {
    local PROGRAM_NAME=$1
    local COMMAND=$2

    mkdir -p ~/.config/autostart

    # Create the .desktop file
    local DESKTOP_FILE=~/.config/autostart/${PROGRAM_NAME}.desktop
    cat <<EOL > $DESKTOP_FILE
[Desktop Entry]
Type=Application
Exec=$COMMAND
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=$PROGRAM_NAME
Comment=Start $PROGRAM_NAME at login
EOL

    # Set appropriate permissions
    chmod +x $DESKTOP_FILE

    echo "$PROGRAM_NAME has been added to startup programs."
}
