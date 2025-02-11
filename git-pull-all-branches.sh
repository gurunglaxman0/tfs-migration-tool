#!/bin/bash
checkOutAllBranches() {
    set -e  # Exit if any command fails

    echo "checkOutAllBranches:" $(pwd)
    # Fetch all branches
    git fetch --all

    # Get a list of all branches (local + remote)
    branches=$(git branch -r | grep -v HEAD | sed 's/origin\///')

    # Loop through each branch and pull the latest changes
    for branch in $branches; do
        echo "🔄 Checking out and pulling: $branch"
        git checkout $branch || git checkout -b $branch origin/$branch
        git pull origin $branch
    done
}

