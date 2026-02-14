---
name: mautic-api
description: This skill should be used when the user asks to "create mautic email", "update email html", "send email via api", "list mautic emails", "delete mautic email", "mautic api", "mautic email api", "send email to contact", "get email by id", "batch create emails", "add mautic instance", "list mautic profiles", "remove mautic profile", "manage api profiles", or mentions Mautic REST API operations or API instance management. Provides curl-based workflows for Mautic REST API with multi-instance profile management and OAuth2 or Basic Auth.
version: 1.0.0
---

# Mautic API

Interact with the Mautic REST API using curl. Supports OAuth2 Client Credentials and Basic Auth with multi-instance profile management.

## Prerequisites

**Dependencies:** `curl`, `python3` (for JSON parsing).

## Script Directory

All bundled scripts are in the `scripts/` subdirectory of this skill. Resolve the absolute path to the directory containing this SKILL.md file and use it as prefix for all script calls.

## Instance Profiles

Credentials for multiple Mautic instances are stored in `~/.mautic-api-profiles` (`chmod 600`, INI-style). Each profile specifies its auth type. Manage with `scripts/mautic-profiles.sh`:

**Add profiles:**
```bash
bash /path/to/scripts/mautic-profiles.sh add production https://mautic.example.com oauth2 1_abc123 secret123
bash /path/to/scripts/mautic-profiles.sh add staging https://staging.example.com basic admin mypassword
```

**List / Show / Edit / Remove:**
```bash
bash /path/to/scripts/mautic-profiles.sh list
bash /path/to/scripts/mautic-profiles.sh show production
bash /path/to/scripts/mautic-profiles.sh edit production MAUTIC_BASE_URL https://new-url.example.com
bash /path/to/scripts/mautic-profiles.sh remove staging
```
Valid edit keys: `MAUTIC_BASE_URL`, `MAUTIC_AUTH_TYPE`, `MAUTIC_CLIENT_ID`, `MAUTIC_CLIENT_SECRET`, `MAUTIC_USERNAME`, `MAUTIC_PASSWORD`.

**Load a profile** (sets env vars for API calls):
```bash
eval "$(bash /path/to/scripts/mautic-profiles.sh load production)"
```
Exports `MAUTIC_BASE_URL`, `MAUTIC_AUTH_TYPE`, `MAUTIC_PROFILE`, and auth-specific credentials. Clears the other auth type's vars to prevent conflicts.

### When the user mentions an instance name

If the user says "create email on production" or "list emails on staging", load the matching profile name before making API calls. If the profile doesn't exist, list available profiles and ask which one to use.

### When the user asks to manage profiles

If the user says "add mautic instance", "list profiles", "remove profile", etc., use `mautic-profiles.sh` with the appropriate action. Always use `show` (not `load`) when displaying profile info to the user, since `show` masks secrets.

### Mautic API Credentials Setup

**For OAuth2:**
1. Settings > Configuration > API Settings > Enable API: Yes > Save
2. Settings > API Credentials > +New > OAuth 2
3. Enter name, set redirect URI to the Mautic domain URL
4. Save and note Client ID and Client Secret

**For Basic Auth:**
1. Settings > Configuration > API Settings > Enable API: Yes
2. Enable HTTP basic auth: Yes > Save
3. Use any Mautic user's username and password

## Authentication Workflow

The auth script handles both types automatically based on `MAUTIC_AUTH_TYPE`:

```bash
export MAUTIC_ACCESS_TOKEN=$(bash /path/to/scripts/mautic-auth.sh)
```

- **OAuth2**: Requests token from `/oauth/v2/token`. Valid 3600s. Re-run when expired.
- **Basic Auth**: Encodes `username:password` as base64. No expiration.

Both produce `MAUTIC_ACCESS_TOKEN` that `mautic-api.sh` uses with the correct `Authorization` header.

## Standard Workflow

```bash
eval "$(bash /path/to/scripts/mautic-profiles.sh load <profile>)"
export MAUTIC_ACCESS_TOKEN=$(bash /path/to/scripts/mautic-auth.sh)
bash /path/to/scripts/mautic-api.sh <METHOD> <ENDPOINT> [JSON_BODY]
```

Handle errors: expired token → re-authenticate, 400 → check fields, 403 → check permissions.

---

## Email API

Base path: `/api/emails`

### List Emails

```bash
bash /path/to/scripts/mautic-api.sh GET "/api/emails?limit=10&orderBy=dateAdded&orderByDir=DESC"
```

Query params: `search`, `start`, `limit`, `orderBy`, `orderByDir`, `publishedOnly`, `minimal`.
Search commands: `is:published`, `is:unpublished`, `name:value`, `subject:value`, `category:name`.

### Get / Create / Update / Delete

```bash
bash /path/to/scripts/mautic-api.sh GET /api/emails/{id}

bash /path/to/scripts/mautic-api.sh POST /api/emails/new \
    '{"name":"Email Name","subject":"Subject","customHtml":"<h1>Hello</h1>","emailType":"template","isPublished":true}'

bash /path/to/scripts/mautic-api.sh PATCH /api/emails/{id}/edit \
    '{"customHtml":"<h1>Updated</h1>"}'

bash /path/to/scripts/mautic-api.sh DELETE /api/emails/{id}/delete
```

Required fields: `name`, `subject`. Key optional: `customHtml`, `emailType` (`template`|`list`), `fromAddress`, `fromName`, `isPublished`.

### Send Email

```bash
# To specific contact
bash /path/to/scripts/mautic-api.sh POST /api/emails/{id}/contact/{contactId}/send \
    '{"tokens":{"{custom_token}":"value"}}'

# To segment
bash /path/to/scripts/mautic-api.sh POST /api/emails/{id}/send '{"limit":100}'
```

### Email Fields Quick Reference

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | Yes | Internal name |
| subject | string | Yes | Email subject line |
| customHtml | string | No | HTML body content |
| plainText | string | No | Plain text version |
| emailType | string | No | `template` or `list` |
| fromAddress | string | No | Sender email |
| fromName | string | No | Sender display name |
| isPublished | bool | No | Published status |
| lists | array | No* | Segment IDs (*required for `list` type) |
| category | int | No | Category ID |

For the complete field list (20+ fields), see `references/email-api-reference.md`.

### Personalization Tokens

Use in `customHtml`: `{contactfield=firstname}`, `{unsubscribe_text}`, `{webview_text}`, `{tracking_pixel}`.
Full token list in `references/email-api-reference.md`.

---

## Additional Resources

### Reference Files

- **`references/email-api-reference.md`** - Complete Email API: all endpoints, batch operations, dynamic content, UTM tags, error responses, pagination

### Scripts

- **`scripts/mautic-profiles.sh`** - Profile manager (list, show, load, add, edit, remove)
- **`scripts/mautic-auth.sh`** - Authentication helper (OAuth2 token or Basic Auth encoding)
- **`scripts/mautic-api.sh`** - General API request helper (any method/endpoint)
