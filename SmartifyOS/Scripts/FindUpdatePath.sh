#!/bin/bash

usb_mount_points=$(mount | grep "^/dev/sd" | cut -d' ' -f3)

for mount_point in $usb_mount_points; do
    if [ -d "$mount_point/smartify_os_update" ]; then
        echo "$mount_point/smartify_os_update/"
        exit
    fi
done

echo "not_found"