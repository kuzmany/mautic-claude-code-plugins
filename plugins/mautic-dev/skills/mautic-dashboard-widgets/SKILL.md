---
name: mautic-dashboard-widgets
description: This skill should be used when the user asks to "create dashboard widget", "add widget to bundle", "DashboardSubscriber", "widget template data", "chart widget", "table widget", "widget caching", "WidgetDetailEvent", "onWidgetDetailGenerate", "widget permissions", "widget form type". Provides guide for implementing Mautic dashboard widgets through Event Subscribers.
version: 1.0.0
---

# Mautic Dashboard Widgets

## Overview

Mautic dashboard widgets are created through **Event Subscribers** that extend the base `DashboardSubscriber`. Each bundle can contribute widgets to the dashboard by defining widget types, permissions, and data generators.

## Architecture

```
Bundle/
├── EventListener/
│   └── DashboardSubscriber.php    # Widget registration & data
├── Form/Type/
│   └── Dashboard*WidgetType.php   # Widget config forms (optional)
└── Translations/en_US/
    └── messages.ini               # Widget name translations
```

## Quick Reference

| Component | Location | Purpose |
|-----------|----------|---------|
| Base class | `Mautic\DashboardBundle\EventListener\DashboardSubscriber` | Extend this |
| Events | `DashboardEvents::DASHBOARD_ON_MODULE_*` | Auto-subscribed |
| Widget Entity | `Mautic\DashboardBundle\Entity\Widget` | Widget config/params |
| Chart template | `@MauticCore/Helper/chart.html.twig` | Line, pie, bar charts |
| Table template | `@MauticCore/Helper/table.html.twig` | Tabular data |
| Map template | `@MauticCore/Helper/map.html.twig` | Geographic data |

## Implementation Pattern

### 1. Create DashboardSubscriber

```php
<?php

namespace Mautic\{Bundle}Bundle\EventListener;

use Mautic\DashboardBundle\Event\WidgetDetailEvent;
use Mautic\DashboardBundle\EventListener\DashboardSubscriber as MainDashboardSubscriber;
use Mautic\{Bundle}Bundle\Form\Type\Dashboard{Widget}WidgetType;
use Mautic\{Bundle}Bundle\Model\{Model}Model;

class DashboardSubscriber extends MainDashboardSubscriber
{
    // Category name in widget selector
    protected $bundle = 'bundlename';

    // Widget types: key = widget identifier, value = config (optional formAlias)
    protected $types = [
        'widget.type.name' => [
            'formAlias' => Dashboard{Widget}WidgetType::class,  // Optional form
        ],
        'simple.widget' => [],  // No config form needed
    ];

    // Required permissions (user needs at least one)
    protected $permissions = [
        'bundlename:entity:viewown',
        'bundlename:entity:viewother',
    ];

    public function __construct(
        protected {Model}Model $model,
    ) {
    }

    public function onWidgetDetailGenerate(WidgetDetailEvent $event): void
    {
        $this->checkPermissions($event);
        $canViewOthers = $event->hasPermission('bundlename:entity:viewother');

        if ('widget.type.name' == $event->getType()) {
            $widget = $event->getWidget();
            $params = $widget->getParams();

            if (!$event->isCached()) {
                // Generate widget data here
                $event->setTemplateData([
                    // Template-specific data
                ]);
            }

            $event->setTemplate('@MauticCore/Helper/chart.html.twig');
            $event->stopPropagation();
        }
    }
}
```

### 2. Template Data Patterns

**Chart Widget (line/pie/bar):**
```php
$event->setTemplateData([
    'chartType'   => 'line',  // or 'pie', 'bar'
    'chartHeight' => $widget->getHeight() - 80,
    'chartData'   => $this->model->getChartData(
        $params['timeUnit'],
        $params['dateFrom'],
        $params['dateTo'],
        $params['dateFormat'],
        $canViewOthers
    ),
]);
$event->setTemplate('@MauticCore/Helper/chart.html.twig');
```

