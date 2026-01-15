---
name: Mautic Tables
description: This skill should be used when the user asks to "add table", "create list view", "list page table", "detail table", "tableheader", "list_actions", "pagination", "sortable columns", "table row actions", "entity list", "column width", "table column", or mentions Twig table templates. Provides guide for implementing tables in Mautic admin UI.
version: 1.0.0
---

# Mautic Tables

Mautic uses consistent table patterns across the admin UI. Two main table types exist: **List Tables** (index pages) and **Detail Tables** (detail pages).

## List Tables (Index Pages)

List tables display collections of entities with sorting, pagination, and bulk actions.

### Basic Structure

```twig
{% if items|length > 0 %}
    <div class="table-responsive">
        <table class="table table-hover entity-list" id="entityTable">
            <thead>
                <tr>
                    {# Checkbox column for bulk actions #}
                    {{ include('@MauticCore/Helper/tableheader.html.twig', {
                        'checkall': 'true',
                        'target': '#entityTable',
                    }) }}

                    {# Sortable name column #}
                    {{ include('@MauticCore/Helper/tableheader.html.twig', {
                        'sessionVar': 'entity',
                        'orderBy': 'e.name',
                        'text': 'mautic.core.name',
                        'class': 'col-entity-name',
                        'default': true,
                    }) }}

                    {# Responsive columns (hidden on small screens) #}
                    {{ include('@MauticCore/Helper/tableheader.html.twig', {
                        'sessionVar': 'entity',
                        'orderBy': 'e.id',
                        'text': 'mautic.core.id',
                        'class': 'visible-md visible-lg col-entity-id',
                    }) }}
                </tr>
            </thead>
            <tbody>
                {% for item in items %}
                    <tr>
                        {# Row actions (checkbox + dropdown) #}
                        <td>
                            {{ include('@MauticCore/Helper/list_actions.html.twig', {
                                'item': item,
                                'templateButtons': {
                                    'edit': permissions['entity:entities:edit'],
                                    'clone': permissions['entity:entities:create'],
                                    'delete': permissions['entity:entities:delete'],
                                },
                                'routeBase': 'entity',
                            }) }}
                        </td>

                        {# Name cell with status and link #}
                        <td>
                            <div>
                                {{ include('@MauticCore/Helper/publishstatus_icon.html.twig', {
                                    'item': item,
                                    'model': 'entity',
                                }) }}
                                <a href="{{ path('mautic_entity_action', {'objectAction': 'view', 'objectId': item.id}) }}"
                                   data-toggle="ajax">
                                    {{ item.name }}
                                </a>
                            </div>
                            {{ include('@MauticCore/Helper/description--inline.html.twig', {
                                'description': item.description
                            }) }}
                        </td>

                        <td class="visible-md visible-lg">{{ item.id }}</td>
                    </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
    <div class="panel-footer">
        {{ include('@MauticCore/Helper/pagination.html.twig', {
            'totalItems': items|length,
            'page': page,
            'limit': limit,
            'menuLinkId': 'mautic_entity_index',
            'baseUrl': path('mautic_entity_index'),
            'sessionVar': 'entity',
        }) }}
    </div>
{% else %}
    {# Empty state handling #}
    {% if searchValue is not empty %}
        {{ include('@MauticCore/Helper/noresults.html.twig', {
            'tip': 'mautic.entity.noresults.tip'
        }) }}
    {% else %}
        {# Content block for empty state - see references/empty-states.md #}
    {% endif %}
{% endif %}
```

## Key Helper Components

### tableheader.html.twig

Creates sortable column headers or bulk action checkbox.

| Parameter | Type | Description |
|-----------|------|-------------|
| `checkall` | string | Set to `'true'` for bulk checkbox header |
| `target` | string | CSS selector for table (e.g., `'#entityTable'`) |
| `sessionVar` | string | Session variable name for sort state |
| `orderBy` | string | Column name to sort by (e.g., `'e.name'`) |
| `text` | string | Translation key for header text |
| `class` | string | CSS classes (use `visible-md visible-lg` for responsive) |
| `default` | bool | Set `true` if this is default sort column |

### list_actions.html.twig

Creates row checkbox with actions dropdown.

| Parameter | Type | Description |
|-----------|------|-------------|
| `item` | object | Entity object |
| `templateButtons` | object | `{edit: bool, clone: bool, delete: bool, export: bool}` |
| `routeBase` | string | Route base name (e.g., `'campaign'`) |
| `customButtons` | array | Additional custom action buttons |
| `editMode` | string | `'ajax'` or `'ajaxmodal'` |
| `editAttr` | object | Additional attributes for edit link |
| `query` | object | Additional query parameters |

### pagination.html.twig

Creates pagination controls with page size selector.

| Parameter | Type | Description |
|-----------|------|-------------|
| `totalItems` | int | Total count of items |
| `page` | int | Current page number |
| `limit` | int | Items per page |
| `menuLinkId` | string | Menu link ID for active state |
| `baseUrl` | string | Base URL for pagination links |
| `sessionVar` | string | Session variable name |

