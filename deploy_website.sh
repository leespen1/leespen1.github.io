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

# Record what is currently deployed, so we can tell which pages the new build
# actually changes. Empty on a first-ever deploy.
# Time-limited: a wedged SSH control master makes this hang indefinitely rather
# than fail, which would stall the deploy before it has done any work.
if ! timeout 60 git fetch -q origin $TARGET_BRANCH 2>/dev/null; then
  echo "WARNING: could not refresh origin/$TARGET_BRANCH; using the local ref."
  echo "  If this persists: ssh -O exit git@github.com"
fi
PREV_DEPLOY="$(git rev-parse -q --verify origin/$TARGET_BRANCH || true)"

# Build the site using Franklin.jl
echo "Building the website..."
julia --project -e 'using Franklin; verify_links(); optimize(); verify_links()'


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
DEPLOY_COMMIT="$(git rev-parse HEAD)"

# Push to the remote gh-pages branch
git push -f origin $TARGET_BRANCH

# Switch back to the main branch and restore Franklin's cache
git checkout $SOURCE_BRANCH
mv /tmp/__site_backup_$$ __site

echo "Deployment successful!"

# Tell IndexNow (Bing, Naver, Seznam.cz, Yandex, Yep) which pages changed.
# Pages are matched against the sitemap so that orphaned files still sitting in
# __site/ from deleted sources are never submitted.
if [ -z "$PREV_DEPLOY" ]; then
  echo "No previous deploy to compare against; submitting the whole sitemap."
  CHANGED_URLS=(--all)
else
  mapfile -t changed_pages < <(
    git diff --name-only "$PREV_DEPLOY" "$DEPLOY_COMMIT" -- '*.html' |
    sed -e 's|^|https://spencerlee.net/|' -e 's|/index\.html$|/|'
  )
  mapfile -t sitemap_urls < <(
    grep -o '<loc>[^<]*</loc>' __site/sitemap.xml |
    sed -e 's|</\?loc>||g' -e 's|/index\.html$|/|' |
    sort -u
  )
  mapfile -t CHANGED_URLS < <(
    comm -12 \
      <(printf '%s\n' "${changed_pages[@]}" | sort -u) \
      <(printf '%s\n' "${sitemap_urls[@]}")
  )
fi

if [ ${#CHANGED_URLS[@]} -eq 0 ]; then
  echo "No published pages changed; skipping IndexNow submission."
else
  # Deploy has already succeeded, so a ping failure is reported loudly but does
  # not retroactively call the deploy a failure.
  if ! bash "$(dirname "$0")/indexnow.sh" "${CHANGED_URLS[@]}"; then
    echo "WARNING: IndexNow submission failed. The site is deployed; re-run:"
    echo "  bash indexnow.sh ${CHANGED_URLS[*]}"
    exit 1
  fi
fi
