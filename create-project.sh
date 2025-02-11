#!/bin/bash
PROJET_PATH="/Users/lakshmangurung/Documents/Workspace/tfs/gitlab-tool"
WORKSPACE_PATH="$PROJET_PATH/workspace"
LOG_FILE="$PROJET_PATH/access.log"
. ./git-pull-all-branches.sh

# Configuration
GITLAB_URL="https://gitlab.com"  # Change if self-hosted
ACCESS_TOKEN=$(env  | grep GITLAB_ACCESS_TOKEN | grep -oe '[^=]*$') #tfs-migration token
PROJECT_GROUP="genie_app"
SUBGROUP_PATH="motherson-mtsl/apps/mobilitycoe"  # Adjust to your subgroup path

# Encode the subgroup path for API usage
# ENCODED_SUBGROUP_PATH=$(echo -n "$SUBGROUP_PATH/$PROJECT_GROUP" | sed 's/\//%2F/g')
ENCODED_SUBGROUP_PATH="$SUBGROUP_PATH/$PROJECT_GROUP"

getAllNameSpaces() {
    echo $(curl --header "Private-Token: $ACCESS_TOKEN" "$GITLAB_URL/api/v4/namespaces")
}

getNameSpaceDetail() {
   local SEARCH_PATH=$1
    namespaces=$(getAllNameSpaces)
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
    local SUBGROUP_PATH=$1   # Subgroup URL-friendly path
    local gitlab_url="https://gitlab.com/api/v4/groups"  # GitLab API endpoint
    local MAIN_GROUP_PATH="motherson-mtsl/apps/mobilitycoe"  # Adjust to your subgroup path
    local FULL_PATH="$MAIN_GROUP_PATH/$SUBGROUP_PATH"
    nameSpaceDetail=$(getNameSpaceDetail "$FULL_PATH")
    
    if [ "$nameSpaceDetail" = "-1" ]; then
        echo "$FULL_PATH doesnt exists. Creating One" >> "$LOG_FILE"
       # Make API request to create a subgroup
        nameSpaceDetail=$(curl --silent --request POST "$gitlab_url" \
            --header "Private-Token: $ACCESS_TOKEN" \
            --header "Content-Type: application/json" \
            --data "{
                \"name\": \"$SUBGROUP_PATH\",
                \"path\": \"$SUBGROUP_PATH\",
                \"parent_id\": \"$parent_group_id\",
                \"visibility\": \"private\"
            }")


        # Extract the created subgroup ID from the JSON response
        ID=$(echo "$nameSpaceDetail" | jq -r '.id')
        echo "Group Creation Start \---------- \n" >> "$LOG_FILE"
        echo "$nameSpaceDetail \---------- \n" >> "$LOG_FILE"
        echo "Group Creation End: \---------- \n" >> "$LOG_FILE"

        # Check if the subgroup was created successfully
        if [[ "$ID" == "null" || -z "$ID" ]]; then
            echo "-1"
            echo "Failed To Create Group: $FULL_PATH\n" >> "$LOG_FILE"
            return -1  # Failure
        fi

        # echo "Subgroup created successfully! ID: $subgroup_id"
        # echo "Web URL: $(echo "$response" | jq -r '.web_url')"
        # echo "GroupId: $(echo "$response" | jq -r '.id')"
        # echo $response
        # return $(echo "$response" | jq -r '.id')
        # echo $nameSpaceDetail
    fi


    echo "Group NAMESPACEID: ---------- \n" >> "$LOG_FILE"
    # echo $nameSpaceDetail
    ID=$(echo "$nameSpaceDetail" | jq -r '.id')
    echo "Group NAMESPACEID: $ID---------- \n" >> "$LOG_FILE"
    echo $ID
    
}

create_gitlab_repository() {
    NAMESPACE_ID=$1
    PROJECT_NAME=$2
    # API endpoint
    PROJECT_DESCRIPTION="This project is created via API."
    API_URL="$GITLAB_URL/api/v4/projects"
    RESPONSE=$(curl --request POST "$API_URL" \
    --header "Private-Token: $ACCESS_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{
        \"name\": \"$PROJECT_NAME\",
        \"description\": \"$PROJECT_DESCRIPTION\",
        \"namespace_id\": \"$NAMESPACE_ID\",
        \"visibility\": \"private\"
    }" \
    --proxy http://localhost:9090
    )

    echo "create_gitlab_repository Response: ---------- \n $RESPONSE\n-------" >> "$LOG_FILE"
    echo $(echo $RESPONSE | jq -r '.http_url_to_repo')
}

extract_subgroup_name() {
    url=$1
    # echo $url
    result=$(echo "$url" | sed -E 's|.*SMG/([^/]+)/_git.*|\1|')
    if [ "$result" = "$url" ]; then
        result=$(echo "$url" | sed -E 's|.*MobilityCoE/([^/]+)/_git.*|\1|')
         if [ "$result" = "$url" ]; then
            echo ""
         fi
    fi
    echo "$result"
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
# create_gitlab_subgroup "$SUBGROUP_PATH"

clone_tfs_repo() {
    local repo_url=$1   # Git repository URL
    local clone_dir=$(basename "$repo_url" .git)

    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: Git is not installed."
        return 0
    fi

    # Clone the repository
    if git clone "$repo_url" "$clone_dir"; then
        echo "SUCCESS"
    else
        echo "Error: Failed to clone repository."
        return -1
    fi
    
    # checkout-all branches
}


# NAMESPACE_ID=$(create_gitlab_subgroup "$SUBGROUP_PATH")
# echo $NAMESPACE_ID

# test() {
#     cd "workspace"
# }
# test
# echo $(pwd)
