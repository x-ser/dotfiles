#!/bin/bash

export TEMP=/tmp

# Define colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Kali Linux Pentest Lab Setup         ${NC}"
echo -e "${CYAN}========================================${NC}"

# ============================================================
# PART 1: PACKAGE INSTALLATION
# ============================================================
echo -e "\n${CYAN}--- [1/2] Starting Package Installation ---${NC}"

# --- Update System
echo -e "${CYAN}Updating system repositories...${NC}"
sudo apt update && sudo apt upgrade -y

# --- VMware Setup
echo -e "${CYAN}Installing VMware tools and setup service...${NC}"
sudo apt install -y \
    open-vm-tools \
    open-vm-tools-desktop
sudo systemctl enable --now open-vm-tools

# --- Base GUI & Window Manager
echo -e "${CYAN}Installing GUI and Desktop environment...${NC}"
sudo apt install -y \
    i3 \
    polybar \
    terminator \
    rofi \
    feh \
    thunar \
    gvfs \
    tumbler \
    thunar-archive-plugin \
    file-roller \
    picom \
    dex \
    xss-lock \
    network-manager-gnome \
    xclip

# --- JetBrains Mono Nerd Font
echo -e "${CYAN}Installing JetBrains Mono Nerd Font...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -O /tmp/JetBrainsMono.tar.xz
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SpaceMono.tar.xz" -O /tmp/SpaceMono.tar.xz
tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
tar -xf /tmp/SpaceMono.tar.xz -C "$FONT_DIR"
fc-cache -fv

# --- Development & Shell
echo -e "${CYAN}Installing development tools and Zsh...${NC}"
sudo apt install -y \
    zsh \
    build-essential \
    clang \
    linux-headers-$(uname -r) \
    python3 \
    python3-pip \
    pipx \
    git \
    wget \
    curl \
    openssl \
    default-jdk \
    rsync \
    firefox-esr \
    mingw-w64 \
    gcc \
    libfaketime \
    ntpsec \
    bat \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting

pipx ensurepath

# --- Starship Prompt
echo -e "${CYAN}Installing Starship prompt...${NC}"
curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- VS Code (Microsoft repo)
echo -e "${CYAN}Installing Visual Studio Code...${NC}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/packages.microsoft.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install -y code

# --- Rust Installation
echo -e "${CYAN}Installing Rust via rustup.rs...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# --- Security Tools
# Note: Kali already includes nmap, john, sqlmap, metasploit-framework, etc.
# This section installs/verifies any that may be missing.
echo -e "${CYAN}Installing/verifying security tools...${NC}"
sudo apt install -y \
    nmap \
    hashcat \
    john \
    openvpn \
    metasploit-framework \
    krb5-user \
    samba \
    ldap-utils \
    bind9-dnsutils \
    sqlmap \
    ffuf \
    gobuster \
    feroxbuster \
    bloodhound \
    bloodhound-ce-python

# --- BloodHound CE Setup (initializes PostgreSQL & Neo4j internally)
echo -e "${CYAN}Initializing BloodHound CE...${NC}"
sudo bloodhound-setup

# --- Rust-based Tools
echo -e "${CYAN}Installing Rust-based tools...${NC}"
cargo install rustscan

git clone --depth 1 https://github.com/0xfalafel/rcat.git $TEMP/rcat
cargo install --path $TEMP/rcat

git clone --depth 1 https://github.com/g0h4n/RustHound-CE.git $TEMP/RustHound-CE
cargo install --path $TEMP/RustHound-CE

# --- Python Tools via pipx
echo -e "${CYAN}Installing Python pentest tools via pipx...${NC}"
git clone --depth 1 https://github.com/fortra/impacket.git $TEMP/impacket
pipx install $TEMP/impacket

git clone --depth 1 https://github.com/Pennyw0rth/NetExec.git $TEMP/NetExec
pipx install $TEMP/NetExec

git clone --depth 1 https://github.com/p0dalirius/smbclient-ng.git $TEMP/smbclient-ng
pipx install $TEMP/smbclient-ng

git clone --depth 1 https://github.com/adityatelange/evil-winrm-py.git $TEMP/evil-winrm-py
pipx install $TEMP/evil-winrm-py

