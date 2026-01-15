# List Table Patterns Reference

Comprehensive reference for Mautic list table implementations.

## Complete List Page Structure

List pages typically follow this structure in `list.html.twig`:

```twig
{% set isIndex = tmpl == 'index' ? true : false %}
{% set tmpl = 'list' %}

{% extends isIndex ? '@MauticCore/Default/content.html.twig' : '@MauticCore/Default/raw_output.html.twig' %}

{% block mauticContent %}entity{% endblock %}
{% block headerTitle %}{{ 'mautic.entity.entities'|trans }}{% endblock %}

{% block content %}
{% if isIndex %}
    <div id="page-list-wrapper" class="{% if items|length > 0 or searchValue is not empty %}panel {% endif %}panel-default">

        {# Toolbar with search, filters, and actions #}
        {{ include('@MauticCore/Helper/list_toolbar.html.twig', {
            'searchValue': searchValue,
            'action': currentRoute,
            'page_actions': {
                'templateButtons': {
                    'new': permissions['entity:entities:create'],
                },
                'routeBase': 'entity',
            },
            'bulk_actions': {
                'routeBase': 'entity',
                'templateButtons': {
                    'delete': permissions['entity:entities:delete']
                }
            },
            'quickFilters': [
                {
                    'search': 'mautic.core.searchcommand.ispublished',
                    'label': 'mautic.core.form.active',
                    'tooltip': 'mautic.core.searchcommand.ispublished.description',
                    'icon': 'ri-check-line'
                },
                {
                    'search': 'mautic.core.searchcommand.isunpublished',
                    'label': 'mautic.core.form.inactive',
                    'tooltip': 'mautic.core.searchcommand.isunpublished.description',
                    'icon': 'ri-close-line'
                }
            ]
        }) }}

        <div class="page-list">
            {# Table content or block reference #}
            {{ block('listResults') }}
        </div>
    </div>
{% else %}
    {{ block('listResults') }}
{% endif %}
{% endblock %}

{% block listResults %}
    {# List table implementation #}
{% endblock %}
```

## list_toolbar.html.twig Parameters

The toolbar provides search, filtering, and action buttons.

```twig
{{ include('@MauticCore/Helper/list_toolbar.html.twig', {
    'searchValue': searchValue,              {# Current search string #}
    'action': currentRoute,                   {# Form action URL #}
    'actionRoute': actionRoute,               {# Route for actions #}
    'indexRoute': indexRoute,                 {# Index route name #}
    'translationBase': translationBase,       {# Translation key prefix #}
    'preCustomButtons': toolBarButtons,       {# Buttons before default buttons #}

    'templateButtons': {
        'delete': permissions[permissionBase~':delete'],  {# Bulk delete permission #}
    },

    'filters': filters|default([]),           {# Custom filter dropdowns #}

    'page_actions': {
        'templateButtons': {
            'new': permissions['entity:entities:create'],
        },
        'routeBase': 'entity',
        'langVar': 'entity.entities',
        'customButtons': pageButtons,         {# Additional action buttons #}
        'editMode': 'ajaxModal',              {# Modal mode for new/edit #}
        'editAttr': {
            'data-target': '#MauticSharedModal',
            'data-header': 'mautic.entity.header.new'|trans,
            'data-toggle': 'ajaxmodal',
        },
        'query': {                            {# Additional query params #}
            'bundle': bundle,
        },
    },

    'bulk_actions': {
        'routeBase': 'entity',
        'templateButtons': {
            'delete': permissions['entity:entities:delete']
        },
        'query': {
            'bundle': bundle
        }
    },

    'quickFilters': [
        {
            'search': 'mautic.core.searchcommand.ispublished',
            'label': 'mautic.core.form.active',
            'tooltip': 'mautic.core.searchcommand.ispublished.description',
            'icon': 'ri-check-line'
        }
    ]
}) }}
```

## Modal Edit Mode

For entities edited via modal (like Categories):

```twig
{{ include('@MauticCore/Helper/list_actions.html.twig', {
    'item': item,
    'templateButtons': {
        'edit': permissions[permissionBase ~ ':edit'],
        'delete': permissions[permissionBase ~ ':delete'],
    },
    'editMode': 'ajaxmodal',
    'editAttr': {
        'data-target': '#MauticSharedModal',
        'data-header': title,
        'data-toggle': 'ajaxmodal',
    },
    'routeBase': 'category',
    'query': {
        'bundle': bundle,
    },
}) }}
```

## Permission-Based Row Actions

Use `securityHasEntityAccess()` for owner-based permissions:

```twig
{{ include('@MauticCore/Helper/list_actions.html.twig', {
    'item': item,
    'templateButtons': {
        'edit': securityHasEntityAccess(
            permissions['campaign:campaigns:editown'],
            permissions['campaign:campaigns:editother'],
            item.createdBy
        ),
        'clone': permissions['campaign:campaigns:create'],
        'delete': securityHasEntityAccess(
            permissions['campaign:campaigns:deleteown'],
            permissions['campaign:campaigns:deleteother'],
            item.createdBy
        ),
    },
    'routeBase': 'campaign',
}) }}
```

## Sortable Columns with Default Direction

```twig
{{ include('@MauticCore/Helper/tableheader.html.twig', {
    'sessionVar': 'email',
    'orderBy': 'e.dateModified',
    'defaultDir': 'DESC',                     {# Default sort direction #}
    'text': 'mautic.lead.import.label.dateModified',
    'class': 'visible-lg col-email-dateModified',
    'default': true,                          {# This is the default sort column #}
}) }}
```

