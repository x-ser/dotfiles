#!/bin/sh
# Start VMware clipboard agent (avoid duplicates)
if ! pgrep -xu "$USER" vmware-user >/dev/null 2>&1; then
  /usr/bin/vmware-user-suid-wrapper &
fi

