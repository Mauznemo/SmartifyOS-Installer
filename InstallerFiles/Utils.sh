#!/bin/bash

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
