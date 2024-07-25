#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m' 

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

addSystemdService() {
    local SERVICE_NAME=$1
    local DESCRIPTION=$2
    local SAVE_PATH=$3

    # Check if all required parameters were provided
    if [ -z "$SERVICE_NAME" ] || [ -z "$SAVE_PATH" ]; then
        echo "Usage: addSystemdService <service-name> <description> <exec-path>"
        return 1
    fi

    # Create the systemd service file
    local SERVICE_FILE=/etc/systemd/system/${SERVICE_NAME}.service
    sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=$DESCRIPTION
After=network.target

[Service]
#Environment=DISPLAY=:0
User=$USERNAME
Group=$USERNAME
Type=simple
ExecStart=$SAVE_PATH

[Install]
WantedBy=multi-user.target
EOL

    # Set appropriate permissions
    sudo chmod 644 $SERVICE_FILE

    # Reload systemd to recognize the new service
    sudo systemctl daemon-reload

    # Enable and start the service
    sudo systemctl enable ${SERVICE_NAME}.service
    sudo systemctl start ${SERVICE_NAME}.service

    echo "Systemd service ${SERVICE_NAME} has been created and started."
}