## Detail Tables

Detail pages use simpler tables for metadata display.

```twig
<div class="panel shd-none mb-0">
    <table class="table table-hover mb-0">
        <tbody>
            {# Include common entity details #}
            {{ include('@MauticCore/Helper/details.html.twig', {
                'entity': item
            }) }}

            {# Custom rows #}
            <tr>
                <td width="20%">
                    <span class="fw-b textTitle">{{ 'mautic.entity.field'|trans }}</span>
                </td>
                <td>{{ item.fieldValue }}</td>
            </tr>
        </tbody>
    </table>
</div>
```

### details.html.twig

Renders common entity metadata rows automatically:
- Category (if entity has `getCategory()`)
- Created by / Created date
- Modified by / Modified date
- Publish up / Publish down dates
- Entity ID

## Common Cell Patterns

### Date Cell with Tooltip

```twig
<td class="visible-md visible-lg" title="{{ item.dateAdded ? dateToFullConcat(item.dateAdded) : '' }}">
    {{ item.dateAdded ? dateToDate(item.dateAdded) : '' }}
</td>
```

### Category Cell

```twig
<td class="visible-md visible-lg">
    {{ include('@MauticCore/Modules/category--expanded.html.twig', {
        'category': item.category
    }) }}
</td>
```

### Status Icon + Name Link

```twig
<td>
    <div>
        {{ include('@MauticCore/Helper/publishstatus_icon.html.twig', {
            'item': item,
            'model': 'entity',
        }) }}
        <a href="{{ path('mautic_entity_action', {'objectAction': 'view', 'objectId': item.id}) }}"
           data-toggle="ajax">
            {{ item.name }}
        </a>
        {{ customContent('entity.name', _context) }}
    </div>
    {{ include('@MauticCore/Helper/description--inline.html.twig', {
        'description': item.description
    }) }}
</td>
```

### Permission-Based Edit Link

```twig
{% if permissions['entity:entities:edit'] %}
    <a href="{{ path('mautic_entity_action', {'objectAction': 'edit', 'objectId': item.id}) }}"
       data-toggle="ajax">
        {{ item.name }}
    </a>
{% else %}
    {{ item.name }}
{% endif %}
```

## Responsive Classes

| Class | Visibility |
|-------|------------|
| `visible-xs` | Mobile only |
| `visible-sm` | Tablet only |
| `visible-md` | Desktop |
| `visible-lg` | Large desktop |
| `hidden-xs` | Hidden on mobile |
| `visible-md visible-lg` | Desktop and larger |

## Column Widths

### List Tables

List tables use **auto-calculated widths** based on content. Column classes are semantic identifiers:

```twig
{# Class naming: col-{entity}-{field} #}
'class': 'col-campaign-name'
'class': 'visible-md visible-lg col-email-category'
'class': 'visible-md visible-lg col-entity-id'
```

**Special width classes:**

| Class | Width | Usage |
|-------|-------|-------|
| `col-actions` | 100px | Actions column (checkbox + dropdown) |

The actions column is automatically sized via CSS. Other columns expand based on content.

### Detail Tables

Detail tables use **inline width attribute** on label cells:

```twig
<tr>
    <td width="20%">
        <span class="fw-b textTitle">{{ 'mautic.entity.label'|trans }}</span>
    </td>
    <td>{{ item.value }}</td>
</tr>
```

**Standard pattern:**
- Label cell: `width="20%"` - fixed width for labels
- Value cell: No width (auto-expands to remaining space)

### Full-Width Tables

For tables inside panels/forms:

```twig
<table class="table" width="100%">
```

## Custom Row Actions

Add custom buttons to row actions:

```twig
{% set customButtons = [{
    'attr': {
        'href': path('mautic_entity_action', {'objectAction': 'send', 'objectId': item.id}),
        'data-toggle': 'ajax',
    },
    'iconClass': 'ri-send-plane-line',
    'btnText': 'mautic.entity.send'|trans,
}] %}

{{ include('@MauticCore/Helper/list_actions.html.twig', {
    'item': item,
    'templateButtons': templateButtons,
    'routeBase': 'entity',
    'customButtons': customButtons,
}) }}
```

## File Locations

| Type | Path |
|------|------|
| tableheader | `app/bundles/CoreBundle/Resources/views/Helper/tableheader.html.twig` |
| list_actions | `app/bundles/CoreBundle/Resources/views/Helper/list_actions.html.twig` |
| pagination | `app/bundles/CoreBundle/Resources/views/Helper/pagination.html.twig` |
| details | `app/bundles/CoreBundle/Resources/views/Helper/details.html.twig` |
| noresults | `app/bundles/CoreBundle/Resources/views/Helper/noresults.html.twig` |

## Additional Resources

### Reference Files

For detailed patterns and advanced use cases, consult:
- **`references/list-table-patterns.md`** - Complete list table structure and variations
- **`references/empty-states.md`** - Empty state content blocks

### Example Files

Working examples in `examples/`:
- **`list.html.twig`** - Complete list page example
- **`_list.html.twig`** - Partial list template example
