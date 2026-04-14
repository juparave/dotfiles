#!/usr/bin/env bash

# A script to free up disk space on Linux (Ubuntu/Debian) by cleaning up
# common caches, temporary files, and unused packages.
# Works for both sudoers and non-sudoers — sudo commands are skipped gracefully.
# Review each section carefully before running.

USER=$(whoami)

# Check if the user can use sudo
if sudo -n true 2>/dev/null; then
    HAS_SUDO=true
else
    HAS_SUDO=false
    echo "Note: sudo not available. Skipping system-level cleanups."
    echo ""
fi

echo "Starting the cleanup process on Linux..."

# --- APT (Debian/Ubuntu) ---
if [ "$HAS_SUDO" = true ] && command -v apt &> /dev/null; then
    echo "Cleaning APT cache and unused packages..."
    sudo apt autoremove -y || true
    sudo apt autoclean -y || true
    sudo apt clean || true
else
    echo "Skipping APT cleanup (requires sudo)."
fi

# --- Snap ---
if [ "$HAS_SUDO" = true ] && command -v snap &> /dev/null; then
    echo "Removing old Snap revisions..."
    snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read -r name rev; do
        sudo snap remove "$name" --revision="$rev" 2>/dev/null || true
    done
else
    echo "Skipping Snap cleanup (requires sudo)."
fi

# --- System & User Caches ---
echo "Cleaning user caches..."
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}"/* 2>/dev/null || true
rm -rf "$HOME/.local/share/Trash/files"/* 2>/dev/null || true

if [ "$HAS_SUDO" = true ]; then
    echo "Cleaning system caches and logs..."
    sudo rm -rf /var/cache/* 2>/dev/null || true
    sudo rm -rf /var/log/* 2>/dev/null || true
    sudo journalctl --vacuum-time=3d 2>/dev/null || true
else
    echo "Skipping system cache/log cleanup (requires sudo)."
fi

# --- Thumbnails ---
echo "Cleaning thumbnail cache..."
rm -rf "$HOME/.cache/thumbnails"/* 2>/dev/null || true

# --- Homebrew (Linuxbrew) ---
if command -v brew &> /dev/null; then
    echo "Cleaning Homebrew cache..."
    brew cleanup
fi

# --- Node.js (npm) ---
if command -v npm &> /dev/null; then
    echo "Cleaning npm cache..."
    npm cache clean --force
fi

# --- Yarn ---
if command -v yarn &> /dev/null; then
    echo "Cleaning Yarn cache..."
    rm -rf "$HOME/.cache/yarn"/* 2>/dev/null || true
fi

# --- Go ---
if command -v go &> /dev/null; then
    echo "Cleaning Go build cache..."
    go clean -cache
fi

# --- Pip ---
if command -v pip &> /dev/null; then
    echo "Cleaning pip cache..."
    pip cache purge 2>/dev/null || true
fi

# --- Docker ---
if command -v docker &> /dev/null; then
    echo "Cleaning Docker (images, containers, volumes, build cache)..."
    docker system prune -af --volumes 2>/dev/null || true
fi

# --- Flutter ---
if command -v flutter &> /dev/null; then
    read -p "Do you want to clean all Flutter projects in ~/workspace/flutter? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleaning Flutter projects..."
        find ~/workspace/flutter -name "pubspec.yaml" -print0 2>/dev/null | while IFS= read -r -d $'\0' file; do
            project_dir=$(dirname "$file")
            echo "  --> Cleaning project: $project_dir"
            (cd "$project_dir" && flutter clean)
        done
    fi
fi

# --- Temp files ---
echo "Cleaning user temporary files..."
rm -rf /tmp/"$USER"/* 2>/dev/null || true
rm -rf "$HOME/tmp"/* 2>/dev/null || true

if [ "$HAS_SUDO" = true ]; then
    echo "Cleaning system temporary files..."
    sudo rm -rf /var/tmp/* 2>/dev/null || true
else
    echo "Skipping system temp cleanup (requires sudo)."
fi

echo ""
echo "Cleanup process finished."
