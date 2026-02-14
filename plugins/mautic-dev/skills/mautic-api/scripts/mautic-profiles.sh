#!/bin/bash
# Mautic API Profile Manager
# Manages instance credentials in ~/.mautic-api-profiles
#
# Usage:
#   bash mautic-profiles.sh list
#   bash mautic-profiles.sh show <name>
#   bash mautic-profiles.sh load <name>
#   bash mautic-profiles.sh add <name> <url> oauth2 <client_id> <client_secret>
#   bash mautic-profiles.sh add <name> <url> basic <username> <password>
#   bash mautic-profiles.sh edit <name> <key> <value>
#   bash mautic-profiles.sh remove <name>
#
# File: ~/.mautic-api-profiles (chmod 600, INI-style)

set -euo pipefail

CONFIG_FILE="${HOME}/.mautic-api-profiles"
ACTION="${1:-}"

VALID_KEYS_COMMON="MAUTIC_BASE_URL MAUTIC_AUTH_TYPE"
VALID_KEYS_OAUTH2="MAUTIC_CLIENT_ID MAUTIC_CLIENT_SECRET"
VALID_KEYS_BASIC="MAUTIC_USERNAME MAUTIC_PASSWORD"
ALL_VALID_KEYS="$VALID_KEYS_COMMON $VALID_KEYS_OAUTH2 $VALID_KEYS_BASIC"

ensure_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
    fi
    local PERMS
    PERMS=$(stat -c '%a' "$CONFIG_FILE" 2>/dev/null || stat -f '%Lp' "$CONFIG_FILE" 2>/dev/null)
    if [ "$PERMS" != "600" ] && [ "$PERMS" != "400" ]; then
        echo "WARNING: $CONFIG_FILE has permissions $PERMS (should be 600). Run: chmod 600 $CONFIG_FILE" >&2
    fi
}

get_profiles() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return
    fi
    grep '^\[' "$CONFIG_FILE" 2>/dev/null | sed 's/\[//;s/\]//' || true
}

profile_exists() {
    local name="$1"
    get_profiles | grep -qx "$name" 2>/dev/null
}

# Read a single key from a profile section
read_profile_key() {
    local name="$1" target_key="$2"
    local in_section=false
    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^\[([^]]+)\] ]]; then
            [ "${BASH_REMATCH[1]}" = "$name" ] && in_section=true || in_section=false
            continue
        fi
        if $in_section; then
            local key val
            key=$(echo "$line" | cut -d'=' -f1 | xargs)
            val=$(echo "$line" | cut -d'=' -f2- | xargs)
            if [ "$key" = "$target_key" ]; then
                echo "$val"
                return
            fi
        fi
    done < "$CONFIG_FILE"
}

# ── LIST ──────────────────────────────────────────────
do_list() {
    ensure_config
    local profiles
    profiles=$(get_profiles)
    if [ -z "$profiles" ]; then
        echo "No profiles configured."
        echo "Add one with:"
        echo "  bash $0 add <name> <url> oauth2 <client_id> <client_secret>"
        echo "  bash $0 add <name> <url> basic <username> <password>"
        return
    fi
    echo "Profiles in $CONFIG_FILE:"
    echo ""
    while IFS= read -r name; do
        local url auth_type
        url=$(read_profile_key "$name" "MAUTIC_BASE_URL")
        auth_type=$(read_profile_key "$name" "MAUTIC_AUTH_TYPE")
        auth_type="${auth_type:-oauth2}"
        echo "  $name  →  $url  [$auth_type]"
    done <<< "$profiles"
}

