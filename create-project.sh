#!/bin/bash
. ./git-pull-all-branches.sh

# Configuration
GITLAB_URL="https://gitlab.com"  # Change if self-hosted
ACCESS_TOKEN=$(env  | grep GITLAB_ACCESS_TOKEN | grep -oe '[^=]*$') #tfs-migration token
PROJECT_GROUP="genie_app"
SUBGROUP_PATH="motherson-mtsl/apps/mobilitycoe"  # Adjust to your subgroup path

PROJECT_NAME="new-project"  # Desired project name
PROJECT_DESCRIPTION="This is a test project created via API"


# Encode the subgroup path for API usage
# ENCODED_SUBGROUP_PATH=$(echo -n "$SUBGROUP_PATH/$PROJECT_GROUP" | sed 's/\//%2F/g')
ENCODED_SUBGROUP_PATH="$SUBGROUP_PATH/$PROJECT_GROUP"

getNameSpaces() {
    echo $(curl --header "Private-Token: $ACCESS_TOKEN" "$GITLAB_URL/api/v4/namespaces")
}

isPathExists() {
   local SEARCH_PATH=$1
    namespaces=$(getNameSpaces)
    # project_id=$(echo "$response" | jq -r '.id')
    matched_entry=$(echo "$namespaces" | jq -r --arg search "$SEARCH_PATH" '.[] | select(.full_path == $search)')

    # Check if a match was found
    if [ -n "$matched_entry" ]; then
        echo "$matched_entry"
    else
        echo "-1"
    fi
}

# Function to create a GitLab subgroup
create_gitlab_subgroup() {
    local parent_group_id=$(env  | grep GITLAB_PARENT_GROUP_ID | grep -oe '[^=]*$') 
    local subgroup_name=$2    # Name of the subgroup
    local subgroup_path=$3    # Subgroup URL-friendly path
    local gitlab_url="https://gitlab.com/api/v4/groups"  # GitLab API endpoint

    # Make API request to create a subgroup
    response=$(curl --silent --request POST "$gitlab_url" \
        --header "Private-Token: $ACCESS_TOKEN" \
        --header "Content-Type: application/json" \
        --data "{
            \"name\": \"$subgroup_name\",
            \"path\": \"$subgroup_path\",
            \"parent_id\": \"$parent_group_id\",
            \"visibility\": \"private\"
        }")

    # Extract the created subgroup ID from the JSON response
    subgroup_id=$(echo "$response" | jq -r '.id')

    # Check if the subgroup was created successfully
    if [[ "$subgroup_id" == "null" || -z "$subgroup_id" ]]; then
        echo "Error: Failed to create subgroup"
        echo "Response: $response"
        return 1  # Failure
    fi

    echo "Subgroup created successfully! ID: $subgroup_id"
    echo "Web URL: $(echo "$response" | jq -r '.web_url')"
    echo "GroupId: $(echo "$response" | jq -r '.id')"
}

createProject() {
    NAMESPACE_ID=$1
    # API endpoint
    API_URL="$GITLAB_URL/api/v4/projects"
    RESPONSE=$(curl --request POST "$API_URL" \
    --header "Private-Token: $ACCESS_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{
        \"name\": \"$PROJECT_NAME\",
        \"description\": \"$PROJECT_DESCRIPTION\",
        \"namespace_id\": \"$NAMESPACE_ID\",
        \"visibility\": \"private\"
    }")

    echo $(echo $RESPONSE | jq -r '.http_url_to_repo')
}

# result=$(isPathExists "$ENCODED_SUBGROUP_PATH")
# # echo "ENCODED_SUBGROUP_PATH: $ENCODED_SUBGROUP_PATH"
# groupId=$(echo $result | jq -r '.id')
# echo "GroupId $groupId"
# # # echo "Namesapces: $namespaces"
# # # Create project under the subgroup

# createProject


#!/bin/bash



# Example usage: Replace with actual values
SUBGROUP_NAME="New Subgroup"  # Desired name
SUBGROUP_PATH="new-subgroup"  # URL-friendly path (lowercase, no spaces)

# Call the function with arguments
# create_gitlab_subgroup "$PARENT_GROUP_ID" "$SUBGROUP_NAME" "$SUBGROUP_PATH"

clone_git_repo() {
    cd ""
    local repo_url=$1   # Git repository URL
    local clone_dir=$(basename "$repo_url" .git)

    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: Git is not installed."
        return 1
    fi

    # Clone the repository
    if git clone "$repo_url" "$clone_dir"; then
        echo "Repository cloned successfully to $clone_dir"
    else
        echo "Error: Failed to clone repository."
        return 1
    fi
    cd "$clone_dir"
    # checkout-all branches
    checkOutAllBranches
    cd "../"
}
