#!/bin/bash
# Notify IndexNow (Bing, Naver, Seznam.cz, Yandex, Yep) that URLs have changed.
# Google does not participate in IndexNow; it is unaffected by this script.
#
# Usage:
#   bash indexnow.sh https://spencerlee.net/CV/ ...  # submit specific URLs
#   bash indexnow.sh --all                          # submit every page in the sitemap
#
# deploy_website.sh calls this with only the pages that actually changed.
# Use --all sparingly: re-submitting unchanged pages is what IndexNow's rate
# limits are aimed at.
#
# The key file must stay reachable at $KEY_LOCATION; it is served from the
# repo root, which Franklin copies verbatim into __site/.

set -euo pipefail

HOST="spencerlee.net"
KEY="d56a4944abcf44cdafb4276d0cb2904e"
KEY_LOCATION="https://${HOST}/${KEY}.txt"
ENDPOINT="https://api.indexnow.org/indexnow"
SITEMAP="$(dirname "$0")/__site/sitemap.xml"

# Every URL the site actually publishes, in canonical (trailing-slash) form.
# The sitemap is generated from the Markdown sources, so it excludes orphaned
# pages left behind in __site/ by deleted sources.
sitemap_urls() {
  if [ ! -f "$SITEMAP" ]; then
    echo "ERROR: $SITEMAP not found. Build the site first." >&2
    exit 1
  fi
  grep -o '<loc>[^<]*</loc>' "$SITEMAP" |
    sed -e 's|</\?loc>||g' -e 's|/index\.html$|/|' |
    sort -u
}

if [ $# -eq 0 ]; then
  echo "Usage: bash indexnow.sh URL [URL ...] | bash indexnow.sh --all"
  exit 1
fi

if [ "$1" = "--all" ]; then
  mapfile -t urls < <(sitemap_urls)
else
  urls=("$@")
fi

if [ ${#urls[@]} -eq 0 ]; then
  echo "Nothing to submit."
  exit 0
fi

# Every URL must be on $HOST, otherwise IndexNow rejects the whole batch (422).
for u in "${urls[@]}"; do
  case "$u" in
    "https://${HOST}/"*) ;;
    *) echo "ERROR: $u is not under https://${HOST}/"; exit 1 ;;
  esac
done

# Verify the key is actually being served before asking the API to fetch it.
served="$(curl -fsS "$KEY_LOCATION")"
if [ "$served" != "$KEY" ]; then
  echo "ERROR: $KEY_LOCATION does not serve the expected key."
  echo "  expected: $KEY"
  echo "  got:      $served"
  exit 1
fi

payload="$(printf '%s\n' "${urls[@]}" | jq -R . | jq -s \
  --arg host "$HOST" --arg key "$KEY" --arg loc "$KEY_LOCATION" \
  '{host: $host, key: $key, keyLocation: $loc, urlList: .}')"

echo "Submitting ${#urls[@]} URL(s) to IndexNow:"
printf '  %s\n' "${urls[@]}"

status="$(curl -sS -o /tmp/indexnow_response_$$ -w '%{http_code}' \
  -X POST "$ENDPOINT" \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data-binary "$payload")"

body="$(cat /tmp/indexnow_response_$$)"
rm -f /tmp/indexnow_response_$$

case "$status" in
  200) echo "OK: URLs accepted." ;;
  202) echo "Accepted: URLs received, key validation pending." ;;
  400) echo "ERROR 400: malformed request."; echo "$body"; exit 1 ;;
  403) echo "ERROR 403: key not valid (not found at $KEY_LOCATION)."; echo "$body"; exit 1 ;;
  422) echo "ERROR 422: URLs do not belong to $HOST, or the key does not match."; echo "$body"; exit 1 ;;
  429) echo "ERROR 429: rate limited (too many submissions)."; echo "$body"; exit 1 ;;
  *)   echo "ERROR $status:"; echo "$body"; exit 1 ;;
esac