# ── SHOW ──────────────────────────────────────────────
do_show() {
    local name="${2:?Usage: mautic-profiles.sh show <name>}"
    ensure_config
    if ! profile_exists "$name"; then
        echo "ERROR: Profile '$name' not found." >&2
        echo "Available: $(get_profiles | tr '\n' ' ')" >&2
        exit 1
    fi
    local in_section=false
    echo "[$name]"
    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^\[([^]]+)\] ]]; then
            [ "${BASH_REMATCH[1]}" = "$name" ] && in_section=true || in_section=false
            continue
        fi
        if $in_section; then
            local key val
            key=$(echo "$line" | cut -d'=' -f1 | xargs)
            val=$(echo "$line" | cut -d'=' -f2- | xargs)
            case "$key" in
                MAUTIC_CLIENT_SECRET|MAUTIC_PASSWORD)
                    echo "  $key=${val:0:4}****"
                    ;;
                *)
                    echo "  $key=$val"
                    ;;
            esac
        fi
    done < "$CONFIG_FILE"
}

# ── LOAD ──────────────────────────────────────────────
do_load() {
    local name="${2:?Usage: mautic-profiles.sh load <name>}"
    ensure_config
    if ! profile_exists "$name"; then
        echo "ERROR: Profile '$name' not found." >&2
        echo "Available: $(get_profiles | tr '\n' ' ')" >&2
        exit 1
    fi

    local in_section=false
    local base_url="" auth_type="" client_id="" client_secret="" username="" password=""
    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        if [[ "$line" =~ ^\[([^]]+)\] ]]; then
            [ "${BASH_REMATCH[1]}" = "$name" ] && in_section=true || in_section=false
            continue
        fi
        if $in_section; then
            local key val
            key=$(echo "$line" | cut -d'=' -f1 | xargs)
            val=$(echo "$line" | cut -d'=' -f2- | xargs)
            case "$key" in
                MAUTIC_BASE_URL) base_url="$val" ;;
                MAUTIC_AUTH_TYPE) auth_type="$val" ;;
                MAUTIC_CLIENT_ID) client_id="$val" ;;
                MAUTIC_CLIENT_SECRET) client_secret="$val" ;;
                MAUTIC_USERNAME) username="$val" ;;
                MAUTIC_PASSWORD) password="$val" ;;
            esac
        fi
    done < "$CONFIG_FILE"

    auth_type="${auth_type:-oauth2}"

    # Validate
    if [ -z "$base_url" ]; then
        echo "ERROR: Profile '$name' missing MAUTIC_BASE_URL" >&2
        exit 1
    fi

    # Escape single quotes in values to prevent command injection when eval'd
    local esc_base_url="${base_url//\'/\'\\\'\'}"
    local esc_name="${name//\'/\'\\\'\'}"

    echo "export MAUTIC_BASE_URL='${esc_base_url}'"
    echo "export MAUTIC_AUTH_TYPE='${auth_type}'"
    echo "export MAUTIC_PROFILE='${esc_name}'"

    case "$auth_type" in
        oauth2)
            local missing=""
            [ -z "$client_id" ] && missing="$missing MAUTIC_CLIENT_ID"
            [ -z "$client_secret" ] && missing="$missing MAUTIC_CLIENT_SECRET"
            if [ -n "$missing" ]; then
                echo "ERROR: Profile '$name' (oauth2) missing:$missing" >&2
                exit 1
            fi
            local esc_client_id="${client_id//\'/\'\\\'\'}"
            local esc_client_secret="${client_secret//\'/\'\\\'\'}"
            echo "export MAUTIC_CLIENT_ID='${esc_client_id}'"
            echo "export MAUTIC_CLIENT_SECRET='${esc_client_secret}'"
            # Clear basic auth vars
            echo "unset MAUTIC_USERNAME 2>/dev/null; true"
            echo "unset MAUTIC_PASSWORD 2>/dev/null; true"
            ;;
        basic)
            local missing=""
            [ -z "$username" ] && missing="$missing MAUTIC_USERNAME"
            [ -z "$password" ] && missing="$missing MAUTIC_PASSWORD"
            if [ -n "$missing" ]; then
                echo "ERROR: Profile '$name' (basic) missing:$missing" >&2
                exit 1
            fi
            local esc_username="${username//\'/\'\\\'\'}"
            local esc_password="${password//\'/\'\\\'\'}"
            echo "export MAUTIC_USERNAME='${esc_username}'"
            echo "export MAUTIC_PASSWORD='${esc_password}'"
            # Clear oauth2 vars
            echo "unset MAUTIC_CLIENT_ID 2>/dev/null; true"
            echo "unset MAUTIC_CLIENT_SECRET 2>/dev/null; true"
            echo "unset MAUTIC_ACCESS_TOKEN 2>/dev/null; true"
            ;;
        *)
            echo "ERROR: Unknown auth type '$auth_type' in profile '$name'. Must be 'oauth2' or 'basic'." >&2
            exit 1
            ;;
    esac
}