git clone --depth 1 https://github.com/cddmp/enum4linux-ng.git $TEMP/enum4linux-ng
pipx install $TEMP/enum4linux-ng

git clone --depth 1 https://github.com/ly4k/Certipy.git $TEMP/Certipy
pipx install $TEMP/Certipy

# --- Ligolo-ng (pivoting proxy)
echo -e "${CYAN}Installing ligolo-ng proxy...${NC}"
LIGOLO_VER=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')
wget -q "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_proxy_${LIGOLO_VER#v}_linux_amd64.tar.gz" -O /tmp/ligolo-proxy.tar.gz
tar -xf /tmp/ligolo-proxy.tar.gz -C /tmp
sudo mv /tmp/proxy /usr/local/bin/ligolo-proxy
wget -q "https://github.com/nicocha30/ligolo-ng/releases/download/${LIGOLO_VER}/ligolo-ng_agent_${LIGOLO_VER#v}_linux_amd64.tar.gz" -O /tmp/ligolo-agent.tar.gz
tar -xf /tmp/ligolo-agent.tar.gz -C /tmp
mv /tmp/agent "$HOME/.local/bin/ligolo-agent"

# --- Oh My Zsh
echo -e "${CYAN}Installing Oh My Zsh...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# --- Pentest Tweaks: Allow opening ports < 1024 without root
echo -e "${CYAN}Configuring unprivileged ports...${NC}"
echo 'net.ipv4.ip_unprivileged_port_start=0' | sudo tee /etc/sysctl.d/50-unprivileged-ports.conf > /dev/null
sudo sysctl --system > /dev/null

echo -e "${CYAN}--- Package Installation Complete! ---${NC}"

# ============================================================
# PART 2: DOTFILES INSTALLATION
# ============================================================
echo -e "\n${YELLOW}--- [2/2] Installing Dotfiles ---${NC}"

# --- Create directory structure
echo -e "${YELLOW}Creating config directories...${NC}"
mkdir -p ~/.config/i3/wallpaper
mkdir -p ~/.config/polybar/scripts
mkdir -p ~/.config/terminator
mkdir -p ~/.config/rofi
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/starship
mkdir -p ~/.config/picom
mkdir -p ~/.config/Thunar
mkdir -p ~/htb/vpn

# --- Copy config files
echo -e "${YELLOW}Copying configuration files...${NC}"
cp -rv config/i3 ~/.config
cp -rv config/polybar ~/.config
cp -rv config/starship ~/.config
cp -rv config/picom ~/.config
cp -rv config/Thunar ~/.config
cp config/terminator/config ~/.config/terminator/config
cp config/rofi/config.rasi ~/.config/rofi/config.rasi
cp config/gtk-3.0/gtk.css ~/.config/gtk-3.0/gtk.css
cp .zshrc ~/.zshrc

# --- Make scripts executable
echo -e "${YELLOW}Setting script permissions...${NC}"
chmod +x ~/.config/i3/clipboard.sh
chmod +x ~/.config/i3/pentest.sh
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/scripts/net_stat.sh

# --- Initialize target file for polybar
echo "None" > ~/.config/polybar/.current_target

# --- Set Zsh as default shell (Oh My Zsh may have already done this)
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
fi

# --- Cleanup temp build files
echo -e "${YELLOW}Cleaning up temp files...${NC}"
rm -rf $TEMP/rcat $TEMP/RustHound-CE $TEMP/impacket $TEMP/NetExec \
       $TEMP/smbclient-ng $TEMP/evil-winrm-py $TEMP/enum4linux-ng \
       $TEMP/Certipy /tmp/JetBrainsMono.tar.xz \
       /tmp/ligolo-proxy.tar.gz /tmp/ligolo-agent.tar.gz

echo -e "${YELLOW}--- Dotfiles Installation Complete! ---${NC}"

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}   Setup Finished!                      ${NC}"
echo -e "${CYAN}   NOTE: Place wallpaper at ~/.config/i3/wallpaper/catgirl.jpg${NC}"
echo -e "${CYAN}   NOTE: Place HTB .ovpn file in ~/htb/vpn/${NC}"
echo -e "${CYAN}   Please reboot or reload i3 (Alt+Shift+R)${NC}"
echo -e "${CYAN}========================================${NC}"
