#!/bin/bash

# Define repository and branch names
SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

# Abort if there are uncommitted changes (staged or unstaged) or untracked files
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "ERROR: You have uncommitted changes or untracked files."
  echo "Please commit or stash them before deploying."
  git status --short
  exit 1
fi

# Build the site using Franklin.jl
echo "Building the website..."
julia -e 'using Franklin; verify_links(); optimize(); lunr(); verify_links()'


# Preserve __site (Franklin's cache) so code blocks aren't re-evaluated next deploy
mv __site /tmp/__site_backup_$$

# Check out the gh-pages branch or create it if it doesn't exist
if git rev-parse --verify $TARGET_BRANCH; then
  git branch -D $TARGET_BRANCH
fi
git checkout --orphan $TARGET_BRANCH

# Delete the old files
git rm -rf .

# Copy new build from backup to root of the branch
cp -r /tmp/__site_backup_$$/* .


# Add changes to git
git add .

# Commit changes
git commit -m "Update website"

# Push to the remote gh-pages branch
git push -f origin $TARGET_BRANCH

# Switch back to the main branch and restore Franklin's cache
git checkout $SOURCE_BRANCH
mv /tmp/__site_backup_$$ __site

echo "Deployment successful!"