# ── ADD ───────────────────────────────────────────────
do_add() {
    local name="${2:?Usage: mautic-profiles.sh add <name> <url> <oauth2|basic> <credentials...>}"
    local url="${3:?Missing <url>}"
    local auth_type="${4:?Missing <auth_type> (oauth2 or basic)}"
    ensure_config

    if profile_exists "$name"; then
        echo "ERROR: Profile '$name' already exists. Use 'edit' to modify or 'remove' first." >&2
        exit 1
    fi

    url="${url%/}"

    case "$auth_type" in
        oauth2)
            local client_id="${5:?Missing <client_id>}"
            local client_secret="${6:?Missing <client_secret>}"
            {
                [ -s "$CONFIG_FILE" ] && echo ""
                echo "[$name]"
                echo "MAUTIC_BASE_URL=$url"
                echo "MAUTIC_AUTH_TYPE=oauth2"
                echo "MAUTIC_CLIENT_ID=$client_id"
                echo "MAUTIC_CLIENT_SECRET=$client_secret"
            } >> "$CONFIG_FILE"
            echo "Profile '$name' added ($url) [oauth2]"
            ;;
        basic)
            local username="${5:?Missing <username>}"
            local password="${6:?Missing <password>}"
            {
                [ -s "$CONFIG_FILE" ] && echo ""
                echo "[$name]"
                echo "MAUTIC_BASE_URL=$url"
                echo "MAUTIC_AUTH_TYPE=basic"
                echo "MAUTIC_USERNAME=$username"
                echo "MAUTIC_PASSWORD=$password"
            } >> "$CONFIG_FILE"
            echo "Profile '$name' added ($url) [basic]"
            ;;
        *)
            echo "ERROR: Auth type must be 'oauth2' or 'basic', got '$auth_type'" >&2
            echo "Usage:" >&2
            echo "  bash $0 add <name> <url> oauth2 <client_id> <client_secret>" >&2
            echo "  bash $0 add <name> <url> basic <username> <password>" >&2
            exit 1
            ;;
    esac
}

