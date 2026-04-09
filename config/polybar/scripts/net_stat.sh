#!/bin/bash

PRIMARY="#888888"
WHITE="#c8c8c8"

VPN_ICON="󰞇"
ETH_ICON="󰖟"
DOWN_ICON="󰇚"
UP_ICON="󰇛"

# Detect active ethernet interface (Kali may use eth0 or ens33)
get_eth_iface() {
    for iface in eth0 ens33 ens3 enp0s3; do
        if ip link show "$iface" >/dev/null 2>&1; then
            echo "$iface"
            return
        fi
    done
    echo ""
}

if ip addr show tun0 >/dev/null 2>&1; then
    # VPN Stats
    IP=$(ip addr show tun0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    RX=$(cat /sys/class/net/tun0/statistics/rx_bytes | numfmt --to=iec)
    TX=$(cat /sys/class/net/tun0/statistics/tx_bytes | numfmt --to=iec)
    echo "%{F$PRIMARY}$VPN_ICON %{F$WHITE}$IP  %{F$PRIMARY}$DOWN_ICON %{F$WHITE}$RX %{F$PRIMARY}$UP_ICON %{F$WHITE}$TX"
else
    # Local Ethernet Stats
    IFACE=$(get_eth_iface)
    if [ -n "$IFACE" ]; then
        IP=$(ip addr show "$IFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "Offline")
        RX=$(cat /sys/class/net/"$IFACE"/statistics/rx_bytes 2>/dev/null | numfmt --to=iec || echo "0")
        TX=$(cat /sys/class/net/"$IFACE"/statistics/tx_bytes 2>/dev/null | numfmt --to=iec || echo "0")
        echo "%{F$PRIMARY}$ETH_ICON %{F$WHITE}$IP  %{F$PRIMARY}$DOWN_ICON %{F$WHITE}$RX %{F$PRIMARY}$UP_ICON %{F$WHITE}$TX"
    else
        echo "%{F$PRIMARY}$ETH_ICON %{F$WHITE}Offline"
    fi
fi
