---
name: Mautic Database & Migrations
description: This skill should be used when the user asks to "create migration", "add entity field", "Doctrine entity", "database schema", "repository pattern", "create table", "alter table", or needs guidance on Mautic's database layer and Doctrine ORM usage.
version: 0.1.0
---

# Mautic Database & Migrations

> **Status:** Planned - This skill is under development.

This skill will provide guidance for working with Mautic's database layer using Doctrine ORM.

## Planned Content

- Creating database migrations
- Doctrine entity patterns
- Repository classes
- Schema modifications
- Index management
- Foreign key relationships
- Custom field storage

## Key Commands

```bash
# Generate migration
bin/console doctrine:migrations:generate

# Run migrations
bin/console doctrine:migrations:migrate

# Check migration status
bin/console doctrine:migrations:status
```

## File Locations

| Category | Location |
|----------|----------|
| Entities | `/app/bundles/{Bundle}/Entity/` |
| Repositories | `/app/bundles/{Bundle}/Entity/` |
| Migrations | `/app/migrations/` |

## Additional Resources

Detailed references will be added in:
- `references/migrations.md`
- `references/entities.md`
- `references/repositories.md`
