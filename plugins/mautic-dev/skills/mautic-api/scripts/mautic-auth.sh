#!/bin/bash
# Mautic Authentication Helper
# Handles both OAuth2 Client Credentials and Basic Auth
#
# Usage: export MAUTIC_ACCESS_TOKEN=$(bash mautic-auth.sh)
#
# For OAuth2 (MAUTIC_AUTH_TYPE=oauth2 or unset):
#   Required: MAUTIC_BASE_URL, MAUTIC_CLIENT_ID, MAUTIC_CLIENT_SECRET
#   Output: Prints access token to stdout
#
# For Basic Auth (MAUTIC_AUTH_TYPE=basic):
#   Required: MAUTIC_USERNAME, MAUTIC_PASSWORD
#   Output: Prints base64-encoded credentials to stdout
#   (mautic-api.sh uses this automatically)

set -euo pipefail

AUTH_TYPE="${MAUTIC_AUTH_TYPE:-oauth2}"

case "$AUTH_TYPE" in
    oauth2)
        # Validate required environment variables
        for var in MAUTIC_BASE_URL MAUTIC_CLIENT_ID MAUTIC_CLIENT_SECRET; do
            if [ -z "${!var:-}" ]; then
                echo "ERROR: $var environment variable is not set" >&2
                exit 1
            fi
        done

        BASE_URL="${MAUTIC_BASE_URL%/}"

        RESPONSE=$(curl -s -X POST "${BASE_URL}/oauth/v2/token" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "grant_type=client_credentials" \
            -d "client_id=${MAUTIC_CLIENT_ID}" \
            -d "client_secret=${MAUTIC_CLIENT_SECRET}")

        if echo "$RESPONSE" | grep -q '"error"'; then
            ERROR=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error_description', d.get('error', 'Unknown error')))" 2>/dev/null || echo "$RESPONSE")
            echo "ERROR: Authentication failed: $ERROR" >&2
            exit 1
        fi

        TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)

        if [ -z "$TOKEN" ]; then
            echo "ERROR: Failed to extract access token from response" >&2
            echo "Response: $RESPONSE" >&2
            exit 1
        fi

        export MAUTIC_ACCESS_TOKEN="$TOKEN"
        echo "$TOKEN"
        ;;

    basic)
        for var in MAUTIC_USERNAME MAUTIC_PASSWORD; do
            if [ -z "${!var:-}" ]; then
                echo "ERROR: $var environment variable is not set" >&2
                exit 1
            fi
        done

        # Output base64-encoded credentials for Authorization header
        TOKEN=$(printf '%s:%s' "$MAUTIC_USERNAME" "$MAUTIC_PASSWORD" | base64 -w0 2>/dev/null || printf '%s:%s' "$MAUTIC_USERNAME" "$MAUTIC_PASSWORD" | base64)

        export MAUTIC_ACCESS_TOKEN="$TOKEN"
        echo "$TOKEN"
        ;;

    *)
        echo "ERROR: Unknown MAUTIC_AUTH_TYPE '$AUTH_TYPE'. Must be 'oauth2' or 'basic'." >&2
        exit 1
        ;;
esac
