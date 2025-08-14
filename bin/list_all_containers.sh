#!/bin/bash

# Script to list all Docker containers on all servers

# Define the servers
SERVERS=("kirk.prestatus.com" "picard.prestatus.com" "laforge.prestatus.com")

# Function to list containers on a server
list_containers() {
    local server=$1
    echo "=============================="
    echo "Containers on $server:"
    echo "=============================="
    
    # Try to connect and list containers
    if DOCKER_HOST=ssh://pablito@$server docker ps -a >/dev/null 2>&1; then
        DOCKER_HOST=ssh://pablito@$server docker ps -a
    else
        echo "Error: Could not connect to $server or Docker is not running"
    fi
    echo ""
}

# Main function
main() {
    echo "Listing all Docker containers on all servers..."
    echo ""
    
    # Loop through each server and list containers
    for server in "${SERVERS[@]}"; do
        list_containers "$server"
    done
    
    echo "Done."
}

# Run the main function
main