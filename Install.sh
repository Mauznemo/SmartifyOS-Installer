#!/bin/bash

source "InstallerFiles/Utils.sh"

#########################
####### Functions #######
#########################

function copySystemDirectories() {
    local destinationDir="$HOME/"
    local sourceDir="SmartifyOS"

    # Ensure destination path exists
    mkdir -p "$destinationDir"

    # Get the total size of the source directory
    local totalFiles=$(find "$sourceDir" -type f | wc -l)

    local files=0

    cp -av "$sourceDir" "$destinationDir" | (
        while read -r line; do
            files=$((files + 1))

            local progress=$(((files * 100) / totalFiles))

            # Update Yad progress bar
            echo "Copying files... $progress% - $files/$totalFiles"
        done
    )

}


function installInstallerDependencies() {
    echo "Updating your system..."

    sudo apt-get update > /dev/null 2>&1

    echo "System updated"
}

function installDependencies() {
    echo "Installing dependencies..."

    # Android Auto dependencies
    sudo apt-get install -y adb libc++1 libc++abi1 tmux > /dev/null 2>&1
    # Gnome extension dependencies
    sudo apt-get install -y gnome-shell-extensions gnome-extensions > /dev/null 2>&1 #gnome-shell-extension-tool

    sudo apt install -y python3 xinput xdotool x11-utils > /dev/null 2>&1

    echo "Dependencies installed"
}

function configureSudoers() {
    echo "Configuring sudoers..."
    # Needed so the Unity app can run sudo commands
    echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$USERNAME

    sudo chmod 0440 /etc/sudoers.d/$USERNAME

    if sudo visudo -c &>/dev/null; then
        echo "Sudoers configured successfully."
    else
        echo -e "${RED}Configuring sudoers failed. Rolling back changes.${RESET}"
        sudo rm -f /etc/sudoers.d/$USERNAME
        exit 1
    fi
}

function addStartupPrograms() {
    echo "Adding startup programs..."

    addStartup "TouchInput" "$HOME/SmartifyOS/Scripts/TouchInput.py"
}


function addSystemServices() {
    echo "Adding system services..."
    addSystemdService "smartify-os" "Smartify OS" "$HOME/SmartifyOS/Scripts/StartSmartifyOS.sh"
}

addUdevUsbRule() {
    local TOUCH_FILE=$1
    local UDEV_RULE_FILE="/etc/udev/rules.d/99-touch-file-on-usb.rules"

    # Check if the file path was provided
    if [ -z "$TOUCH_FILE" ]; then
        echo "Usage: addUdevRule <file-to-touch>"
        return 1
    fi

    # Create the UDEV rule file with the necessary content
    echo 'ACTION=="add", SUBSYSTEM=="usb", RUN+="/usr/bin/touch '$TOUCH_FILE'"' | sudo tee $UDEV_RULE_FILE > /dev/null

    # Reload UDEV rules
    sudo udevadm control --reload-rules

    echo "UDEV rule created and reloaded"
}


function addUsbEvent() {
    echo "Adding USB event..."
    addUdevUsbRule "$HOME/SmartifyOS/Events/OnUsbDeviceConnected"
}


function configureAppearance() {
    echo "Configuring appearance..."

    #Hide desktop icons
    gnome-extensions disable ding@rastersoft.com

    # Hide Dock
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false

    #Hide Top Bar
    gnome-extensions install ./InstallerFiles/hidetopbar@mathieu.bidon.ca.zip
    sleep 5
    gnome-extensions enable hidetopbar@mathieu.bidon.ca

    #gsettings set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
    #gsettings set org.gnome.shell.extensions.hidetopbar enable-intellihide true
    dconf write /org/gnome/shell/extensions/hidetopbar/mouse-sensitive true
    dconf write /org/gnome/shell/extensions/hidetopbar/enable-intellihide false
}

function setBackground() {
    echo "Setting background..."
    # TODO: Set background
}

function askForReboot() {
    read -p "Do you want to reboot now? (y/n): " RESPONSE

    # Convert the response to lowercase
    RESPONSE=$(echo "$RESPONSE" | tr '[:upper:]' '[:lower:]')

    # Check the user's response
    case "$RESPONSE" in
        y|yes)
            echo "Rebooting..."
            sudo reboot
            ;;
        n|no)
            echo "Exiting..."
            ;;
        *)
            echo "Invalid response. Please enter 'y' or 'n'."
            askForReboot
            ;;
    esac
}

#########################
####### Installer #######
#########################

if ! checkInternet; then
    echo "Please connect the Computer to the Internet while running the installer!"
    exit 1
fi

#Install all dependencies need for the Installer
installInstallerDependencies

#Copy system files
copySystemDirectories

#Install all needed software
installDependencies

#Configure system permissions
configureSudoers

#Add startup programs
addStartupPrograms

#Add system services
addSystemServices

#Add USB event
addUsbEvent

#Install gnome extension
configureAppearance

#set background
setBackground

source "InstallAdditions.sh"

#ask for reboot
askForReboot
