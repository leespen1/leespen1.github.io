#!/bin/bash

# Define repository and branch names
SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

# Build the site using Franklin.jl
echo "Building the website..."
julia -e 'using Franklin; verify_links(); optimize(); verify_links()'  # You might use `build()` if you don't want to serve


# Check out the gh-pages branch or create it if it doesn't exist
if git rev-parse --verify $TARGET_BRANCH; then
  git branch -D $TARGET_BRANCH
fi
git checkout --orphan $TARGET_BRANCH

# Delete the old files
git rm -rf .

# Copy new build from __site to root of the branch
cp -r __site/* .

# Remove the __site directory if it's copied over
rmdir __site

# Add changes to git
git add .

# Commit changes
git commit -m "Update website"

# Push to the remote gh-pages branch
git push -f origin $TARGET_BRANCH

# Optionally switch back to the main branch
git checkout $SOURCE_BRANCH

echo "Deployment successful!"
