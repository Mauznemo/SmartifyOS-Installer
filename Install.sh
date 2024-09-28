#!/bin/bash

set -euf -o pipefail

source "InstallerFiles/Utils.sh"

noUpgrade=${1:-}

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
    sudo apt-get install -y adb libc++1 libc++abi1 wmctrl xdotool #> /dev/null 2>&1

    sudo apt-get install -y pulseaudio-utils mpv

    # Dependencies for touch input
    sudo apt-get install -y python3-yaml python3-evdev python3-pynput
    sudo apt install -y xinput

    printBold "Dependencies installed"
}

function configureSudoers() {
    printBold "Configuring sudoers..."
    # Needed so the Unity app can run sudo commands
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$USER

    sudo chmod 0440 /etc/sudoers.d/$USER

    if sudo visudo -c &>/dev/null; then
        printBold "Sudoers configured successfully."
    else
        echo -e "${RED}Configuring sudoers failed. Rolling back changes.${RESET}"
        sudo rm -f /etc/sudoers.d/$USER
        exit 1
    fi

    # Other permissions
    sudo usermod -a -G dialout $USER
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
    addStartup "TouchInput" "$SCRIPT_DIR/StartTouchInput.sh"
    addStartup "SmartifyOS" "$HOME/SmartifyOS/Scripts/StartSmartifyOS.sh"
}

function addUsbEvent() {
    printBold "Adding USB event..."
    addUdevUsbRule "$HOME/SmartifyOS/Events/OnUsbDeviceConnected"
}

function configureSystemSettings()
{
    printBold "Configuring system settings..."

    # Define the config file path
    local CONFIG_FILE="/etc/lightdm/lightdm.conf"

    # Define the lines to add
    local pam_service="pam-service=lightdm"
    local pam_autologin_service="pam-autologin-service=lightdm-autologin"
    local autologin_user="autologin-user=$USER"
    local autologin_timeout="autologin-user-timeout=0"

    # Check if the file contains the "[Seat:*]" section
    if grep -q "^\[Seat:\*\]" "$CONFIG_FILE"; then
        echo "[Seat:*] section found, adding configurations..."

        # Remove old lines if they already exist to prevent duplicates
        sudo sed -i "/pam-service=lightdm/d" "$CONFIG_FILE"
        sudo sed -i "/pam-autologin-service=lightdm-autologin/d" "$CONFIG_FILE"
        sudo sed -i "/autologin-user=/d" "$CONFIG_FILE"
        sudo sed -i "/autologin-user-timeout=/d" "$CONFIG_FILE"

        # Add new configurations under "[Seat:*]"
        sudo sed -i "/^\[Seat:\*\]/a $pam_service\n$pam_autologin_service\n$autologin_user\n$autologin_timeout" "$CONFIG_FILE"
    else
        echo "[Seat:*] section not found, creating it..."

        # Append [Seat:*] section with the required lines
        #echo -e "\n[Seat:*]\n$lines_to_add" >> "$CONFIG_FILE"
        sudo echo -e "\n[Seat:*]\n$pam_service\n$pam_autologin_service\n$autologin_user\n$autologin_timeout" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi

    echo "Configurations added successfully."

    # Replace /etc/default/grub with the new content
    sudo tee /etc/default/grub > /dev/null << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash gfxpayload=text loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 vt.global_cursor_default=0"
GRUB_CMDLINE_LINUX="console=ttyS0"
GRUB_BACKGROUND=""
EOF

    sudo sed -i 's/^quiet_boot="0"/quiet_boot="1"/g' /etc/grub.d/10_linux

    sudo systemctl mask getty@tty1.service
    
    sudo update-grub

    echo "Grub configuration updated successfully!"

    #sudo timedatectl set-ntp false
}

function configureAppearance() {
    printBold "Configuring appearance..."
    sudo sed -i 's/^@lxpanel --profile LXDE/#@lxpanel --profile LXDE/g' $HOME/.config/lxsession/LXDE/autostart
}

function setBackground() {
    printBold "Setting background..."

    sed -i 's/show_trash=1/show_trash=0/' ~/.config/pcmanfm/LXDE/desktop-items-0.conf

    local BACKGROUND_IMAGE="$SCRIPT_DIR/InstallerFiles/SmartifyOS-Background.png"
    pcmanfm --set-wallpaper "$BACKGROUND_IMAGE"
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

#Configure system settings
configureSystemSettings

#Install gnome extension
configureAppearance

#set background
setBackground

source "InstallAdditions.sh"

#ask for reboot
askForReboot
