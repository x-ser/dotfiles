# --- Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Disabled — using Starship instead

plugins=(git)

source "$ZSH/oh-my-zsh.sh" 2>/dev/null

# --- Zsh Plugins (Kali ships these via apt)
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# --- Starship Prompt
export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"
eval "$(starship init zsh)"

# --- Zoxide Smart CD
eval "$(zoxide init zsh --cmd cd)"

# --- Batcat A cat(1) clone with wings. 
alias cat='batcat --paging=never'
alias -g -- -h='-h 2>&1 | batcat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | batcat --language=help --style=plain'

# --- PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# --- History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# --- General Aliases
alias ll='ls -lah --color=auto'
alias la='ls -la --color=auto'
alias l='ls -lh --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# --- Pentest Aliases
alias myip='ip addr show tun0 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}" || ip addr show eth0 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'
alias vpnip='ip addr show tun0 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'
alias localip='ip addr show eth0 2>/dev/null | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'
alias msfconsole='msfconsole -q'
alias nse='ls /usr/share/nmap/scripts/ | grep'

# --- Wordlists
alias rockyou='echo /usr/share/wordlists/rockyou.txt'
alias seclists='echo /usr/share/seclists'
alias wl-dir='echo /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt'
alias wl-dns='echo /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt'
alias wl-user='echo /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt'

# --- Target Management (syncs with Polybar)
TARGET_FILE="$HOME/.config/polybar/.current_target"

settarget() {
    echo "$1" > "$TARGET_FILE"
    echo "[+] Target set: $1"
}

cleartarget() {
    echo "None" > "$TARGET_FILE"
    echo "[+] Target cleared"
}

target() {
    cat "$TARGET_FILE" 2>/dev/null || echo "None"
}

# --- HTB Workspace
HTB_DIR="$HOME/htb"

newbox() {
    if [ -z "$1" ]; then
        echo "Usage: newbox <box-name>"
        return 1
    fi
    local box="$HTB_DIR/$1"
    mkdir -p "$box"/{nmap,loot,exploit,notes}
    echo "# $1" > "$box/notes/README.md"
    settarget "$1"
    cd "$box"
    echo "[+] Workspace ready: $box"
}

# --- HTB VPN
vpn() {
    local ovpn_dir="$HOME/htb/vpn"
    local ovpn_file=$(find "$ovpn_dir" -name "*.ovpn" -type f 2>/dev/null | head -1)
    if [ -z "$ovpn_file" ]; then
        echo "[-] No .ovpn file found in $ovpn_dir"
        return 1
    fi
    echo "[*] Connecting: $(basename "$ovpn_file")"
    sudo openvpn "$ovpn_file"
}

# --- Quick Scan (uses current target)
scan() {
    local ip=$(cat "$TARGET_FILE" 2>/dev/null)
    if [ -z "$ip" ] || [ "$ip" = "None" ]; then
        echo "[-] No target set. Use: settarget <ip>"
        return 1
    fi
    local out="."
    [ -d "./nmap" ] && out="./nmap"
    echo "[*] Scanning $ip ..."
    case "${1:-quick}" in
        quick)
            rustscan -a "$ip" -- -sC -sV -oN "$out/quick.txt"
            ;;
        full)
            nmap -p- -sC -sV -oA "$out/full" "$ip"
            ;;
        udp)
            sudo nmap -sU --top-ports 50 -oA "$out/udp" "$ip"
            ;;
        *)
            echo "Usage: scan [quick|full|udp]"
            ;;
    esac
}

# --- File Transfer Servers
serve() {
    local port="${1:-8000}"
    local lip=$(ip addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    [ -z "$lip" ] && lip=$(ip addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "[*] Serving $(pwd) on http://$lip:$port"
    echo "[*] wget http://$lip:$port/<file>"
    python3 -m http.server "$port"
}

upload() {
    local port="${1:-8001}"
    local lip=$(ip addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    [ -z "$lip" ] && lip=$(ip addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "[*] Upload server on http://$lip:$port/upload"
    echo "[*] curl -F 'file=@<file>' http://$lip:$port/upload"
    python3 -c "
import http.server, cgi, os
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        ct = self.headers.get('Content-Type','')
        if 'multipart' in ct:
            form = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={'REQUEST_METHOD':'POST','CONTENT_TYPE':ct})
            f = form['file']
            with open(f.filename, 'wb') as out:
                out.write(f.file.read())
            self.send_response(200)
            self.end_headers()
            self.wfile.write(f'Saved: {f.filename}\n'.encode())
            print(f'[+] Received: {f.filename}')
        else:
            self.send_response(400)
            self.end_headers()
http.server.HTTPServer(('0.0.0.0', $port), H).serve_forever()
"
}

# --- Timestamped Notes
notes() {
    local ts=$(date '+%H:%M:%S')
    local notes_dir="./notes"
    [ ! -d "$notes_dir" ] && notes_dir="."
    local file="$notes_dir/notes.md"

    if [ -z "$1" ]; then
        ${EDITOR:-vim} "$file"
    else
        echo "- \`[$ts]\` $*" >> "$file"
        echo "[+] $ts | $*"
    fi
}

# --- Universal Archive Extractor
extract() {
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1"    ;;
        *.tar.gz)  tar xzf "$1"    ;;
        *.tar.xz)  tar xJf "$1"    ;;
        *.tar)     tar xf "$1"     ;;
        *.bz2)     bunzip2 "$1"    ;;
        *.gz)      gunzip "$1"     ;;
        *.xz)      unxz "$1"      ;;
        *.zip)     unzip "$1"      ;;
        *.7z)      7z x "$1"       ;;
        *.rar)     unrar x "$1"    ;;
        *.Z)       uncompress "$1" ;;
        *)         echo "[-] Unknown format: $1" ; return 1 ;;
    esac
    echo "[+] Extracted: $1"
}

# --- Offensive tools (sourced separately to avoid AV on Windows host)
# revshell function lives in ~/.config/i3/pentest.sh
[ -f "$HOME/.config/i3/pentest.sh" ] && source "$HOME/.config/i3/pentest.sh"
