#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <source_branch> <deploy_branch>"
    echo "Example: $0 master deploy"
    echo "Example: $0 main deploy"
    exit 1
}

# Check if we have the correct number of arguments
if [ $# -ne 2 ]; then
    usage
fi

SOURCE_BRANCH=$1
DEPLOY_BRANCH=$2

# Store current branch name to return to it later
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Function to handle errors
handle_error() {
    local exit_code=$?
    echo "Error: $1"
    echo "Rolling back to original branch: $CURRENT_BRANCH"
    git checkout "$CURRENT_BRANCH"
    exit $exit_code
}

# Check if both branches exist
git rev-parse --verify "$SOURCE_BRANCH" >/dev/null 2>&1 || handle_error "Source branch '$SOURCE_BRANCH' does not exist"
git rev-parse --verify "$DEPLOY_BRANCH" >/dev/null 2>&1 || handle_error "Deploy branch '$DEPLOY_BRANCH' does not exist"

# Function to check for uncommitted changes
check_uncommitted_changes() {
    if ! git diff-index --quiet HEAD --; then
        handle_error "You have uncommitted changes. Please commit or stash them first."
    fi
}

# Main deployment process
deploy() {
    echo "Starting deployment process..."
    echo "Source branch: $SOURCE_BRANCH"
    echo "Deploy branch: $DEPLOY_BRANCH"
    
    # Check for uncommitted changes
    check_uncommitted_changes
    
    # Checkout deploy branch
    echo "Checking out $DEPLOY_BRANCH branch..."
    git checkout "$DEPLOY_BRANCH" || handle_error "Failed to checkout $DEPLOY_BRANCH branch"
    
    # Pull latest changes with rebase
    echo "Pulling latest changes..."
    git pull --rebase origin "$DEPLOY_BRANCH" || handle_error "Failed to pull changes from $DEPLOY_BRANCH"
    
    # Merge source branch
    echo "Merging $SOURCE_BRANCH into $DEPLOY_BRANCH..."
    git merge "$SOURCE_BRANCH" || handle_error "Failed to merge $SOURCE_BRANCH into $DEPLOY_BRANCH"
    
    # Push changes
    echo "Pushing changes to remote..."
    git push origin "$DEPLOY_BRANCH" || handle_error "Failed to push changes to remote"
    
    # Return to original branch
    echo "Returning to $CURRENT_BRANCH branch..."
    git checkout "$CURRENT_BRANCH" || handle_error "Failed to return to $CURRENT_BRANCH"
    
    echo "Deployment process completed successfully!"
}

# Execute deployment
deploy
