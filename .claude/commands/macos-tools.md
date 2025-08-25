---
description: "Documents macOS-specific capabilities available to Claude"
---

# macOS Tools Available to Claude

Claude can interact with macOS system tools through the Bash tool:

## Clipboard
- **Copy to clipboard**: `echo "text" | pbcopy`
- **Read from clipboard**: `pbpaste`

## File System
- **Open files**: `open file.txt` (opens in default app)
- **Open directories**: `open .` (opens in Finder)
- **Reveal in Finder**: `open -R file.txt`

## System Info
- **Get system info**: `system_profiler SPHardwareDataType`
- **Check processes**: `ps aux | grep process_name`
- **Network info**: `ifconfig` or `networksetup -listallhardwareports`

## Applications
- **Launch apps**: `open -a "Application Name"`
- **Kill apps**: `pkill -f "app_name"`

These capabilities work across all your Darwin workstations.