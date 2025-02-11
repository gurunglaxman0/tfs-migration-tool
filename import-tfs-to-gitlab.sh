#!/bin/bash
. ./create-project.sh
# Path to the Git config file
# Example Usage: Replace with actual Git repository URL
#!/bin/bash


resetGitConfigFile() {

    GIT_URL="$1"
    CONFIG_FILE=".git/config"  # Change this if needed

    # Use awk to keep only the content before [remote "origin"]
    awk '!/\[remote "origin"\]/{print; next} {exit}' "$CONFIG_FILE" > temp_config && mv temp_config "$CONFIG_FILE"

    # echo "Updated $CONFIG_FILE: Only content before [remote \"origin\"] remains."
    
    git remote add origin "$GIT_URL"
}

# URL="https://tfsci.mindeservices.com/tfs/MobilityCoE/MS_CBS/_git/ms_ads_ios"
# NAME=$(extract_name "$URL")
# echo "Extracted name: $NAME"

# clone_git_repo "$GIT_REPO_URL" "$CLONE_DIRECTORY"

# cd "ms_ads_ios"



#!/bin/bash

# Input file containing URLs (one per line)
input_file="$PROJET_PATH/tfs-urls.txt"

# Output JSON file
output_file="$PROJET_PATH/output.json"
failed_log="$PROJET_PATH/failed_urls.log"
success_file="$PROJET_PATH/success_urls.log"

# Check if the output JSON file exists and is valid; otherwise, initialize it
if [[ ! -f "$output_file" || ! $(jq empty "$output_file" 2>/dev/null) ]]; then
    echo "[]" > "$output_file"
fi


cd "$WORKSPACE_PATH"

> "$failed_log"
> "$success_file"

# Read existing JSON data
json_array=$(cat "$output_file")

# Read URLs from the input file and process them
while IFS= read -r url || [[ -n "$url" ]]; do
    TFS_CLONE_RESULT=$(clone_tfs_repo "$url")
    if [ "$TFS_CLONE_RESULT" != "SUCCESS" ]; then
         echo "$url" >> "$failed_log"
         echo "FAILED to clone TFS"  $(pwd)
         continue
    fi
    
    subGroupName=$(extract_subgroup_name "$url")
   
    # # Extract repository name
    repo_name=$(basename "$url" .git)

    cd "$WORKSPACE_PATH/$repo_name"
    # echo "repo_name $repo_name"
    # echo "subGroupName $subGroupName"
    checkOutAllBranches

    NAMESPACE_ID=$(create_gitlab_subgroup "$subGroupName")
    if [ "$NAMESPACE_ID" = "" ];  then
        echo "$url" >> "$failed_log"
        continue
    fi
    # echo "NAMESPACE_ID: $NAMESPACE_ID"

    gitlab_repo_url=$(create_gitlab_repository "$NAMESPACE_ID" "$repo_name")
   
    # # # Checkout All branches
    # # https://gitlab.com/motherson-mtsl/apps/mobilitycoe/U1070_QuickForm/mquick_form_mobile.git

    # echo "gitlab_repo_url: $gitlab_repo_url"
   
    if [ $gitlab_repo_url = null ];  then
        echo "$url" >> "$failed_log"
        echo "FAILED TO Get Github URL: \n" >> "$LOG_FILE"
        continue
    fi
    
    resetGitConfigFile "$gitlab_repo_url"
    git push -u origin --all

    # # Append JSON object
    json_array=$(echo "$json_array" | jq --arg name "$name" --arg link "$url" --arg gitlab_repo_url "$gitlab_repo_url" --arg repo_name "$repo_name" '. + [{"name": $repo_name, "tfsLink": $link, "gitlab_repo_url":$gitlab_repo_url}]')
    # # 

    echo "$gitlab_repo_url" >> "$success_file"

   cd "$WORKSPACE_PATH"
done < "$input_file"

# Save updated JSON back to file

# echo "$json_array" > "$output_file"
