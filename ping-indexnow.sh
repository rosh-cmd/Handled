#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# ping-indexnow.sh
#
# Submits one or more URLs to IndexNow so Bing, Yandex, and other
# participating engines pick up new/updated pages within minutes.
#
# USAGE
#   ./ping-indexnow.sh                        # submit all journal articles
#   ./ping-indexnow.sh /real-estate-social-media-consistency /journal    # submit specific paths
#
# RUN THIS after every deploy that adds or updates a journal article.
# ─────────────────────────────────────────────────────────────────

KEY="59d835275ba0b279207b95cf1ad930ed"
HOST="handledstudio.com.au"
KEY_LOCATION="https://${HOST}/${KEY}.txt"
ENDPOINT="https://api.indexnow.org/indexnow"

# Default: all journal article URLs
DEFAULT_URLS=(
  "https://${HOST}/why-marketing-looks-inconsistent"
  "https://${HOST}/hiring-designer-vs-design-retainer"
  "https://${HOST}/signs-outgrown-design-setup"
  "https://${HOST}/real-estate-marketing-inconsistent"
  "https://${HOST}/construction-tender-design-mistakes"
  "https://${HOST}/real-cost-of-freelancers"
  "https://${HOST}/real-estate-social-media-consistency"
  "https://${HOST}/graphic-designer-real-estate-melbourne"
  "https://${HOST}/consistent-listing-marketing-without-designer"
  "https://${HOST}/property-marketing-materials-melbourne"
  "https://${HOST}/real-estate-agent-bio-design"
  "https://${HOST}/capability-statement-design"
  "https://${HOST}/tender-document-design-construction"
  "https://${HOST}/construction-marketing-materials"
  "https://${HOST}/graphic-designer-construction-companies"
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
