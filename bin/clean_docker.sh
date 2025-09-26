#!/bin/bash

echo "Docker Cleanup Script"
echo "====================="

# Function to convert human-readable sizes to KB for calculation
convert_to_kb() {
    local size=$1
    # Extract number and unit
    local number=$(echo $size | sed 's/[^0-9.]*$//')
    local unit=$(echo $size | sed 's/^[0-9.]*//')
    
    case $unit in
        "B")  echo "scale=2; $number/1024" | bc | xargs printf "%.0f" ;;
        "kB") echo $number | xargs printf "%.0f" ;;
        "MB") echo "$number * 1024" | bc | xargs printf "%.0f" ;;
        "GB") echo "$number * 1024 * 1024" | bc | xargs printf "%.0f" ;;
        "TB") echo "$number * 1024 * 1024 * 1024" | bc | xargs printf "%.0f" ;;
        *)    echo 0 ;;
    esac
}

# Remove all stopped containers and calculate reclaimed space
echo ""
echo "Removing all stopped containers..."
container_output=$(docker container prune -f 2>&1)
echo "$container_output"

# Extract reclaimed space from container prune output
container_space=$(echo "$container_output" | grep "Total reclaimed space:" | sed 's/Total reclaimed space://' | xargs)
container_space_formatted="0B"
container_space_kb=0

if [ -n "$container_space" ] && [ "$container_space" != "0B" ]; then
    container_space_formatted="$container_space"
    container_space_kb=$(convert_to_kb "$container_space")
    echo "Space reclaimed from containers: $container_space_formatted"
else
    echo "No space reclaimed from containers or operation not supported"
fi

# Remove build cache objects and calculate reclaimed space
echo ""
echo "Removing build cache objects..."
cache_output=$(docker builder prune -f 2>&1)
echo "$cache_output"

# Extract total from build cache output
build_cache_space=$(echo "$cache_output" | grep "Total:" | sed 's/.*Total:[[:space:]]*//' | xargs)
build_cache_space_kb=0
build_cache_space_formatted="0B"

if [ -n "$build_cache_space" ] && [ "$build_cache_space" != "0B" ]; then
    build_cache_space_formatted="$build_cache_space"
    build_cache_space_kb=$(convert_to_kb "$build_cache_space")
    echo "Space reclaimed from build cache: $build_cache_space_formatted"
else
    echo "No space reclaimed from build cache or operation not supported"
fi

# Remove all dangling images and calculate reclaimed space
echo ""
echo "Removing all dangling images..."
image_output=$(docker image prune -a -f 2>&1)
echo "$image_output"

# Extract reclaimed space from image prune output
image_space=$(echo "$image_output" | grep "Total reclaimed space:" | sed 's/Total reclaimed space://' | xargs)
image_space_formatted="0B"
image_space_kb=0

if [ -n "$image_space" ] && [ "$image_space" != "0B" ]; then
    image_space_formatted="$image_space"
    image_space_kb=$(convert_to_kb "$image_space")
    echo "Space reclaimed from images: $image_space_formatted"
else
    echo "No space reclaimed from images or operation not supported"
fi

# Remove system prune (unused networks and build cache) 
echo ""
echo "Removing unused networks and build cache..."
system_output=$(docker system prune -f --volumes 2>&1)
echo "$system_output"

# Calculate total reclaimed space in KB
total_kb=$(echo "$container_space_kb + $build_cache_space_kb + $image_space_kb" | bc)

# Show final totals
echo ""
echo "==========================================="
echo "SUMMARY:"
echo "Space reclaimed from containers: $container_space_formatted"
echo "Space reclaimed from build cache: $build_cache_space_formatted" 
echo "Space reclaimed from images: $image_space_formatted"
printf "TOTAL RECLAIMED SPACE: "
if [ $total_kb -gt 0 ]; then
    # Convert back to human readable format
    if [ $total_kb -lt 1024 ]; then
        echo "${total_kb}KB"
    elif [ $total_kb -lt 1048576 ]; then
        total_mb=$(echo "scale=2; $total_kb/1024" | bc)
        echo "${total_mb}MB"
    elif [ $total_kb -lt 1073741824 ]; then
        total_gb=$(echo "scale=2; $total_kb/1048576" | bc)
        echo "${total_gb}GB"
    else
        total_tb=$(echo "scale=2; $total_kb/1073741824" | bc)
        echo "${total_tb}TB"
    fi
else
    echo "0KB"
fi
echo "==========================================="