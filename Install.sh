#!/bin/bash

source "InstallerFiles/Utils.sh"

#########################
####### Functions #######
#########################

function copySystemDirectories() {
    local destinationDir="/home/$USER/SmartifyOS/"
    local sourceDir="SmartifyOS/"

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
            echo $progress
            echo "# $((progress))%"
        done | yad --center --progress \
            --text="Copying system files" \
            --width=300 \
            --auto-close
    )

}

function installInstallerDependencies() {
    echo "Updating your system..."

    #sudo apt-get update > /dev/null 2>&1

    echo "Installing installer dependencies..."

    #sudo apt-get install -y yad > /dev/null 2>&1

    echo "Installer dependencies installed!"
}

function installDependencies() {
    echo "Hello World"
}

function configureSudoers() {
    echo "Hello World"
}

function addStartupPrograms() {
    echo "Hello World"
}

function addSystemServices() {
    echo "Hello World"
}

function addUsbEvent() {
    echo "Hello World"
}

function installGnomeExtensions() {
    echo "Hello World"
}

function setBackground() {
    echo "Hello World"
}

function askForReboot() {
    echo "Hello World"
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
installGnomeExtensions

#set background
setBackground

source "InstallAdditions.sh"

#ask for reboot
askForReboot
