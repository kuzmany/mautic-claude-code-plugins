# Mautic Email API - Complete Reference

## Authentication

### Client Credentials Flow

Obtain an access token using OAuth2 Client Credentials:

```bash
curl -s -X POST "${MAUTIC_BASE_URL}/oauth/v2/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials" \
    -d "client_id=${MAUTIC_CLIENT_ID}" \
    -d "client_secret=${MAUTIC_CLIENT_SECRET}"
```

**Response:**
```json
{
    "access_token": "YWM5YjM...NjMxZjVj",
    "expires_in": 3600,
    "token_type": "bearer",
    "scope": ""
}
```

### Using the Token

Include in all requests:
```
Authorization: Bearer {access_token}
```

### Setup in Mautic Admin

1. Go to Settings (gear icon) > Configuration > API Settings
2. Enable API: Yes
3. Enable HTTP basic auth: No (use OAuth2)
4. Go to Settings > API Credentials
5. Click "+ New" and select "OAuth 2"
6. Enter a name and redirect URI (not needed for Client Credentials, use your domain)
7. Save and note the Client ID and Client Secret

---

## Endpoints

### GET /api/emails - List Emails

List all emails. Returns parent-level emails only (excludes A/B test variants).

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| search | string | - | Filter by search string or search command |
| start | int | 0 | Pagination offset |
| limit | int | 30 | Results per page (max varies by config) |
| orderBy | string | - | Column to sort by (e.g., `name`, `id`, `dateAdded`) |
| orderByDir | string | ASC | Sort direction: `ASC` or `DESC` |
| publishedOnly | bool | false | Return only published emails |
| minimal | bool | false | Exclude nested list data for faster response |

**Example Request:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
    "${MAUTIC_BASE_URL}/api/emails?search=newsletter&limit=10&orderBy=dateAdded&orderByDir=DESC"
```

**Response:**
```json
{
    "total": 42,
    "emails": {
        "1": {
            "id": 1,
            "name": "Welcome Email",
            "subject": "Welcome to Our Newsletter",
            "isPublished": true,
            "dateAdded": "2024-01-15T10:30:00+00:00",
            "customHtml": "<html>...</html>",
            "emailType": "template",
            ...
        }
    }
}
```

**Search Commands:**
- `is:published` / `is:unpublished` - Filter by publish status
- `is:mine` - Filter by owner
- `category:name` - Filter by category name
- `name:value` - Search by name
- `subject:value` - Search by subject

---

### GET /api/emails/{id} - Get Single Email

**Example:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
    "${MAUTIC_BASE_URL}/api/emails/5"
```

**Response:**
```json
{
    "email": {
        "id": 5,
        "name": "Welcome Email",
        "subject": "Welcome!",
        "fromAddress": "hello@example.com",
        "fromName": "Company",
        "replyToAddress": "reply@example.com",
        "bccAddress": "bcc@example.com",
        "customHtml": "<html><body><h1>Welcome</h1></body></html>",
        "plainText": "Welcome!",
        "template": "blank",
        "emailType": "template",
        "language": "en",
        "isPublished": true,
        "publishUp": null,
        "publishDown": null,
        "readCount": 150,
        "sentCount": 500,
        "revision": 3,
        "category": null,
        "lists": [],
        "assetAttachments": [],
        "dynamicContent": [],
        "utmTags": {}
    }
}
```

---

### POST /api/emails/new - Create Email

**Required Fields:**
- `name` (string) - Email name
- `subject` (string) - Email subject

**Optional Fields:**

| Field | Type | Description |
|-------|------|-------------|
| customHtml | string | HTML content of the email |
| plainText | string | Plain text version |
| description | string | Email description |
| fromAddress | string | Sender email address |
| fromName | string | Sender name |
| replyToAddress | string | Reply-To address |
| bccAddress | string | BCC address |
| emailType | string | `template` (transactional) or `list` (segment) |
| template | string | Theme template name (e.g., `blank`) |
| language | string | Language code (e.g., `en`) |
| isPublished | bool | Published status |
| publishUp | datetime | Publish start (ISO 8601) |
| publishDown | datetime | Publish end (ISO 8601) |
| category | int | Category ID |
| lists | array | Segment IDs (required for `emailType: list`) |
| assetAttachments | array | Asset IDs to attach |
| unsubscribeForm | int | Unsubscribe form ID |
| preferenceCenter | int | Preference center page ID |
| useOwnerAsMailer | bool | Use contact owner as sender |
| headers | object | Custom email headers |
| utmTags | object | UTM tracking tags |
| dynamicContent | array | Dynamic content blocks |
| content | array | Template content blocks (for builder templates) |

**Example - Create a template email:**
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/new" \
    -d '{
        "name": "Welcome Email",
        "subject": "Welcome to Our Service!",
        "customHtml": "<html><body><h1>Welcome {contactfield=firstname}!</h1><p>Thank you for signing up.</p></body></html>",
        "plainText": "Welcome {contactfield=firstname}! Thank you for signing up.",
        "fromAddress": "hello@example.com",
        "fromName": "My Company",
        "emailType": "template",
        "isPublished": true,
        "language": "en"
    }'
```

**Example - Create a segment (list) email:**
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/new" \
    -d '{
        "name": "Monthly Newsletter",
        "subject": "Newsletter - January 2025",
        "customHtml": "<html><body><h1>Newsletter</h1></body></html>",
        "emailType": "list",
        "lists": [1, 5],
        "isPublished": true
    }'
```

**Response (201 Created):**
```json
{
    "email": {
        "id": 42,
        "name": "Welcome Email",
        ...
    }
}
```

