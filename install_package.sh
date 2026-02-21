#!/bin/bash

export TEMP=/tmp

# Define colors for output
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}--- Starting Pentest Lab Package Installation ---${NC}"

# --- Update System
echo -e "${CYAN}Updating system repositories...${NC}"
sudo pacman -Syu --noconfirm

# --- VMware Setup
echo -e "${CYAN}Installing Vmware tools and Setup service...${NC}"
sudo pacman -S --needed --noconfirm \
    open-vm-tools \
    gtkmm3
sudo systemctl enable --now vmtoolsd.service
sudo systemctl enable --now vmware-vmblock-fuse.service

# --- Base GUI & Window Manager
echo -e "${CYAN}Installing GUI and Desktop environment...${NC}"
sudo pacman -S --needed --noconfirm \
    i3-wm \
    polybar \
    terminator \
    rofi \
    feh \
    ttf-jetbrains-mono-nerd \
    thunar \
    gvfs \
    tumbler \
    thunar-archive-plugin \
    file-roller \
    picom

# --- Development & Shell
echo -e "${CYAN}Installing development tools and Zsh...${NC}"
sudo pacman -S --needed --noconfirm \
    zsh \
    base-devel \
    clang \
    linux-headers \
    starship \
    python \
    python-pip \
    python-pipx \
    code \
    git \
    wget \
    curl \
    openssl \
    zlib \
    libffi \
    mpdecimal \
    pocl \
    jre21-openjdk \
    rsync \
    firefox 

pipx ensurepath

# --- Rust Installation (Official Script)
echo -e "${CYAN}Installing Rust via rustup.rs...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# --- Tools
echo -e "${CYAN}Installing core security tools...${NC}"
sudo pacman -S --needed --noconfirm \
    nmap \
    hashcat \
    john \
    openvpn \
    metasploit \
    krb5 \
    samba \
    openldap \
    dnsutils \
    sqlmap \
    ntp \
    libfaketime

# --- yay
cd $TEMP && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm

# --- yay repo
yay -S --needed --noconfirm \
    python313 \
    ffuf

# --- More tools
cargo install rustscan

git clone https://github.com/0xfalafel/rcat.git $TEMP/rcat
cargo install --path $TEMP/rcat

git clone https://github.com/g0h4n/RustHound-CE.git $TEMP/RustHound-CE
cargo install --path $TEMP/RustHound-CE

git clone https://github.com/fortra/impacket.git $TEMP/impacket
pipx install $TEMP/impacket

git clone https://github.com/Pennyw0rth/NetExec.git $TEMP/NetExec
pipx install $TEMP/NetExec --python python3.13

git clone https://github.com/p0dalirius/smbclient-ng.git $TEMP/smbclient-ng
pipx install $TEMP/smbclient-ng

git clone https://github.com/adityatelange/evil-winrm-py.git $TEMP/evil-winrm-py
pipx install $TEMP/evil-winrm-py

git clone https://github.com/cddmp/enum4linux-ng.git $TEMP/enum4linux-ng
pipx install $TEMP/enum4linux-ng

echo -e "${CYAN}--- Package Installation Complete! ---${NC}"


# --- Pentest Tweaks: Allow opening ports < 1024 without root
echo "[*] Configuring unprivileged ports..."

echo 'net.ipv4.ip_unprivileged_port_start=0' | sudo tee /etc/sysctl.d/50-unprivileged-ports.conf > /dev/null
sudo sysctl --system > /dev/null

echo "[+] Port configuration applied successfully!"
