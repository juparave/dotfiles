#!/usr/bin/env bash

# A script to free up disk space on macOS by cleaning up common caches and temporary files.
# Warning: This script moves many files to the trash and deletes some system files permanently.
# Review the items in the trash before emptying it.
#
# Usage: deep_free_space.sh [--dry-run]
#   --dry-run  Show what would be cleaned without actually doing it.

set -e # Exit immediately if a command exits with a non-zero status.

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] No files will be moved or deleted."
fi

USER=$(whoami)

# Returns the size of a path in bytes (0 if it doesn't exist)
dir_size_bytes() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sk "$path" 2>/dev/null | awk '{print $1 * 1024}'
    else
        echo 0
    fi
}

TOTAL_FREED=0

# Move a directory to trash (or log in dry-run mode) and accumulate freed bytes
trash_path() {
    local path="$1"
    if [ -d "$path" ] || [ -f "$path" ]; then
        local size
        size=$(dir_size_bytes "$path")
        if $DRY_RUN; then
            local human
            human=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
            echo "  [dry-run] Would trash: $path ($human)"
        else
            osascript -e "tell application \"Finder\" to move POSIX file \"$path\" to trash"
            TOTAL_FREED=$((TOTAL_FREED + size))
        fi
    fi
}

# Run a command (or log it in dry-run mode) and estimate freed bytes via a path
rm_path() {
    local path="$1"
    if [ -d "$path" ] || [ -f "$path" ]; then
        local size
        size=$(dir_size_bytes "$path")
        if $DRY_RUN; then
            local human
            human=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
            echo "  [dry-run] Would delete: $path ($human)"
        else
            sudo rm -rf "$path" || true
            TOTAL_FREED=$((TOTAL_FREED + size))
        fi
    fi
}

# Run an arbitrary command in dry-run mode (just log it)
maybe_run() {
    local label="$1"
    shift
    if $DRY_RUN; then
        echo "  [dry-run] Would run: $label"
    else
        "$@"
    fi
}

# Capture free disk space before cleanup
FREE_BEFORE=$(df -k / | awk 'NR==2 {print $4 * 1024}')

echo "Starting the cleanup process..."

# --- Xcode ---
echo "Cleaning Xcode caches and derived data..."
trash_path "/Users/$USER/Library/Developer/Xcode/DerivedData"
trash_path "/Users/$USER/Library/Developer/Xcode/Archives"
trash_path "/Users/$USER/Library/Caches/com.apple.dt.Xcode"
trash_path "/Users/$USER/Library/Developer/CoreSimulator/Caches"
maybe_run "xcrun simctl delete unavailable" xcrun simctl delete unavailable

# --- System & User Caches and Logs ---
echo "Cleaning system and user caches and logs..."
for entry in /Library/Caches/*; do
    rm_path "$entry"
done
for entry in /private/var/log/*; do
    rm_path "$entry"
done
for cache_dir in "/Users/$USER/Library/Caches/"*; do
    for entry in "$cache_dir/"*; do
        rm_path "$entry"
    done
done
for entry in "/Users/$USER/Library/Logs/"*; do
    rm_path "$entry"
done

# --- Homebrew ---
if command -v brew &> /dev/null; then
    echo "Cleaning Homebrew cache..."
    maybe_run "brew cleanup" brew cleanup
fi

# --- Node.js (npm) ---
if command -v npm &> /dev/null; then
    echo "Cleaning npm cache (will not delete globally installed packages)..."
    maybe_run "npm cache clean --force" npm cache clean --force
fi

# --- Yarn ---
if command -v yarn &> /dev/null; then
    echo "Cleaning Yarn cache..."
    trash_path "/Users/$USER/Library/Caches/Yarn"
fi

# --- Go ---
if command -v go &> /dev/null; then
    echo "Cleaning Go build cache..."
    maybe_run "go clean -cache" go clean -cache
fi

# --- Pip ---
if command -v pip &> /dev/null; then
    echo "Cleaning pip cache..."
    trash_path "/Users/$USER/Library/Caches/pip"
fi

# --- Optional: Flutter Projects ---
if command -v flutter &> /dev/null; then
    read -p "Do you want to clean all Flutter projects found under ~/workspace? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Searching for Flutter projects under ~/workspace..."
        find ~/workspace -name "pubspec.yaml" \
            -not -path "*/\.*" \
            -not -path "*/node_modules/*" \
            -not -path "*/.pub-cache/*" \
            -not -path "*/build/*" \
            -print0 | while IFS= read -r -d $'\0' file; do
            project_dir=$(dirname "$file")
            echo "--> Cleaning project: $project_dir"
            if $DRY_RUN; then
                echo "  [dry-run] Would run: flutter clean in $project_dir"
            else
                (cd "$project_dir" && flutter clean)
            fi
        done
    fi
fi

# --- Report ---
if $DRY_RUN; then
    echo ""
    echo "Dry run complete. No files were modified."
else
    FREE_AFTER=$(df -k / | awk 'NR==2 {print $4 * 1024}')
    ACTUAL_FREED=$((FREE_AFTER - FREE_BEFORE))

    # Convert bytes to human-readable
    human_readable() {
        local bytes=$1
        if [ "$bytes" -ge $((1024 * 1024 * 1024)) ]; then
            echo "$(echo "scale=2; $bytes / 1073741824" | bc) GB"
        elif [ "$bytes" -ge $((1024 * 1024)) ]; then
            echo "$(echo "scale=2; $bytes / 1048576" | bc) MB"
        elif [ "$bytes" -ge 1024 ]; then
            echo "$(echo "scale=2; $bytes / 1024" | bc) KB"
        else
            echo "${bytes} B"
        fi
    }

    echo ""
    echo "Moving items to trash is complete. Please review the items in the trash before emptying it."
    echo "You can empty the trash by running:"
    echo "  osascript -e 'tell application \"Finder\" to empty trash'"
    echo ""
    echo "Estimated space freed (trashed/deleted items): $(human_readable $TOTAL_FREED)"
    echo "Actual disk space recovered (df diff):         $(human_readable $ACTUAL_FREED)"
    echo ""
    echo "Cleanup process finished."
fi