---

### PATCH /api/emails/{id}/edit - Update Email (Partial)

Send only the fields to update. Other fields remain unchanged.

**Example - Update HTML content:**
```bash
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/42/edit" \
    -d '{
        "customHtml": "<html><body><h1>Updated Content</h1><p>New body text here.</p></body></html>"
    }'
```

**Example - Update subject and publish status:**
```bash
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/42/edit" \
    -d '{
        "subject": "New Subject Line",
        "isPublished": false
    }'
```

---

### PUT /api/emails/{id}/edit - Update Email (Full Replace)

Replace all email fields. If the email ID doesn't exist, creates a new one.

---

### DELETE /api/emails/{id}/delete - Delete Email

**Example:**
```bash
curl -s -X DELETE -H "Authorization: Bearer $TOKEN" \
    "${MAUTIC_BASE_URL}/api/emails/42/delete"
```

**Response:**
```json
{
    "email": {
        "id": 42,
        ...
    }
}
```

---

### POST /api/emails/{id}/contact/{contactId}/send - Send to Contact

Send a transactional email to a specific contact.

**Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| tokens | object | Token replacements `{"{tokenname}": "value"}` |
| assetAttachments | array | Additional asset IDs to attach |

**Example:**
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/42/contact/15/send" \
    -d '{
        "tokens": {
            "{custom_token}": "Custom Value",
            "firstname": "John"
        }
    }'
```

**Response:**
```json
{
    "success": 1
}
```

---

### POST /api/emails/{id}/send - Send to Segment

Send a segment (list) email to its assigned segments.

**Parameters:**

| Field | Type | Description |
|-------|------|-------------|
| lists | array | Override segments - send to specific list IDs |
| limit | int | Max recipients per batch |

**Example:**
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/42/send" \
    -d '{"limit": 100}'
```

**Response:**
```json
{
    "success": 1,
    "sentCount": 95,
    "failedCount": 5
}
```

---

### POST /api/emails/batch/new - Batch Create Emails

Create multiple emails in one request.

**Example:**
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/batch/new" \
    -d '[
        {"name": "Email 1", "subject": "Subject 1", "customHtml": "<h1>Email 1</h1>", "emailType": "template"},
        {"name": "Email 2", "subject": "Subject 2", "customHtml": "<h1>Email 2</h1>", "emailType": "template"}
    ]'
```

---

### PATCH /api/emails/batch/edit - Batch Update Emails

Update multiple emails. Each object must include `id`.

**Example:**
```bash
curl -s -X PATCH -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/batch/edit" \
    -d '[
        {"id": 1, "subject": "Updated Subject 1"},
        {"id": 2, "isPublished": false}
    ]'
```

---

### DELETE /api/emails/batch/delete - Batch Delete Emails

**Example:**
```bash
curl -s -X DELETE -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "${MAUTIC_BASE_URL}/api/emails/batch/delete" \
    -d '{"ids": [1, 2, 3]}'
```

---

### POST /api/emails/reply/{trackingHash} - Record Email Reply

Record that an email received a reply (for tracking purposes).

---

## Mautic Token Syntax in HTML

Use these tokens inside `customHtml` for personalization:

| Token | Description |
|-------|-------------|
| `{contactfield=firstname}` | Contact's first name |
| `{contactfield=lastname}` | Contact's last name |
| `{contactfield=email}` | Contact's email |
| `{contactfield=ALIAS}` | Any contact field by alias |
| `{unsubscribe_text}` | Unsubscribe link with text |
| `{unsubscribe_url}` | Raw unsubscribe URL |
| `{webview_text}` | "View in browser" link |
| `{webview_url}` | Raw webview URL |
| `{tracking_pixel}` | Invisible tracking pixel |
| `{ownerfield=FIELD}` | Contact owner's field |
| `{pagelink=ID}` | Link to a Mautic landing page |
| `{assetlink=ID}` | Link to download a Mautic asset |
| `{formlink=ID}` | Link to a Mautic form |

## Dynamic Content in Emails

```json
{
    "dynamicContent": [
        {
            "tokenName": "Dynamic Content 1",
            "content": "<p>Default content</p>",
            "filters": [
                {
                    "content": "<p>VIP content</p>",
                    "filters": [
                        {
                            "glue": "and",
                            "field": "tags",
                            "type": "tags",
                            "operator": "in",
                            "filter": "vip"
                        }
                    ]
                }
            ]
        }
    ]
}
```

Use in HTML as: `{dynamiccontent="Dynamic Content 1"}`

## UTM Tags

```json
{
    "utmTags": {
        "utmSource": "mautic",
        "utmMedium": "email",
        "utmCampaign": "welcome-series",
        "utmContent": "variant-a",
        "utmTerm": ""
    }
}
```

## Error Responses

### OAuth Error
```json
{
    "error": "invalid_grant",
    "error_description": "The access token provided has expired."
}
```

### API Error
```json
{
    "errors": [
        {
            "message": "name: This value should not be blank.",
            "code": 400,
            "type": null
        }
    ]
}
```

### 403 Forbidden
```json
{
    "error": {
        "message": "You do not have access to the requested area/action.",
        "code": 403
    }
}
```

## Response Headers

All responses include:
- `Mautic-Version` - Instance version (e.g., `4.4.13`)
- Standard HTTP status codes (200, 201, 400, 401, 403, 404)

## Pagination Pattern

For listing emails:
```bash
# Page 1
GET /api/emails?limit=10&start=0

# Page 2
GET /api/emails?limit=10&start=10

# Page 3
GET /api/emails?limit=10&start=20
```

The `total` field in response indicates total available records.
