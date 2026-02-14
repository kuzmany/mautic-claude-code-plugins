---
name: mautic-db
description: This skill should be used when the user asks to "query database", "check db", "find in database", "db query", "sql query", "look up contact", "check email stats", "campaign logs", "database schema", "describe table", "list tables", "find bounce", "check dnc", "database issue", "db investigation", "table size", "database size", "form submissions", "audit log", "slow query", or mentions Mautic database operations, SQL queries, or data lookup on any Mautic instance (local or production).
version: 1.0.0
---

# Mautic Database Communication

Safe, read-first database access for Mautic instances. Dynamically discovers schema at query time using Doctrine commands - no hardcoded schema maintenance needed.

## Execution Methods

There are two ways to run database commands depending on the environment.

### Method 1: Doctrine Console Commands (no quoting issues)

Use `./exec.sh console` (or equivalent) for commands that take a single unquoted argument:

```bash
# List all mapped entities
./exec.sh console doctrine:mapping:info

# Describe a specific entity (table structure, columns, indexes, relationships)
./exec.sh console doctrine:mapping:describe 'Mautic\EmailBundle\Entity\Stat'
```

These work through any SSH/Docker wrapper because the argument has no spaces.

### Method 2: Direct Docker for SQL Queries

`doctrine:query:sql` requires the SQL as a quoted string. The `exec.sh` wrapper breaks quoting through the SSH > exec.sh > docker chain. Use direct docker compose instead:

```bash
ssh {SSH_HOST} 'cd {PROJECT_PATH}/build && docker compose -f docker-compose.{ENV}.yml run --rm -w /var/www/html php-dev php bin/console doctrine:query:sql "{SQL}"'
```

For local ddev environments:
```bash
ddev exec php bin/console doctrine:query:sql "{SQL}"
```

**Important:** Resolve `{SSH_HOST}`, `{PROJECT_PATH}`, and `{ENV}` from the project-specific production skill. Look for skills with "prod" in the name (e.g. `franchiseplus-prod`) which contain SSH host, project path, and Docker compose file details. This skill provides the database workflow; the production skill provides the connection.

## Workflow: 3-Step Query Process

Always follow this workflow when investigating data:

### Step 1: Find the Right Entity

```bash
# Search all 104+ mapped entities
./exec.sh console doctrine:mapping:info
```

Look for entity names matching the domain (Email, Lead, Campaign, Form, etc.).

### Step 2: Discover Schema

```bash
# Get full table structure: columns, types, indexes, foreign keys
./exec.sh console doctrine:mapping:describe 'Mautic\{Bundle}\Entity\{Entity}'
```

This returns:
- **Table name** (actual DB table)
- **Field mappings** (column names, types, nullable)
- **Association mappings** (foreign keys, join columns, related entities)
- **Indexes** (which columns are indexed - important for query performance)

Alternatively, use SQL for column discovery:
```sql
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = '{table}'
ORDER BY ORDINAL_POSITION
```

### Step 3: Run the Query

Build a SELECT query using the discovered schema and run it via Method 2.

## Safety Rules

### READ Operations (Default - No Confirmation Needed)

- SELECT queries
- `doctrine:mapping:info` and `doctrine:mapping:describe`
- `information_schema` queries
- SHOW commands

### WRITE Operations (ALWAYS Require User Confirmation)

**CRITICAL: On production environments, NEVER execute UPDATE, DELETE, INSERT, DROP, ALTER, TRUNCATE, or any data-modifying SQL without explicit user confirmation.**

Before any write operation:
1. Show the exact SQL to the user
2. Explain what rows will be affected (run a SELECT first to show the scope)
3. Wait for explicit "yes" / approval
4. Recommend running with a transaction or `--dry-run` when available

### Query Safety Guidelines

- Always add `LIMIT` to queries (default LIMIT 100)
- Never `SELECT *` on large tables (email_stats, page_hits, campaign_lead_event_log, audit_log)
- Use indexed columns in WHERE clauses (check indexes via `doctrine:mapping:describe`)
- For row counts on large tables, use `information_schema.tables` (approx) instead of `COUNT(*)`
- Prefer `information_schema` for table sizes and metadata

