#!/bin/bash

# Ensure URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

url=$1
target_dir=$(basename $url)

github_user=simonkoeck
github_repo=git-exposed

# Path to this script
script_path=$(realpath "$0")

# Get the timestamp of the last commit to the repo
github_time=$(curl --silent https://api.github.com/repos/$github_user/$github_repo/git/refs/heads/master \
    | grep -Po '"date": "\K.*?(?=")' | head -1)

# Convert the GitHub timestamp to seconds since the Unix epoch
github_time_epoch=$(date --date="$github_time" +%s)

# Get the timestamp of the last modification to this script and convert it to seconds since the Unix epoch
script_time_epoch=$(stat -c %Y "$script_path")

# If the GitHub version is newer, print a warning
if [ "$github_time_epoch" -gt "$script_time_epoch" ]; then
    echo "A newer version of this script is available. Please update your local version."
fi

# Check if .git directory is accessible
if curl --output /dev/null --silent --head --fail "$url/.git"; then
    echo ".git directory found, starting download. This may take a while..."
else
    echo ".git directory not found at $url"
    exit 1
fi

# Download .git directory
wget --mirror -I .git $url/.git 2> /dev/null

# Move to target directory
cd $target_dir

# Reset to the latest commit
git reset --hard

echo "Project has been downloaded and reconstructed in the $target_dir directory."
