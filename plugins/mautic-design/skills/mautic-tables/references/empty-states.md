# Empty States Reference

Mautic handles two empty state scenarios: search results empty and no data yet.

## Empty State Logic

```twig
{% if items|length > 0 %}
    {# Table content #}
{% else %}
    {% if searchValue is not empty %}
        {# No search results - show noresults template #}
        {{ include('@MauticCore/Helper/noresults.html.twig', {
            'tip': 'mautic.entity.noresults.tip'
        }) }}
    {% else %}
        {# No data yet - show content block #}
        {# Content block implementation #}
    {% endif %}
{% endif %}
```

## No Search Results (noresults.html.twig)

For when a search returns no matches:

```twig
{{ include('@MauticCore/Helper/noresults.html.twig', {
    'tip': 'mautic.entity.noresults.tip'
}) }}
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `header` | string | Override header text (default: `mautic.core.noresults.header`) |
| `message` | string | Override message text (default: `mautic.core.noresults`) |
| `tip` | string | Translation key for tip text (shows Mautibot) |

## Content Block (No Data Yet)

For when the entity list is empty (first time use):

```twig
<div class="mt-80 col-md-offset-2 col-lg-offset-3 col-md-8 col-lg-5 height-auto">
    {% set childContainer %}
        <div class="mt-32 mb-md">
            {% include '@MauticCore/Components/pictogram.html.twig' with {
                'pictogram': 'mail--verse',
                'size': '80'
            } %}
        </div>
    {% endset %}

    {{ include('@MauticCore/Components/content-block.html.twig', {
        heading: 'mautic.entity.contentblock.heading',
        subheading: 'mautic.entity.contentblock.subheading',
        copy: 'mautic.entity.contentblock.copy',
        childContainer: childContainer,
    }) }}
</div>
```

## Content Block with CTA Button

```twig
<div class="mt-80 col-md-offset-2 col-lg-offset-3 col-md-8 col-lg-5 height-auto">
    {% set childContainer %}
        <div class="mt-32 mb-md">
            {% include '@MauticCore/Components/pictogram.html.twig' with {
                'pictogram': 'user--analytics',
                'size': '80'
            } %}
        </div>
    {% endset %}

    {{ include('@MauticCore/Components/content-block.html.twig', {
        heading: 'mautic.lead.list.block.heading',
        subheading: 'mautic.lead.list.block.subheading',
        copy: 'mautic.lead.list.block.copy',
        childContainer: childContainer,
        cta: permissions['lead:leads:create'] ? {
            'label': 'mautic.lead.action.add',
            'link': path('mautic_import_action', {'object': 'contacts', 'objectAction': 'new'}),
            'attributes': {'data-toggle': 'ajax'}
        } : null
    }) }}
</div>
```

## Common Pictograms

| Entity | Pictogram |
|--------|-----------|
| Campaign | `ibm--automation-platform` |
| Email | `mail--verse` |
| Contact | `user--analytics` |
| Category | `folder` |
| Stage | `progress` |
| Asset | `document` |
| Form | `task` |

## Content Block with Feature Items

For more complex empty states with feature descriptions:

```twig
<div class="mt-80 col-md-offset-2 col-lg-offset-3 col-md-8 col-lg-5 height-auto">
    {% set childContainer %}
        <div class="mb-md">
            {% include '@MauticCore/Components/pictogram.html.twig' with {
                'pictogram': 'user--analytics',
                'size': '80'
            } %}
        </div>

        {{ include('@MauticCore/Components/content-item-row.html.twig', {
            type: 'default',
            eyebrow: 'mautic.lead.list.eyebrow',
            heading: 'mautic.lead.list.heading',
            copy: 'mautic.lead.list.copy',
        }) }}

        {% set formFeaturesContainer %}
            <div class="row">
                <div class="col-sm-6 col-xs-12">
                    {{ include('@MauticCore/Components/content-item.html.twig', {
                        type: 'pictogram',
                        heading: 'mautic.lead.list.anonymous.heading',
                        pictogram: 'anonymous--users',
                        copy: 'mautic.lead.list.anonymous.copy',
                    }) }}
                </div>
                <div class="col-sm-6 col-xs-12">
                    {{ include('@MauticCore/Components/content-item.html.twig', {
                        type: 'pictogram',
                        heading: 'mautic.lead.list.known.heading',
                        pictogram: 'id--badge',
                        copy: 'mautic.lead.list.known.copy',
                    }) }}
                </div>
            </div>
        {% endset %}

        {{ include('@MauticCore/Components/content-group.html.twig', {
            heading: 'mautic.lead.list.types.heading',
            childContainer: formFeaturesContainer,
        }) }}
    {% endset %}

    {{ include('@MauticCore/Components/content-block.html.twig', {
        heading: 'mautic.lead.list.block.heading',
        subheading: 'mautic.lead.list.block.subheading',
        copy: 'mautic.lead.list.block.copy',
        childContainer: childContainer,
    }) }}
</div>
```

## Pro Tips (Protip Module)

Add at the bottom of list pages:

```twig
{% if isIndex %}
    {{ include('@MauticCore/Modules/protip.html.twig', {
        tip: random([
            'mautic.protip.campaigns.reengagement',
            'mautic.protip.campaigns.survey',
            'mautic.protip.campaigns.crosssell',
            'mautic.protip.campaigns.onboarding'
        ])
    }) }}
{% endif %}
```

## Translation Keys Pattern

For content blocks, create these translation keys:

```
mautic.entity.contentblock.heading       - Main heading
mautic.entity.contentblock.subheading    - Subtitle
mautic.entity.contentblock.copy          - Description text
mautic.entity.noresults.tip              - Tip for search no results
```
