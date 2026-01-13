---
name: Mautic Charts & Graphs
description: This skill should be used when the user asks to "add chart", "create graph", "line chart", "bar chart", "pie chart", "dashboard widget chart", "Chart.js Mautic", "renderCharts", "LineChart", "stats graph". Provides guide for implementing charts in Mautic using Chart.js.
version: 1.0.0
---

# Mautic Charts & Graphs

Mautic uses **Chart.js v2.9.4** for all charts. Charts are rendered via Twig templates and initialized by JavaScript.

## Twig Usage (Most Common Pattern)

Include the chart template with data:

```twig
{{ include('@MauticCore/Helper/chart.html.twig', {
    'chartData': stats,
    'chartType': 'line',
    'chartHeight': 300
}) }}
```

### Chart Types

| Type | chartType value | Use case |
|------|-----------------|----------|
| Line | `'line'` | Time-series, trends |
| Bar | `'bar'` | Categorical comparison |
| Pie | `'pie'` | Part-to-whole |
| Horizontal Bar | `'horizontal-bar'` | Device stats, rankings |

### Optional Parameters

```twig
{{ include('@MauticCore/Helper/chart.html.twig', {
    'chartData': chartData,
    'chartType': 'pie',
    'chartHeight': 210,
    'disableLegend': true
}) }}
```

## PHP: Building Chart Data

### LineChart (Time-Series)

```php
use Mautic\CoreBundle\Helper\Chart\LineChart;

// Create chart with date range
$chart = new LineChart($unit, $dateFrom, $dateTo);

// Add datasets
$chart->setDataset('Sent', $sentData);
$chart->setDataset('Opened', $openedData);

// Get render data for Twig
$chartData = $chart->render();
// Returns: ['labels' => [...], 'datasets' => [...]]
```

### BarChart

```php
use Mautic\CoreBundle\Helper\Chart\BarChart;

$chart = new BarChart(['Label 1', 'Label 2', 'Label 3']);
$chart->setDataset('Series A', [10, 20, 30]);
$chart->setDataset('Series B', [15, 25, 35]);

$chartData = $chart->render();
```

### PieChart

```php
use Mautic\CoreBundle\Helper\Chart\PieChart;

$chart = new PieChart();
$chart->setDataset('Desktop', 60);
$chart->setDataset('Mobile', 30);
$chart->setDataset('Tablet', 10);

$chartData = $chart->render();
```

## JavaScript: Rendering Charts

Charts auto-render on page load. For dynamic content:

```javascript
// Render all charts in scope
Mautic.renderCharts();
Mautic.renderCharts('#myContainer');

// After AJAX content load
mQuery.get(url, function(response) {
    mQuery('#container').html(response);
    Mautic.renderCharts('#container');
});
```

## Chart Data Structure

The PHP helpers output this structure for Chart.js:

```javascript
// Line/Bar chart data
{
    "labels": ["Jan", "Feb", "Mar"],
    "datasets": [{
        "label": "Sent",
        "data": [100, 150, 200],
        "backgroundColor": "rgba(78, 93, 157, 0.1)",
        "borderColor": "rgba(78, 93, 157, 0.8)"
    }]
}

// Pie chart data
{
    "labels": ["Desktop", "Mobile"],
    "datasets": [{
        "data": [60, 40],
        "backgroundColor": ["#4E5D9D", "#00B49C"]
    }]
}
```

## Mautic Default Colors

```php
// In order of dataset index
'#4E5D9D'  // Primary blue-purple
'#00B49C'  // Teal
'#FD9572'  // Coral
'#FDB933'  // Yellow
'#757575'  // Gray
'#9C4E5C'  // Burgundy
'#694535'  // Brown
'#596935'  // Olive
```

## File Locations

| Type | Path |
|------|------|
| PHP Helpers | `app/bundles/CoreBundle/Helper/Chart/` |
| JavaScript | `app/bundles/CoreBundle/Assets/js/7.charts.js` |
| Twig Template | `app/bundles/CoreBundle/Resources/views/Helper/chart.html.twig` |

## Controller Example

```php
public function viewAction($objectId): Response
{
    $dateFrom = new \DateTime('-30 days');
    $dateTo = new \DateTime();

    $chart = new LineChart('d', $dateFrom, $dateTo);
    $chart->setDataset(
        $this->translator->trans('mautic.email.sent'),
        $this->getModel('email')->getSentEmailsLineChartData($dateFrom, $dateTo, $objectId)
    );

    return $this->delegateView([
        'viewParameters' => [
            'stats' => $chart->render(),
        ],
        'contentTemplate' => '@MyBundle/view.html.twig',
    ]);
}
```
