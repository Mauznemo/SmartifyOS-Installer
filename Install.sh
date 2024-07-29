#!/bin/bash

source "InstallerFiles/Utils.sh"

noUpgrade=$1
#########################
####### Functions #######
#########################

function copySystemDirectories() {
    local destinationDir="$HOME/"
    local sourceDir="SmartifyOS"

    # Ensure destination path exists
    mkdir -p "$destinationDir"

    printBold "Copying system files..."

    cp -a "$sourceDir" "$destinationDir"
}


function installInstallerDependencies() {
    printBold "Updating your system..."

    sudo apt-get update -y

    if [ "$noUpgrade" != "no-upgrade" ]; then
        sudo apt-get upgrade -y
    fi

    printBold "System updated"
}

function installDependencies() {
    printBold "Installing dependencies..."

    # Dependencies for installer
    sudo apt-get install -y libnotify-bin #> /dev/null 2>&1

    # Android Auto dependencies
    sudo apt-get install -y adb libc++1 libc++abi1 tmux xdotool #> /dev/null 2>&1
    # Gnome extension dependencies
    sudo apt-get install -y gnome-shell-extensions gnome-shell-extension-prefs #> /dev/null 2>&1 #gnome-shell-extension-tool

    sudo apt-get install -y pulseaudio-utils mpv

    # Dependencies for touch input
    sudo apt-get install -y python3-yaml python3-evdev python3-pynput

    #sudo apt install -y python3 xinput xdotool x11-utils > /dev/null 2>&1

    printBold "Dependencies installed"
}

function configureSudoers() {
    printBold "Configuring sudoers..."
    # Needed so the Unity app can run sudo commands
    echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$USERNAME

    sudo chmod 0440 /etc/sudoers.d/$USERNAME

    if sudo visudo -c &>/dev/null; then
        printBold "Sudoers configured successfully."
    else
        echo -e "${RED}Configuring sudoers failed. Rolling back changes.${RESET}"
        sudo rm -f /etc/sudoers.d/$USERNAME
        exit 1
    fi

    # Other permissions
    sudo usermod -a -G dialout $USERNAME
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

    printBold "UDEV rule created and reloaded"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function addStartupPrograms() {
    printBold "Adding startup programs..."
    addStartup "Installer" "$SCRIPT_DIR/InstallerFiles/AfterReboot.sh"
    addStartup "TouchInput" "$SCRIPT_DIR/StartTouchInput.sh"
}

function addUsbEvent() {
    printBold "Adding USB event..."
    addUdevUsbRule "$HOME/SmartifyOS/Events/OnUsbDeviceConnected"
}


function configureAppearance() {
    printBold "Configuring appearance..."

    #Hide desktop icons
    gnome-extensions disable ding@rastersoft.com

    # Hide Dock
    sudo rm -rf /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com/

    #Hide Top Bar
    gnome-extensions install ./InstallerFiles/hidetopbar@mathieu.bidon.ca.zip

    #Hide Overview on startup
    gnome-extensions install ./InstallerFiles/no-overview@fthx.zip

    #Disable touch gestures
    gnome-extensions install ./InstallerFiles/disable-gestures.zip
}

function setBackground() {
    printBold "Setting background..."

    sudo cp -r ./InstallerFiles/BootTheme/SmartifyOS/ /usr/share/plymouth/themes/
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/SmartifyOS/SmartifyOS.plymouth 200
    sudo update-initramfs -u

    local BACKGROUND_IMAGE="$SCRIPT_DIR/InstallerFiles/SmartifyOS-Background.png"

    gsettings set org.gnome.desktop.background picture-uri "file://$BACKGROUND_IMAGE"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$BACKGROUND_IMAGE"
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

#Add USB event
addUsbEvent

#Install gnome extension
configureAppearance

#set background
setBackground

source "InstallAdditions.sh"

#ask for reboot
askForReboot
