# Common Mautic Database Queries

Safe, read-only queries for frequent investigations. All queries include LIMIT clauses.

## Contact Lookup

```sql
-- Find contact by email
SELECT id, firstname, lastname, email, points, date_added, last_active, stage_id
FROM leads WHERE email = '{email}' LIMIT 5

-- Find contact by ID
SELECT id, firstname, lastname, email, points, date_added, last_active, stage_id
FROM leads WHERE id = {id}

-- Search contacts by name
SELECT id, firstname, lastname, email, date_added
FROM leads WHERE firstname LIKE '{name}%' OR lastname LIKE '{name}%'
ORDER BY date_added DESC LIMIT 20
```

## Contact Details

```sql
-- Contact's segment membership
SELECT ll.name, ll.alias, lll.manually_added, lll.date_added
FROM lead_lists_leads lll
JOIN lead_lists ll ON ll.id = lll.leadlist_id
WHERE lll.lead_id = {contact_id} AND lll.manually_removed = 0

-- Contact's DNC (Do Not Contact) records
SELECT channel, reason, date_added, comments
FROM lead_donotcontact
WHERE lead_id = {contact_id}

-- Contact's campaign membership
SELECT c.name, cl.date_added, cl.manually_removed, cl.manually_added
FROM campaign_leads cl
JOIN campaigns c ON c.id = cl.campaign_id
WHERE cl.lead_id = {contact_id}

-- Contact's tags
SELECT t.tag
FROM lead_tags_xref ltx
JOIN lead_tags t ON t.id = ltx.tag_id
WHERE ltx.lead_id = {contact_id}

-- Contact's UTM tags
SELECT utm_campaign, utm_source, utm_medium, utm_content, utm_term, date_added
FROM lead_utmtags
WHERE lead_id = {contact_id} ORDER BY date_added DESC LIMIT 10

-- Contact's companies
SELECT co.companyname, co.companycity, co.companycountry, cl.is_primary
FROM companies_leads cl
JOIN companies co ON co.id = cl.company_id
WHERE cl.lead_id = {contact_id}
```

## Email Stats

```sql
-- Email send stats for a specific email
SELECT
  COUNT(*) as total_sent,
  SUM(is_read) as total_read,
  SUM(is_failed) as total_failed,
  ROUND(SUM(is_read) * 100.0 / COUNT(*), 1) as open_rate_pct
FROM email_stats WHERE email_id = {email_id}

-- Recent sends for a contact
SELECT es.email_id, e.name, es.date_sent, es.is_read, es.date_read, es.is_failed
FROM email_stats es
LEFT JOIN emails e ON e.id = es.email_id
WHERE es.lead_id = {contact_id}
ORDER BY es.date_sent DESC LIMIT 20

-- Failed emails in last 7 days
SELECT es.email_address, e.name as email_name, es.date_sent
FROM email_stats es
LEFT JOIN emails e ON e.id = es.email_id
WHERE es.is_failed = 1 AND es.date_sent >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY es.date_sent DESC LIMIT 50

-- Bounce/DNC summary by channel
SELECT channel, reason,
  COUNT(*) as total,
  MIN(date_added) as oldest,
  MAX(date_added) as newest
FROM lead_donotcontact
GROUP BY channel, reason
```

## Campaign Investigation

```sql
-- Campaign event failures (recent)
SELECT cef.event_id, ce.name as event_name, ce.type as event_type,
  cef.date_added, cef.reason,
  c.name as campaign_name
FROM campaign_lead_event_failed_log cef
JOIN campaign_events ce ON ce.id = cef.event_id
JOIN campaigns c ON c.id = ce.campaign_id
ORDER BY cef.date_added DESC LIMIT 30

-- Campaign event log for a contact
SELECT ce.name as event_name, ce.type, cel.date_triggered,
  cel.is_scheduled, cel.trigger_date, cel.system_triggered,
  c.name as campaign_name
FROM campaign_lead_event_log cel
JOIN campaign_events ce ON ce.id = cel.event_id
JOIN campaigns c ON c.id = ce.campaign_id
WHERE cel.lead_id = {contact_id}
ORDER BY cel.date_triggered DESC LIMIT 30

-- Campaign members count (correlated subquery - can be slow on large instances, use for small campaign lists)
SELECT c.id, c.name, c.is_published,
  (SELECT COUNT(*) FROM campaign_leads cl WHERE cl.campaign_id = c.id AND cl.manually_removed = 0) as member_count
FROM campaigns c
WHERE c.is_published = 1
ORDER BY c.name
```

