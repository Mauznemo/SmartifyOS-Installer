#!/bin/bash

source "InstallerFiles/Utils.sh"


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
    1 "Install OpenRGB and .Net (for unity communication with OpenRGB)"
    2 "Install USB camera Patch (coverts the camera format to one that is readable by unity)"
)

# Display the checklist dialog
selected=$(yad --center --text="Select additional things you want to install" --list --checklist --title="Select Options" --column="Selected" --column="Option" "${items[@]}" --width=800 --height=300 --separator=",")

# Check if the user pressed "Cancel"
if [ $? -eq 0 ]; then
    echo "You selected: $selected"
else
    echo "No selection made."
fi
