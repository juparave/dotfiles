#!/usr/bin/env bash

# A script to free up disk space on macOS by cleaning up common caches and temporary files.
# Warning: This script moves many files to the trash and deletes some system files permanently.
# Review the items in the trash before emptying it.

set -e # Exit immediately if a command exits with a non-zero status.

USER=$(whoami)

echo "Starting the cleanup process..."

# --- Xcode ---
echo "Cleaning Xcode caches and derived data..."
if [ -d "/Users/$USER/Library/Developer/Xcode/DerivedData" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/Xcode/DerivedData\" to trash"
fi
if [ -d "/Users/$USER/Library/Developer/Xcode/Archives" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/Xcode/Archives\" to trash"
fi
if [ -d "/Users/$USER/Library/Caches/com.apple.dt.Xcode" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Caches/com.apple.dt.Xcode\" to trash"
fi
if [ -d "/Users/$USER/Library/Developer/CoreSimulator/Caches" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/CoreSimulator/Caches\" to trash"
fi
xcrun simctl delete unavailable

# --- System & User Caches and Logs ---
echo "Cleaning system and user caches and logs..."
# The following commands will prompt for your password to delete system-level files.
# We add '|| true' to ignore "Operation not permitted" errors caused by SIP (System Integrity Protection).
sudo rm -rf /Library/Caches/* || true
sudo rm -rf /private/var/log/* || true
# For user caches and logs, we'll move them to the trash to be safe.
if [ -d "/Users/$USER/Library/Caches" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Caches\" to trash"
fi
if [ -d "/Users/$USER/Library/Logs" ]; then
    osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Logs\" to trash"
fi


# --- Homebrew ---
if command -v brew &> /dev/null; then
    echo "Cleaning Homebrew cache..."
    brew cleanup
fi

# --- Node.js (npm) ---
if command -v npm &> /dev/null; then
    echo "Cleaning npm cache (will not delete globally installed packages)..."
    npm cache clean --force
fi

# --- Yarn ---
if command -v yarn &> /dev/null; then
    echo "Cleaning Yarn cache..."
    if [ -d "/Users/$USER/Library/Caches/Yarn" ]; then
        osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Caches/Yarn\" to trash"
    fi
fi

# --- Go ---
if command -v go &> /dev/null; then
    echo "Cleaning Go build cache..."
    go clean -cache
fi

# --- Pip ---
if command -v pip &> /dev/null; then
    echo "Cleaning pip cache..."
    if [ -d "/Users/$USER/Library/Caches/pip" ]; then
        osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Caches/pip\" to trash"
    fi
fi

# --- Optional: Flutter Projects ---
if command -v flutter &> /dev/null; then
    read -p "Do you want to clean all Flutter projects in ~/workspace/flutter? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleaning Flutter projects..."
        find ~/workspace/flutter -name "pubspec.yaml" -print0 | while IFS= read -r -d $'\0' file; do
            project_dir=$(dirname "$file")
            echo "--> Cleaning project: $project_dir"
            (cd "$project_dir" && flutter clean)
        done
    fi
fi


# --- Final Step: Empty Trash ---
echo "Moving items to trash is complete. Please review the items in the trash before emptying it."
echo "You can empty the trash by running:"
echo "osascript -e 'tell application \"Finder\" to empty trash'"

echo "Cleanup process finished."
