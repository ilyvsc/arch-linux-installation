#!/bin/bash

function verify_internet_connection() {
    if ping -c2 archlinux.org > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function connect_internet() {
    if verify_internet_connection; then
        echo "Internet connection successful."
    else
        # Find the WiFi adapter (wlan) usually `wlan0`
        adapter=$(iwctl device list | grep -i wlan | awk '{print $2}')
        if [ -z "$adapter" ]; then
            echo "No WiFi adapter found."
            return 1
        fi

        read -p "Enter the network name (SSID): " network
        read -s -p "Enter the WiFi password: " password
        echo

        echo "Connecting to '$network'..."
        if iwctl --passphrase "$password" station "$adapter" connect "$network"; then
            echo "Connecting..."
            sleep 5
            verify_internet_connection
        else
            echo "Failed to connect."
            return 1
        fi
    fi
}

connect_internet
