---
name: Mautic Testing
description: This skill should be used when the user asks about "PHPUnit", "write test", "Codeception", "test fixtures", "MauticMysqlTestCase", "functional test", or needs guidance on testing Mautic code.
version: 0.1.0
---

# Mautic Testing

> **Status:** Planned - This skill is under development.

This skill will provide guidance for writing tests in Mautic.

## Planned Content

- PHPUnit test patterns
- MauticMysqlTestCase base class
- Codeception E2E tests
- Test fixtures
- Mocking and stubbing
- Database testing
- API testing

## Key Commands

```bash
# Run all tests
composer test

# Run specific test file
bin/phpunit app/bundles/EmailBundle/Tests/Functional/EmailTest.php

# Run specific test method
bin/phpunit --filter testMethodName

# Run E2E tests
composer run e2e-test
```

## Test Base Classes

| Class | Use Case |
|-------|----------|
| `PHPUnit\Framework\TestCase` | Unit tests |
| `Mautic\CoreBundle\Test\MauticMysqlTestCase` | Functional tests with DB |

## File Locations

| Category | Location |
|----------|----------|
| Unit Tests | `/app/bundles/{Bundle}/Tests/Unit/` |
| Functional Tests | `/app/bundles/{Bundle}/Tests/Functional/` |
| E2E Tests | `/tests/` |

## Additional Resources

Detailed references will be added in:
- `references/phpunit.md`
- `references/codeception.md`
- `references/fixtures.md`
