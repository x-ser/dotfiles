#!/bin/bash

# Configuration: Use your Polybar theme colors
# Replace with your actual hex codes if these variables aren't recognized
PRIMARY="#7aa2f7"
WHITE="#FFFFFF"

# Define the icons
VPN_ICON="󰞇"
ETH_ICON="󰖟"
DOWN_ICON="󰇚"
UP_ICON="󰇛"

if ip addr show tun0 >/dev/null 2>&1; then
    # VPN Stats
    IP=$(ip addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    RX=$(cat /sys/class/net/tun0/statistics/rx_bytes | numfmt --to=iec)
    TX=$(cat /sys/class/net/tun0/statistics/tx_bytes | numfmt --to=iec)
    echo "%{F$PRIMARY}$VPN_ICON %{F$WHITE}$IP  %{F$PRIMARY}$DOWN_ICON %{F$WHITE}$RX %{F$PRIMARY}$UP_ICON %{F$WHITE}$TX"
else
    # Local Ethernet Stats
    IP=$(ip addr show ens33 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "Offline")
    RX=$(cat /sys/class/net/ens33/statistics/rx_bytes 2>/dev/null | numfmt --to=iec || echo "0")
    TX=$(cat /sys/class/net/ens33/statistics/tx_bytes 2>/dev/null | numfmt --to=iec || echo "0")
    echo "%{F$PRIMARY}$ETH_ICON %{F$WHITE}$IP  %{F$PRIMARY}$DOWN_ICON %{F$WHITE}$RX %{F$PRIMARY}$UP_ICON %{F$WHITE}$TX"
fi