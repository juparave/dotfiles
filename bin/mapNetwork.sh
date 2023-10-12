#!/usr/bin/env bash

# Check if a network range was provided as a command-line argument
if [ -z "$1" ]; then
  echo "Usage: $0 [network_range]"
  echo "Example: $0 192.168.1.0/24"
  exit 1
fi

# Use the provided network range or default to 192.168.1.0/24
network_range="$1"

# Run the Nmap ping scan
nmap -sn $network_range

# Provide a message to indicate the scan is complete
echo "Nmap ping scan on network $network_range is complete."