## Non-Sortable Header

For columns without sorting (e.g., stats):

```twig
<th class="visible-sm visible-md visible-lg col-email-stats">
    {{ 'mautic.core.stats'|trans }}
</th>
```

## Complex Custom Buttons

```twig
{% set sendButton = {
    'attr': {
        'data-toggle': 'ajax',
        'href': path('mautic_email_action', {'objectAction': 'send', 'objectId': item.id}),
    },
    'iconClass': 'ri-send-plane-line',
    'btnText': 'mautic.email.send'
} %}

{% if item.isBackgroundSending() %}
    {% set sendButton = sendButton|merge({
        'attr': {
            'href': 'javascript:void(0);',
            'disabled': true
        },
        'tooltip': 'mautic.email.send.disabled',
        'btnClass': 'disabled'
    }) %}
{% endif %}

{% set previewButton = {
    'attr': {
        'class': 'btn btn-ghost btn-sm btn-nospin',
        'href': url('mautic_email_preview', {'objectId': item.id}),
        'target': '_blank',
        'data-toggle': '',
    },
    'iconClass': 'ri-external-link-line',
    'btnText': 'mautic.core.open_link'|trans,
    'priority': 100
} %}

{% set customButtons = [sendButton, previewButton] %}
```

## Stats Badges in Table Cells

```twig
<td class="visible-sm visible-md visible-lg col-stats" data-stats="{{ item.id }}">
    <span class="mt-xs label label-blue" id="sent-count-{{ item.id }}">
        <i class="ri-mail-unread-line"></i>
        <a href="{{ path('mautic_contact_index', {'search': 'email_sent:' ~ item.id}) }}"
           data-toggle="tooltip"
           title="{{ 'mautic.email.stat.tooltip'|trans }}">
            {{ 'mautic.email.stat.sentcount'|trans({'%count%': item.sentCount}) }}
        </a>
    </span>
    <span class="mt-xs label label-teal" id="read-count-{{ item.id }}">
        <i class="ri-mail-open-line"></i>
        <a href="{{ path('mautic_contact_index', {'search': 'email_read:' ~ item.id}) }}">
            {{ 'mautic.email.stat.readcount'|trans({'%count%': item.readCount}) }}
        </a>
        <span id="read-percent-{{ item.id }}">({{ item.readPercentage }}%)</span>
    </span>
</td>
```

## Icon Badges in Name Cell

```twig
<td>
    <div>
        {{ include('@MauticCore/Helper/publishstatus_icon.html.twig', {
            'item': item,
            'model': 'email',
        }) }}
        <a href="{{ path('mautic_email_action', {'objectAction': 'view', 'objectId': item.id}) }}"
           data-toggle="ajax">
            {{ item.name }}

            {# Conditional icon badges #}
            {% if item.hasVariants() %}
                <span data-toggle="tooltip" title="{{ 'mautic.email.icon_tooltip.ab_test'|trans }}">
                    <i class="ri-fw ri-organization-chart fs-14"></i>
                </span>
            {% endif %}
            {% if item.hasTranslations() %}
                <span data-toggle="tooltip" title="{{ 'mautic.core.icon_tooltip.translation'|trans }}">
                    <i class="ri-fw ri-translate fs-14"></i>
                </span>
            {% endif %}
        </a>
        {{ include('@MauticProject/Modules/projects.html.twig') }}
    </div>

    {% if item.description is not empty %}
        <div class="text-secondary mt-4">
            <small>{{ item.description|purify }}</small>
        </div>
    {% endif %}
</td>
```

## Color Label Cell (Categories)

```twig
<td>
    {% set color = item.getColor() %}
    <span class="label label-gray label-category"
          style="background: {{ '#' not in color ? '#' : '' }}{{ color }};">
        &nbsp;
    </span>
</td>
```

## Dynamic Column Headers (Lead List)

For customizable columns:

```twig
<thead>
    <tr>
        {{ include('@MauticCore/Helper/tableheader.html.twig', {
            'checkall': 'true',
            'target': '#leadTable',
        }) }}

        {% for column, label in columns %}
            {{ include([
                ('@MauticLead/Lead/_list_header_' ~ column ~ '.html.twig'),
                '@MauticLead/Lead/_list_header_default.html.twig'
            ], {
                'label': label,
                'column': column,
                'class': (column in columns|keys) ? 'hidden-xs' : '',
            }) }}
        {% endfor %}
    </tr>
</thead>
```

## Table ID Naming Convention

Follow this pattern for table IDs:

| Entity | Table ID |
|--------|----------|
| Campaign | `#campaignTable` |
| Email | `#emailTable` |
| Lead | `#leadTable` |
| Category | `#categoryTable` |
| Stage | `#stageTable` |

The ID should match the entity name + "Table" suffix in camelCase.

## CSS Class Conventions

| Class | Usage |
|-------|-------|
| `table` | Base Bootstrap table class |
| `table-hover` | Row highlight on hover |
| `entity-list` | Entity type class (e.g., `campaign-list`) |
| `col-entity-field` | Column width class (e.g., `col-campaign-name`) |
| `visible-md visible-lg` | Show only on desktop |
| `hidden-xs` | Hide on mobile |
