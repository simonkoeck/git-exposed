#!/bin/bash

# Ensure URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

url=$1
target_dir=$(basename $url)

# Check if .git directory is accessible
if curl --output /dev/null --silent --head --fail "$url/.git"; then
    echo ".git directory found, starting download. this may take a while..."
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
