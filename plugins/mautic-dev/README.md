# mautic-dev

Development toolkit for Mautic - bundles, database, API, testing.

## Skills

### mautic-js
JavaScript development guide for Mautic bundles and plugins. Covers:
- Bundle lifecycle (OnLoad/OnUnload functions)
- mQuery (jQuery noConflict) patterns
- AJAX patterns (ajaxActionRequest, moderated intervals)
- UI components (modals, chosen selects, sortables, tooltips)
- Event binding with namespaces
- Loading indicators and progress tracking

**Trigger phrases:** "write Mautic JavaScript", "mQuery", "bundle OnLoad", "Mautic.ajaxActionRequest", "chosen select", "Mautic modal"

### mautic-dashboard-widgets
Dashboard widget development guide for Mautic bundles. Covers:
- DashboardSubscriber architecture and implementation
- Widget type registration with permissions
- Chart, table, and map widget templates
- Widget form types for configuration
- Caching and parameter handling

**Trigger phrases:** "create dashboard widget", "DashboardSubscriber", "WidgetDetailEvent", "widget template data", "chart widget", "table widget"

### mautic-api
Mautic REST API interaction with curl-based workflows. Covers:
- Multi-instance profile management (OAuth2 and Basic Auth)
- Email API: create, update, send, list, delete
- Authentication workflow with token management
- Batch operations and personalization tokens

**Trigger phrases:** "mautic api", "create mautic email", "send email via api", "add mautic instance", "manage api profiles"

### mautic-db
Database communication for Mautic instances (local or production). Dynamic schema discovery via Doctrine commands - no hardcoded schema. Covers:
- 3-step workflow: find entity > discover schema > run query
- Safe READ-only by default, WRITE requires user confirmation
- Direct docker compose for SQL (bypasses exec.sh quoting issues)
- Common queries for contacts, emails, campaigns, segments, forms
- Database health and audit log investigation

**Trigger phrases:** "query database", "check db", "find in database", "sql query", "look up contact", "check email stats", "campaign logs", "describe table", "database issue"

## Status

This plugin is under active development.
