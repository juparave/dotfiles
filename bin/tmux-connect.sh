#!/usr/bin/env bash
# connect to a remote tmux session
# ./tmux-connect.sh remote.workstation.com work

# default values
host=${1:-"zulu.prestatus.com"}
session=${2:-"work"}

echo "Connecting to remote tmux session $session on $host"

# Redirect stderr to a variable
ssh -t $host tmux attach -t $session 2>&1 

# Check if there was an error
if [ $? -ne 0 ]; then
  echo "Please enable the remote tmux session first"
  echo "eg. tmux new -s work -d"
  echo "I'll try to create it for you"
  ssh -t $host "tmux new-session -d -s $session"
  echo "new session $session created, attaching now..."
  ssh -t $host tmux attach -t $session 2>&1
else
  echo "Successfully connected to remote tmux session $session on $host"
fi

