#!/bin/bash

# Define colors for output
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting Dotfiles Installation...${NC}"

# 1. Create directory structure
echo -e "${YELLOW}Creating config directories...${NC}"
mkdir -p ~/.config/i3
mkdir -p ~/.config/polybar
mkdir -p ~/.config/terminator
mkdir -p ~/.config/rofi
mkdir -p ~/.config/gtk-3.0

# 2. Copy config file
echo -e "${YELLOW}Copy configuration files...${NC}"
cp -rv config/i3 ~/.config
cp -rv config/polybar ~/.config
cp -rv config/starship ~/.config
cp -rv config/picom ~/.config
cp -rv config/Thunar ~/.config
cp config/terminator/config ~/.config/terminator/config
cp config/rofi/config.rasi ~/.config/rofi/config.rasi
cp config/gtk-3.0/gtk.css ~/.config/gtk-3.0/gtk.css
cp .zshrc ~/.zshrc

# 3. Set Zsh as default shell
chsh -s $(which zsh)

echo -e "${YELLOW}Installation Complete! Please reload i3 ($mod+Shift+R).${NC}"
