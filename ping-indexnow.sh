#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# ping-indexnow.sh
#
# Submits one or more URLs to IndexNow so Bing, Yandex, and other
# participating engines pick up new/updated pages within minutes.
#
# USAGE
#   ./ping-indexnow.sh                        # submit all journal articles
#   ./ping-indexnow.sh /article-7 /journal    # submit specific paths
#
# RUN THIS after every deploy that adds or updates a journal article.
# ─────────────────────────────────────────────────────────────────

KEY="59d835275ba0b279207b95cf1ad930ed"
HOST="handledstudio.com.au"
KEY_LOCATION="https://${HOST}/${KEY}.txt"
ENDPOINT="https://api.indexnow.org/indexnow"

# Default: all journal article URLs
DEFAULT_URLS=(
  "https://${HOST}/article-1"
  "https://${HOST}/article-2"
  "https://${HOST}/article-3"
  "https://${HOST}/article-4"
  "https://${HOST}/article-5"
  "https://${HOST}/article-6"
  "https://${HOST}/article-7"
  "https://${HOST}/article-8"
  "https://${HOST}/article-9"
  "https://${HOST}/article-10"
  "https://${HOST}/article-11"
  "https://${HOST}/article-12"
  "https://${HOST}/article-13"
  "https://${HOST}/article-14"
  "https://${HOST}/article-15"
  "https://${HOST}/journal"
)

# Build URL list from args or use defaults
if [ $# -gt 0 ]; then
  URL_LIST=()
  for path in "$@"; do
    URL_LIST+=("\"https://${HOST}${path}\"")
  done
else
  URL_LIST=()
  for url in "${DEFAULT_URLS[@]}"; do
    URL_LIST+=("\"${url}\"")
  done
fi

# Join into JSON array
URLS_JSON=$(IFS=,; echo "${URL_LIST[*]}")

PAYLOAD=$(cat <<JSON
{
  "host": "${HOST}",
  "key": "${KEY}",
  "keyLocation": "${KEY_LOCATION}",
  "urlList": [${URLS_JSON}]
}
JSON
)

echo "Submitting to IndexNow..."
echo "${PAYLOAD}" | python3 -m json.tool --no-indent > /dev/null && echo "Payload valid ✓"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "${PAYLOAD}")

if [ "${HTTP_STATUS}" = "200" ] || [ "${HTTP_STATUS}" = "202" ]; then
  echo "IndexNow accepted (HTTP ${HTTP_STATUS}) ✓"
else
  echo "IndexNow returned HTTP ${HTTP_STATUS} — check URL/key and retry"
  exit 1
fi