## Segment Investigation

```sql
-- Segment sizes (correlated subquery - can be slow on large instances with many segments)
SELECT ll.id, ll.name, ll.alias, ll.is_published, ll.is_global,
  (SELECT COUNT(*) FROM lead_lists_leads lll WHERE lll.leadlist_id = ll.id AND lll.manually_removed = 0) as member_count
FROM lead_lists ll
ORDER BY ll.name

-- Recent segment additions for a contact
SELECT ll.name, lll.date_added, lll.manually_added
FROM lead_lists_leads lll
JOIN lead_lists ll ON ll.id = lll.leadlist_id
WHERE lll.lead_id = {contact_id} AND lll.manually_removed = 0
ORDER BY lll.date_added DESC LIMIT 20
```

## Form Submissions

```sql
-- Recent form submissions
SELECT fs.id, f.name as form_name, fs.date_submitted, fs.lead_id,
  fs.referer, l.email
FROM form_submissions fs
JOIN forms f ON f.id = fs.form_id
LEFT JOIN leads l ON l.id = fs.lead_id
ORDER BY fs.date_submitted DESC LIMIT 20

-- Submissions for a specific form
SELECT fs.date_submitted, fs.lead_id, l.email, fs.referer
FROM form_submissions fs
LEFT JOIN leads l ON l.id = fs.lead_id
WHERE fs.form_id = {form_id}
ORDER BY fs.date_submitted DESC LIMIT 50
```

## Page Hits

```sql
-- Recent page hits for a contact
SELECT p.title, ph.date_hit, ph.url, ph.url_title, ph.source, ph.source_id
FROM page_hits ph
LEFT JOIN pages p ON p.id = ph.page_id
WHERE ph.lead_id = {contact_id}
ORDER BY ph.date_hit DESC LIMIT 20
```

## Database Health

```sql
-- Total database size
SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS size_mb,
  COUNT(*) as table_count
FROM information_schema.tables WHERE table_schema = DATABASE()

-- Top 20 tables by size
SELECT table_name,
  ROUND((data_length + index_length) / 1024 / 1024, 1) AS size_mb,
  table_rows as approx_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY (data_length + index_length) DESC LIMIT 20

-- Long-running queries
SELECT ID, USER, HOST, DB, COMMAND, TIME, STATE, LEFT(INFO, 100) as query_preview
FROM information_schema.PROCESSLIST
WHERE COMMAND != 'Sleep' AND TIME > 5
ORDER BY TIME DESC LIMIT 10

-- Maintenance cleanup dry-run estimate (run via console, not SQL)
-- php bin/console mautic:maintenance:cleanup -n -d 180 --dry-run
```

## Audit Log

```sql
-- Recent audit log for an entity
SELECT action, details, date_added, user_name, ip_address
FROM audit_log
WHERE object = '{object_type}' AND object_id = {object_id}
ORDER BY date_added DESC LIMIT 20
-- object_type examples: lead, email, campaign, page, form

-- Recent actions by a user
SELECT object, object_id, action, date_added, details
FROM audit_log
WHERE user_name = '{username}'
ORDER BY date_added DESC LIMIT 30
```

## Plugin & Integration Status

```sql
-- All plugins
SELECT p.name, p.is_missing, p.version, p.author
FROM plugins p ORDER BY p.name

-- Integration settings
SELECT pi.name, pi.is_published, pi.supported_features, p.name as plugin_name
FROM plugin_integration_settings pi
JOIN plugins p ON p.id = pi.plugin_id
ORDER BY pi.name
```

## Webhook Investigation

```sql
-- Webhooks and recent activity
SELECT w.name, w.webhook_url, w.is_published, w.events_orderby_dir,
  (SELECT COUNT(*) FROM webhook_logs wl WHERE wl.webhook_id = w.id) as log_count
FROM webhooks w ORDER BY w.name
```
