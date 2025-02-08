#!/bin/bash
. ./create-project.sh
# Path to the Git config file
# Example Usage: Replace with actual Git repository URL

GIT_REPO_URL="https://tfsci.mindeservices.com/tfs/SMG/MS_CBS/_git/ms_ads_ios"

# clone_git_repo "$GIT_REPO_URL" "$CLONE_DIRECTORY"

cd "ms_ads_ios"

CONFIG_FILE=".git/config"  # Change this if needed

# Use awk to keep only the content before [remote "origin"]
# awk '!/\[remote "origin"\]/{print; next} {exit}' "$CONFIG_FILE" > temp_config && mv temp_config "$CONFIG_FILE"

# # echo "Updated $CONFIG_FILE: Only content before [remote \"origin\"] remains."

# git remote add origin "https://gitlab.com/motherson-mtsl/apps/mobilitycoe/DO_S06S_ATSAnywhereApp/hris-ios.git"