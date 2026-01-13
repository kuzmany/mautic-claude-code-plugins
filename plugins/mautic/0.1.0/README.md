# Mautic Plugin for Claude Code

Comprehensive Claude Code skills for developing with Mautic - the open-source marketing automation platform built on Symfony.

## Installation

```bash
claude plugin add --path plugins/mautic https://github.com/kuzmany/mautic-claude-code-plugins
```

Or clone manually:

```bash
git clone https://github.com/kuzmany/mautic-claude-code-plugins.git
claude plugin add ./mautic-claude-code-plugins/plugins/mautic
```

## Skills

This plugin provides specialized knowledge across all aspects of Mautic development:

### mautic-design
**Status:** Planned

UI components, design tokens, and styling patterns.

**Triggers:** "create Mautic button", "add Mautic card", "Mautic modal", "CSS variables", "Twig component"

**Covers:**
- Design tokens (colors, spacing, typography)
- Twig components (buttons, cards, modals, tiles)
- RemixIcon usage
- Utility classes
- Theming system

### mautic-javascript
**Status:** Planned

JavaScript patterns and client-side development.

**Triggers:** "mQuery", "Mautic AJAX", "OnLoad", "flash message", "loading indicator"

**Covers:**
- Global Mautic object
- OnLoad/OnUnload lifecycle
- AJAX request patterns
- Flash messages
- Loading indicators
- Keyboard shortcuts

### mautic-database
**Status:** Planned

Database layer and migrations.

**Triggers:** "create migration", "add entity", "Doctrine", "database schema"

**Covers:**
- Doctrine ORM entities
- Migration creation
- Repository patterns
- Database schema changes

### mautic-api
**Status:** Planned

REST API development.

**Triggers:** "REST API", "API endpoint", "webhook", "API authentication"

**Covers:**
- API controller patterns
- Route definitions
- Authentication
- Webhooks

### mautic-bundles
**Status:** Planned

Bundle architecture and services.

**Triggers:** "create bundle", "services", "dependency injection", "config.php"

**Covers:**
- Bundle structure
- Service definitions
- Event subscribers
- Configuration

### mautic-forms
**Status:** Planned

Symfony form types and validation.

**Triggers:** "form type", "Symfony form", "validation", "custom field"

**Covers:**
- Form type classes
- Validation constraints
- Form themes
- Custom field types

### mautic-testing
**Status:** Planned

Testing patterns and best practices.

**Triggers:** "PHPUnit", "test", "Codeception", "fixtures"

**Covers:**
- PHPUnit test patterns
- MauticMysqlTestCase
- Codeception E2E tests
- Test fixtures

## Prerequisites

- Claude Code CLI installed
- Mautic 5.x or 7.x codebase
- PHP 8.1+ (Mautic 5) or PHP 8.2+ (Mautic 7)

## Usage Examples

After installation, Claude will automatically use the appropriate skill based on your request:

```
"Add a primary button to the form"
→ Uses mautic-design skill

"Create a migration to add a new field to leads"
→ Uses mautic-database skill

"How do I make an AJAX request in Mautic?"
→ Uses mautic-javascript skill
```

## Version History

- **0.1.0** - Initial release with skill structure

## Contributing

See the main repository [README](../../README.md) for contribution guidelines.

## License

MIT License