# ── EDIT ──────────────────────────────────────────────
do_edit() {
    local name="${2:?Usage: mautic-profiles.sh edit <name> <key> <value>}"
    local key="${3:?Missing <key>}"
    local value="${4:?Missing <value>}"
    ensure_config

    if ! profile_exists "$name"; then
        echo "ERROR: Profile '$name' not found." >&2
        exit 1
    fi

    # Validate key
    local valid=false
    for k in $ALL_VALID_KEYS; do
        [ "$k" = "$key" ] && valid=true
    done
    if ! $valid; then
        echo "ERROR: Invalid key '$key'." >&2
        echo "Valid keys: $ALL_VALID_KEYS" >&2
        exit 1
    fi

    # Validate auth type value
    if [ "$key" = "MAUTIC_AUTH_TYPE" ] && [ "$value" != "oauth2" ] && [ "$value" != "basic" ]; then
        echo "ERROR: MAUTIC_AUTH_TYPE must be 'oauth2' or 'basic'." >&2
        exit 1
    fi

    [ "$key" = "MAUTIC_BASE_URL" ] && value="${value%/}"

    # Rewrite file with updated value
    local tmpfile
    tmpfile=$(mktemp)
    trap 'rm -f "$tmpfile"' EXIT
    local in_section=false replaced=false
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^\[([^]]+)\] ]]; then
            [ "${BASH_REMATCH[1]}" = "$name" ] && in_section=true || in_section=false
            echo "$line" >> "$tmpfile"
            continue
        fi
        if $in_section && [[ "$line" =~ ^[[:space:]]*${key}[[:space:]]*= ]]; then
            echo "$key=$value" >> "$tmpfile"
            replaced=true
        else
            echo "$line" >> "$tmpfile"
        fi
    done < "$CONFIG_FILE"

    # If key didn't exist in section, append it
    if ! $replaced; then
        local tmpfile2
        tmpfile2=$(mktemp)
        trap 'rm -f "$tmpfile" "$tmpfile2"' EXIT
        in_section=false
        local inserted=false
        while IFS= read -r line || [ -n "$line" ]; do
            if [[ "$line" =~ ^\[([^]]+)\] ]]; then
                if $in_section && ! $inserted; then
                    echo "$key=$value" >> "$tmpfile2"
                    inserted=true
                fi
                [ "${BASH_REMATCH[1]}" = "$name" ] && in_section=true || in_section=false
            fi
            echo "$line" >> "$tmpfile2"
        done < "$tmpfile"
        if $in_section && ! $inserted; then
            echo "$key=$value" >> "$tmpfile2"
        fi
        mv "$tmpfile2" "$tmpfile"
    fi

    mv "$tmpfile" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    echo "Profile '$name': $key updated"
}

# ── REMOVE ────────────────────────────────────────────
do_remove() {
    local name="${2:?Usage: mautic-profiles.sh remove <name>}"
    ensure_config

    if ! profile_exists "$name"; then
        echo "ERROR: Profile '$name' not found." >&2
        exit 1
    fi

    local tmpfile
    tmpfile=$(mktemp)
    trap 'rm -f "$tmpfile"' EXIT
    local in_section=false skip_blanks=false
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^\[([^]]+)\] ]]; then
            if [ "${BASH_REMATCH[1]}" = "$name" ]; then
                in_section=true
                skip_blanks=true
                continue
            else
                in_section=false
                skip_blanks=false
            fi
        fi
        if $in_section; then
            continue
        fi
        if $skip_blanks && [[ -z "$line" ]]; then
            skip_blanks=false
            continue
        fi
        skip_blanks=false
        echo "$line" >> "$tmpfile"
    done < "$CONFIG_FILE"

    mv "$tmpfile" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    echo "Profile '$name' removed"
}

# ── DISPATCH ──────────────────────────────────────────
case "$ACTION" in
    list|ls)    do_list ;;
    show)       do_show "$@" ;;
    load)       do_load "$@" ;;
    add)        do_add "$@" ;;
    edit)       do_edit "$@" ;;
    remove|rm)  do_remove "$@" ;;
    "")
        echo "Usage: mautic-profiles.sh <action> [args]" >&2
        echo "" >&2
        echo "Actions:" >&2
        echo "  list                                                    List all profiles" >&2
        echo "  show   <name>                                           Show profile (secrets masked)" >&2
        echo "  load   <name>                                           Output export statements" >&2
        echo "  add    <name> <url> oauth2 <client_id> <secret>         Add OAuth2 profile" >&2
        echo "  add    <name> <url> basic  <username> <password>        Add Basic Auth profile" >&2
        echo "  edit   <name> <key> <value>                             Update a profile field" >&2
        echo "  remove <name>                                           Delete a profile" >&2
        exit 1
        ;;
    *)
        echo "ERROR: Unknown action '$ACTION'. Use: list, show, load, add, edit, remove" >&2
        exit 1
        ;;
esac
