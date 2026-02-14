#!/bin/bash
# Mautic API Request Helper
# Supports both OAuth2 Bearer token and Basic Auth
#
# Usage: bash mautic-api.sh <METHOD> <ENDPOINT> [JSON_BODY]
#
# Examples:
#   bash mautic-api.sh GET /api/emails
#   bash mautic-api.sh GET "/api/emails?search=newsletter&limit=10"
#   bash mautic-api.sh POST /api/emails/new '{"name":"Test","subject":"Test Subject"}'
#   bash mautic-api.sh PATCH /api/emails/5/edit '{"customHtml":"<h1>Updated</h1>"}'
#   bash mautic-api.sh DELETE /api/emails/5/delete
#
# Required environment variables:
#   MAUTIC_BASE_URL       - Mautic instance URL
#   MAUTIC_AUTH_TYPE      - 'oauth2' (default) or 'basic'
#
# For oauth2: MAUTIC_ACCESS_TOKEN (obtain via mautic-auth.sh)
# For basic:  MAUTIC_ACCESS_TOKEN (base64 creds from mautic-auth.sh)
#         or: MAUTIC_USERNAME + MAUTIC_PASSWORD (used directly)

set -euo pipefail

METHOD="${1:?Usage: mautic-api.sh <METHOD> <ENDPOINT> [JSON_BODY]}"
ENDPOINT="${2:?Usage: mautic-api.sh <METHOD> <ENDPOINT> [JSON_BODY]}"
BODY="${3:-}"

if [ -z "${MAUTIC_BASE_URL:-}" ]; then
    echo "ERROR: MAUTIC_BASE_URL environment variable is not set" >&2
    exit 1
fi

AUTH_TYPE="${MAUTIC_AUTH_TYPE:-oauth2}"
BASE_URL="${MAUTIC_BASE_URL%/}"

# Build curl command
CURL_ARGS=(
    -s
    -X "$METHOD"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
    -w "\n%{http_code}"
)

# Add auth header based on type
case "$AUTH_TYPE" in
    oauth2)
        if [ -z "${MAUTIC_ACCESS_TOKEN:-}" ]; then
            echo "ERROR: MAUTIC_ACCESS_TOKEN is not set. Run mautic-auth.sh first." >&2
            exit 1
        fi
        CURL_ARGS+=(-H "Authorization: Bearer ${MAUTIC_ACCESS_TOKEN}")
        ;;
    basic)
        if [ -n "${MAUTIC_ACCESS_TOKEN:-}" ]; then
            # Use pre-encoded base64 token from mautic-auth.sh
            CURL_ARGS+=(-H "Authorization: Basic ${MAUTIC_ACCESS_TOKEN}")
        elif [ -n "${MAUTIC_USERNAME:-}" ] && [ -n "${MAUTIC_PASSWORD:-}" ]; then
            # Use username:password directly
            CURL_ARGS+=(-u "${MAUTIC_USERNAME}:${MAUTIC_PASSWORD}")
        else
            echo "ERROR: Basic auth requires MAUTIC_ACCESS_TOKEN or MAUTIC_USERNAME+MAUTIC_PASSWORD" >&2
            exit 1
        fi
        ;;
    *)
        echo "ERROR: Unknown MAUTIC_AUTH_TYPE '$AUTH_TYPE'. Must be 'oauth2' or 'basic'." >&2
        exit 1
        ;;
esac

if [ -n "$BODY" ]; then
    CURL_ARGS+=(-d "$BODY")
fi

# Make request
RESPONSE=$(curl "${CURL_ARGS[@]}" "${BASE_URL}${ENDPOINT}")

# Separate body and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Check for HTTP errors
if [ "$HTTP_CODE" -ge 400 ] 2>/dev/null; then
    echo "HTTP $HTTP_CODE Error:" >&2
    echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE_BODY" >&2
    exit 1
fi

# Pretty-print JSON response
echo "$RESPONSE_BODY" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE_BODY"
