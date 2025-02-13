#!/bin/bash

# Define TFS Server, Project, and API Version
TFS_URL="https://tfsci.mindeservices.com/tfs"
# GET https://{instance}/{collection}/{project}/_apis/sourceProviders/{providerName}/repositories?api-version=7.1
ORG_NAME="MobilityCoE"   # Change this to your organization
# ORG_NAME="SMG"   # Change this to your organization
# PROJECT_NAME="U1070_QuickForm"  # Change this to your project name
API_VERSION="6.0"

# projects=("U0117_F5App") 
PROJECT_NAME="SWS_S07D_EMS"
# Personal Access Token (PAT) - Base64 Encode "username:PAT"
# If using a token, use ":PAT" instead of "username:PAT"

PAT=$(env  | grep TFS_ACCESS_TOKEN | grep -oe '[^=]*$') 
echo "PAT:" $PAT
AUTH=$(echo -n ":$PAT" | base64)
output_file="tfs-urls.txt"
 > "$output_file"

# for PROJECT_NAME in "${projects[@]}"; do

    # API URL to list all projects
    API_URL="$TFS_URL/$ORG_NAME/$PROJECT_NAME/_apis/git/repositories"
    # Fetch project list
    response=$(curl -s -u :$PAT -H "Content-Type: application/json" "$API_URL" -v)

    # Extract project names using jq
    # echo "$response" | jq '.value[] | {id: .id, name: .name, state: .state, url: .url}'
    echo $API_URL
    # Extract repository names using jq
    # echo "$response" | jq '.value[]'
 
    clean_response=$(echo "$response" | tr -d '\000-\031')  # Remove control chars
    echo "$clean_response" | jq -r '.value[].remoteUrl' >>"$output_file"
    # echo $response

    # Show saved URLs
    echo "Project URLs saved to $output_file"
    # curl -H "Authorization: Basic LW4gOnA2bXN0czJjZ2U1ZHpoZXBsZWd0anAyM2QybXNvYmY1M3NuZGFhemJ3N3J6aXozZm5wamEK" -H "Content-Type: application/json" "https://tfsci.mindeservices.com/tfs/MobilityCoE/U1070_QuickForm/_apis/git/repositories?api-version=6.0" 

    # curl --location 'https://tfsci.mindeservices.com/tfs/MobilityCoE/U1070_QuickForm/_apis/git/repositories' \
    # --header 'Authorization: Basic OnA2bXN0czJjZ2U1ZHpoZXBsZWd0anAyM2QybXNvYmY1M3NuZGFhemJ3N3J6aXozZm5wamE=' \
    # --header 'Content-Type: application/json'
# done