**Table Widget:**
```php
$items = [];
foreach ($data as $row) {
    $url = $this->router->generate('mautic_entity_action', [
        'objectAction' => 'view',
        'objectId' => $row['id']
    ]);
    $items[] = [
        [
            'value' => $row['name'],
            'type'  => 'link',
            'link'  => $url,
        ],
        [
            'value' => $row['count'],
        ],
    ];
}

$event->setTemplateData([
    'headItems' => [
        'mautic.dashboard.label.title',
        'mautic.dashboard.label.count',
    ],
    'bodyItems' => $items,
    'raw'       => $data,  // Optional: original data
]);
$event->setTemplate('@MauticCore/Helper/table.html.twig');
```

### 3. Widget Form Type (Optional)

```php
<?php

namespace Mautic\{Bundle}Bundle\Form\Type;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\FormBuilderInterface;

class Dashboard{Widget}WidgetType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder->add(
            'filterField',
            ChoiceType::class,
            [
                'label'       => 'mautic.widget.filter.label',
                'choices'     => [
                    'mautic.option.one' => 'value1',
                    'mautic.option.two' => 'value2',
                ],
                'label_attr'  => ['class' => 'control-label'],
                'attr'        => ['class' => 'form-control'],
                'required'    => false,
            ]
        );
    }

    public function getBlockPrefix(): string
    {
        return 'bundle_dashboard_widget_type';
    }
}
```

### 4. Translation Keys

Add to `Translations/en_US/messages.ini`:
```ini
mautic.widget.widget.type.name="Widget Display Name"
mautic.widget.filter.label="Filter Label"
```

## Widget Parameters

The `WidgetDetailEvent` provides access to common parameters:

```php
$params = $widget->getParams();

// Always available (set by system):
$params['timeUnit']    // Time grouping: 'H', 'D', 'W', 'M', 'Y'
$params['dateFrom']    // DateTime object
$params['dateTo']      // DateTime object
$params['dateFormat']  // Format string
$params['filter']      // Array of filters

// From widget config form:
$params['limit']       // Row limit
$params['customField'] // Custom form fields

// Widget dimensions:
$widget->getHeight()   // Height in pixels
$widget->getWidth()    // Width in pixels
```

## Limit Calculation Pattern

```php
// Calculate row limit from widget height
if (empty($params['limit'])) {
    $limit = round((($widget->getHeight() - 80) / 35) - 1);
} else {
    $limit = $params['limit'];
}
```

## Caching

Data is automatically cached when `$event->setTemplateData()` is called.

```php
// Check cache before expensive operations
if (!$event->isCached()) {
    // Generate fresh data
    $event->setTemplateData([...]);
}

// Cache timeout is configurable per widget
$widget->getCacheTimeout();  // Returns minutes
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `@BundleNameBundle` namespace | Use `@BundleName` (see AGENTS.md Template Namespace Convention) |
| Forgetting `$event->stopPropagation()` | Always call after setting template |
| Missing translation key | Add `mautic.widget.{type}` to messages.ini |
| Not checking permissions | Call `$this->checkPermissions($event)` first |
| Skipping cache check | Wrap data generation in `if (!$event->isCached())` |
| Wrong chart data format | Must have `datasets[0].data` array structure |

## Chart Helper Classes

For chart data generation (LineChart, PieChart, BarChart), see the **mautic-graphs** skill which covers Chart.js integration, PHP helpers, and chart data structures in detail.

## Built-in Templates Reference

**Chart types:** `line`, `pie`, `bar`

**Table cell types:**
```php
// Link cell
['value' => 'Text', 'type' => 'link', 'link' => $url]
['value' => 'Text', 'type' => 'link', 'link' => $url, 'external' => true]

// Plain cell
['value' => 'Text']
```

## Service Registration

Services are auto-wired in Symfony 7. No manual registration needed if following PSR-4 autoloading.

For custom constructor dependencies, ensure services are public or use dependency injection.
