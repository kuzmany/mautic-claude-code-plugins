# Mautic Claude Code Plugins

A collection of Claude Code plugins for developing with Mautic - the open-source marketing automation platform.

## Available Plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| [mautic](./plugins/mautic) | 0.1.0 | Comprehensive skills for Mautic development |

## Installation

### Quick Install

```bash
claude plugin add --path plugins/mautic https://github.com/kuzmany/mautic-claude-code-plugins
```

### Manual Install

```bash
git clone https://github.com/kuzmany/mautic-claude-code-plugins.git
claude plugin add ./mautic-claude-code-plugins/plugins/mautic
```

## Skills Overview

The **mautic** plugin provides specialized knowledge for:

| Skill | Status | Description |
|-------|--------|-------------|
| `mautic-design` | Planned | UI components, CSS variables, Twig templates, theming |
| `mautic-javascript` | Planned | mQuery, AJAX patterns, OnLoad lifecycle, events |
| `mautic-database` | Planned | Doctrine entities, migrations, repositories |
| `mautic-api` | Planned | REST API endpoints, webhooks, authentication |
| `mautic-bundles` | Planned | Bundle architecture, services, dependency injection |
| `mautic-forms` | Planned | Symfony form types, validation, custom fields |
| `mautic-testing` | Planned | PHPUnit, Codeception, fixtures, test patterns |

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- Mautic 5.x or 7.x codebase

## Contributing

Contributions welcome! Please read the contribution guidelines before submitting PRs.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Related

- [Mautic](https://github.com/mautic/mautic) - Open-source marketing automation
- [Claude Code](https://claude.ai/code) - AI-powered coding assistant
