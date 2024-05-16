#!/bin/bash
# Remove all stopped containers
echo "Removing all stopped containers"
docker container prune -f

# Remove build cache objects
echo "Removing build cache objects"
docker builder prune -f

# Remove all dangling images
echo "Removing all dangling images"
docker image prune -a -f
