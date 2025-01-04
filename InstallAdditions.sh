#!/bin/bash

set -euf -o pipefail

source "InstallerFiles/Utils.sh"
    
function installCameraPatch()
{
    echo "Installing dependencies..."

    sudo apt-get install -y ffmpeg v4l2loopback-dkms #> /dev/null 2>&1

    echo "Installing camera patch..."
    local destinationDir="$HOME/"
    local sourceDir="Additionals/CameraPatch/SmartifyOS"

    cp -r "$sourceDir" "$destinationDir"

    addStartup "StartCameraConverter" "$HOME/SmartifyOS/Scripts/StartCameraConverter.sh"
}

function installAndroidAuto()
{
    echo "Installing dependencies..."

    sudo apt-get install -y adb libc++1 libc++abi1 wmctrl xdotool

    echo "Installing Android Auto..."
    local destinationDir="$HOME/"
    local sourceDir="Additionals/AndroidAuto/SmartifyOS"

    cp -r "$sourceDir" "$destinationDir"
}

function setPermissions() {
    echo "Setting permissions..."

    find $HOME/SmartifyOS/ -name "*.sh" -exec chmod +x {} \;
    find $HOME/SmartifyOS/ -name "*.py" -exec chmod +x {} \;
}

if ! checkInternet; then
    echo "Please connect the Computer to the Internet while running the installer!"
    exit 1
fi

if ! checkOSDirectory; then
    echo "Please run the main installer before installing additional software"
    exit 1
fi

# Define the items for the checklist
items=(
    1 "Android Auto"
    2 "Install USB camera Patch (coverts the camera format to one that is readable by unity)"
)

printf "\n\n\n"

echo -e "${BOLD}Please select additional options to install (separated by space, Enter for none):${RESET}"
for i in "${!items[@]}"; do
    if [[ $((i % 2)) -eq 0 ]]; then
        printf "%s. %s\n" "${items[$i]}" "${items[$((i + 1))]}"
    fi
done

printf "\n"

# Read user input
read -p "Enter your choices: " -a selections

# Process each selected option
for selection in "${selections[@]}"; do
    case $selection in
        1)
            echo "Installing Android Auto..."
            installAndroidAuto
            setPermissions
            ;;
        2)
            echo "Installing Camera patch..."
            installCameraPatch
            setPermissions
            ;;
        *)
            echo "Invalid selection: $selection"
            ;;
    esac
done
