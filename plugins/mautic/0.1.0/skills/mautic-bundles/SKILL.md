---
name: Mautic Bundle Architecture
description: This skill should be used when the user asks to "create bundle", "add service", "dependency injection", "event subscriber", "config.php", "MauticPlugin", or needs guidance on Mautic's bundle-based architecture.
version: 0.1.0
---

# Mautic Bundle Architecture

> **Status:** Planned - This skill is under development.

This skill will provide guidance for understanding and extending Mautic's bundle-based architecture.

## Planned Content

- Bundle structure
- Service definitions (config.php)
- Event system and subscribers
- Dependency injection
- Menu and route configuration
- Plugin vs core bundle differences
- Model layer patterns

## Bundle Structure

```
MauticExampleBundle/
├── Config/
│   └── config.php          # Services, routes, menu
├── Controller/
├── Entity/
├── Event/
├── EventListener/
├── Form/
├── Model/
├── Tests/
└── Views/
```

## File Locations

| Category | Location |
|----------|----------|
| Core Bundles | `/app/bundles/` |
| Plugins | `/plugins/` |

## Additional Resources

Detailed references will be added in:
- `references/config.md`
- `references/services.md`
- `references/events.md`
