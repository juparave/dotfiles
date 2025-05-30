#!/usr/bin/env bash

## Free disk space, for macOS

USER=$(whoami)

# free DerivedData, ref: https://lapcatsoftware.com/articles/DerivedData.html
osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/Xcode/DerivedData\" to trash"
osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/Xcode/Archives\" to trash"
osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Caches/com.apple.dt.Xcode\" to trash"
osascript -e "tell application \"Finder\" to move POSIX file \"/Users/$USER/Library/Developer/CoreSimulator/Caches\" to trash"
# empty
osascript -e "tell application \"Finder\" to empty trash"

# clear simulator data
# ref: https://medium.com/@nqtuan86/clean-mac-storage-for-xcodes-users-5fbb32239aa5
xcrun simctl delete unavailable
