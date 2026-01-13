---
name: Mautic REST API
description: This skill should be used when the user asks about "Mautic REST API", "API endpoint", "API controller", "webhook", "API authentication", "OAuth", or needs guidance on building or consuming Mautic's API.
version: 0.1.0
---

# Mautic REST API

> **Status:** Planned - This skill is under development.

This skill will provide guidance for working with Mautic's REST API.

## Planned Content

- API controller patterns
- Route definitions
- Authentication (OAuth, Basic Auth, API keys)
- Request/Response handling
- Webhook implementation
- API versioning
- Rate limiting

## API Base URL

```
/api/
```

## File Locations

| Category | Location |
|----------|----------|
| API Controllers | `/app/bundles/{Bundle}/Controller/Api/` |
| API Routes | `/app/bundles/{Bundle}/Config/config.php` |

## Additional Resources

Detailed references will be added in:
- `references/endpoints.md`
- `references/authentication.md`
- `references/webhooks.md`
