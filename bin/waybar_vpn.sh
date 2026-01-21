#!/usr/bin/env bash

toggle_vpn() {
    if pgrep -x openconnect > /dev/null; then
        sudo pkill openconnect
    else
        nohup ~/.config/bin/connect_vpn.sh > /dev/null 2>&1 &
    fi
}

get_status() {
    if pgrep -x openconnect > /dev/null; then
        echo '{"text": "󰖂  CONNECTED", "class": "connected", "tooltip": "VPN: Connected (click to disconnect)"}'
    else
        echo '{"text": "󰖂  DISCONNECTED", "class": "disconnected", "tooltip": "VPN: Disconnected (click to connect)"}'
    fi
}

case "$1" in
    toggle)
        toggle_vpn
        ;;
    *)
        get_status
        ;;
esac
