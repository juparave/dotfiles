#!/bin/bash
set -euo pipefail

echo "Docker Cleanup Script"
echo "====================="

# Check Docker daemon is running
if ! docker info &>/dev/null; then
    echo "Error: Docker daemon is not running" >&2
    exit 1
fi

# Convert a human-readable Docker size string (e.g. "1.5GB") to bytes
to_bytes() {
    awk -v s="$1" 'BEGIN {
        n = s + 0
        u = s; gsub(/[0-9.]+/, "", u)
        if      (u == "B")  print int(n)
        else if (u == "kB") print int(n * 1024)
        else if (u == "MB") print int(n * 1024^2)
        else if (u == "GB") print int(n * 1024^3)
        else if (u == "TB") print int(n * 1024^4)
        else                print 0
    }'
}

format_bytes() {
    awk -v b="$1" 'BEGIN {
        if      (b < 1024)   printf "%dB\n",      b
        else if (b < 1024^2) printf "%.2fKB\n",   b / 1024
        else if (b < 1024^3) printf "%.2fMB\n",   b / 1024^2
        else if (b < 1024^4) printf "%.2fGB\n",   b / 1024^3
        else                 printf "%.2fTB\n",   b / 1024^4
    }'
}

total_bytes=0

# Run a prune command, print its output, and accumulate reclaimed space.
# Usage: run_prune <label> <grep-pattern> <docker command...>
run_prune() {
    local label="$1" pattern="$2"
    shift 2

    echo ""
    echo "${label}..."
    local output
    output=$("$@" 2>&1)
    echo "$output"

    local space
    space=$(echo "$output" | grep -E "$pattern" | awk '{print $NF}' || true)
    
    # Store in dynamic variable (Bash 3.2 compatibility)
    local var_name
    var_name="reclaimed_$(echo "$label" | tr -d ' ')"
    eval "$var_name=\"${space:-0B}\""

    if [ -n "$space" ] && [ "$space" != "0B" ]; then
        local bytes
        bytes=$(to_bytes "$space")
        total_bytes=$(( total_bytes + bytes ))
    fi
}

run_prune "Containers"  "Total reclaimed space:"  docker container prune -f
run_prune "Build cache" "^Total:"                 docker builder prune -a -f
run_prune "Images"      "Total reclaimed space:"  docker image prune -a -f
run_prune "Volumes"     "Total reclaimed space:"  docker volume prune -f
run_prune "Networks"    "Total reclaimed space:"  docker network prune -f

echo ""
echo "==========================================="
echo "SUMMARY:"
for label in "Containers" "Build cache" "Images" "Volumes" "Networks"; do
    var_name="reclaimed_$(echo "$label" | tr -d ' ')"
    reclaimed_val=$(eval "echo \${$var_name:-0B}")
    printf "  %-14s %s\n" "${label}:" "${reclaimed_val}"
done
echo "-------------------------------------------"
printf "  %-14s %s\n" "TOTAL:" "$(format_bytes "$total_bytes")"
echo "==========================================="