## Key Mautic Entities Reference

Quick reference for the most commonly queried entities. Use `doctrine:mapping:info` for the full list.

| Domain | Entity Class | Typical Table |
|--------|-------------|---------------|
| Contacts | `Mautic\LeadBundle\Entity\Lead` | `leads` |
| Companies | `Mautic\LeadBundle\Entity\Company` | `companies` |
| Segments | `Mautic\LeadBundle\Entity\LeadList` | `lead_lists` |
| Segment members | `Mautic\LeadBundle\Entity\ListLead` | `lead_lists_leads` |
| Contact fields | `Mautic\LeadBundle\Entity\LeadField` | `lead_fields` |
| DNC | `Mautic\LeadBundle\Entity\DoNotContact` | `lead_donotcontact` |
| Tags | `Mautic\LeadBundle\Entity\Tag` | `lead_tags` |
| UTM tags | `Mautic\LeadBundle\Entity\UtmTag` | `lead_utmtags` |
| Points log | `Mautic\LeadBundle\Entity\PointsChangeLog` | `lead_points_change_log` |
| Notes | `Mautic\LeadBundle\Entity\LeadNote` | `lead_notes` |
| Emails | `Mautic\EmailBundle\Entity\Email` | `emails` |
| Email stats | `Mautic\EmailBundle\Entity\Stat` | `email_stats` |
| Email devices | `Mautic\EmailBundle\Entity\StatDevice` | `email_stats_devices` |
| Campaigns | `Mautic\CampaignBundle\Entity\Campaign` | `campaigns` |
| Campaign events | `Mautic\CampaignBundle\Entity\Event` | `campaign_events` |
| Campaign members | `Mautic\CampaignBundle\Entity\Lead` | `campaign_leads` |
| Campaign event log | `Mautic\CampaignBundle\Entity\LeadEventLog` | `campaign_lead_event_log` |
| Campaign failed log | `Mautic\CampaignBundle\Entity\FailedLeadEventLog` | `campaign_lead_event_failed_log` |
| Pages | `Mautic\PageBundle\Entity\Page` | `pages` |
| Page hits | `Mautic\PageBundle\Entity\Hit` | `page_hits` |
| Forms | `Mautic\FormBundle\Entity\Form` | `forms` |
| Form submissions | `Mautic\FormBundle\Entity\Submission` | `form_submissions` |
| Categories | `Mautic\CategoryBundle\Entity\Category` | `categories` |
| Audit log | `Mautic\CoreBundle\Entity\AuditLog` | `audit_log` |
| IP addresses | `Mautic\CoreBundle\Entity\IpAddress` | `ip_addresses` |
| Webhooks | `Mautic\WebhookBundle\Entity\Webhook` | `webhooks` |
| Assets | `Mautic\AssetBundle\Entity\Asset` | `assets` |
| Stages | `Mautic\StageBundle\Entity\Stage` | `stages` |
| Notifications | `Mautic\CoreBundle\Entity\Notification` | `notifications` |

**Note:** Table names may have a prefix depending on installation. Discover the actual prefix from the first query result or from `local.php` config.

## Large Tables Warning

These tables grow large on active instances. Always use indexed columns and LIMIT:

| Table | Typically Large | Key Indexed Columns |
|-------|----------------|---------------------|
| `email_stats` | Millions of rows | email_id, lead_id, date_sent, tracking_hash |
| `page_hits` | Millions of rows | date_hit, lead_id, redirect_id |
| `campaign_lead_event_log` | Millions of rows | campaign_id, event_id, lead_id, date_triggered |
| `audit_log` | Hundreds of thousands | object, object_id, date_added |
| `ip_addresses` | Hundreds of thousands | ip_address |
| `lead_ips_xref` | Millions of rows | lead_id, ip_id |

## Additional Reference

- **`references/common-queries.md`** - Ready-to-use safe queries for common investigations
