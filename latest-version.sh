#!/bin/zsh

source .versions

# Latest TagLib version
# GitHub repository in the format OWNER/REPO
REPO="taglib/taglib"

# GitHub API URL for fetching tags
API_URL="https://api.github.com/repos/$REPO/tags"

# Use curl to fetch the latest tag information from GitHub API
# Use jq to parse the JSON and extract tag name and commit sha
LATEST_TAG_INFO=$(curl -s $API_URL | jq -r '.[0] | {tag_name: .name, sha: .commit.sha}')

if [ -z "$LATEST_TAG_INFO" ]; then
    echo "Failed to fetch the latest tag information."
    exit 1
fi

# Extracting tag name and sha
TAG_NAME=$(echo "$LATEST_TAG_INFO" | jq -r '.tag_name' | tr -d v)
SHA=$(echo "$LATEST_TAG_INFO" | jq -r '.sha')

echo "TAGLIB_VERSION=\"$TAG_NAME\""
echo "TAGLIB_SHA=\"$SHA\""
