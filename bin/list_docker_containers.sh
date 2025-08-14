#!/bin/bash

# Script to list Docker containers on all servers with different detail levels
# Usage: list_docker_containers.sh [-a|-d|-s] 
#   -a: Show all container details (default behavior of list_all_containers.sh)
#   -d: Show container names, status, and age (default behavior of list_containers_details.sh)
#   -s: Show container names and status only (default behavior of list_containers_status.sh)

# Define the servers
SERVERS=("kirk.prestatus.com" "picard.prestatus.com" "laforge.prestatus.com")

# Default mode is -a (all details)
MODE="all"

# Parse command line options
while getopts "ads" opt; do
  case $opt in
    a)
      MODE="all"
      ;;
    d)
      MODE="details"
      ;;
    s)
      MODE="status"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: $0 [-a|-d|-s]" >&2
      echo "  -a: Show all container details (default)" >&2
      echo "  -d: Show container names, status, and age" >&2
      echo "  -s: Show container names and status only" >&2
      exit 1
      ;;
  esac
done

# Function to list containers on a server based on mode
list_containers() {
    local server=$1
    echo "=============================="
    echo "Containers on $server:"
    echo "=============================="
    
    # Set the appropriate Docker command based on mode
    case $MODE in
        "all")
            CMD="DOCKER_HOST=ssh://pablito@$server docker ps -a"
            ;;
        "details")
            CMD="DOCKER_HOST=ssh://pablito@$server docker ps -a --format \"table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\""
            ;;
        "status")
            CMD="DOCKER_HOST=ssh://pablito@$server docker ps -a --format \"table {{.Names}}\t{{.Status}}\""
            ;;
    esac
    
    # Try to connect and list containers
    if $CMD >/dev/null 2>&1; then
        $CMD
    else
        echo "Error: Could not connect to $server or Docker is not running"
    fi
    echo ""
}

# Main function
main() {
    case $MODE in
        "all")
            echo "Listing all Docker containers on all servers..."
            ;;
        "details")
            echo "Docker Container Details on All Servers"
            echo "======================================="
            ;;
        "status")
            echo "Docker Container Names and Status on All Servers"
            echo "================================================"
            ;;
    esac
    echo ""
    
    # Loop through each server and list containers
    for server in "${SERVERS[@]}"; do
        list_containers "$server"
    done
    
    echo "Done."
}

# Run the main function
main