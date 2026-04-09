# Claude SSH to Kali vm

## Requirements

Windows (Host)

```powershell
$ winget install OpenJS.NodeJS.LTS
```

Kali (VM)

```bash
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

## SSH key Setup

On Windows Powershell Terminal.
```powershell
$ ssh-keygen -t ed25519
$ type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh kali@<KALI_VM_IP> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## Claude Desktop Config (claude_desktop_config.json)

```json
{
  "mcpServers": {
    "kali-ssh": {
      "command": "npx",
      "args": [
        "-y",
        "@idletoaster/ssh-mcp-server@latest"
      ],
      "env": {}
    }
  },
  "preferences": {
    "menuBarEnabled": false,
    "quickEntryShortcut": "off",
    "coworkScheduledTasksEnabled": false,
    "ccdScheduledTasksEnabled": true,
    "sidebarMode": "code",
    "coworkWebSearchEnabled": true
  }
}
```