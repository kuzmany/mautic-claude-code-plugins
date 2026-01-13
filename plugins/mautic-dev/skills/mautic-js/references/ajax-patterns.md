# Mautic AJAX Patterns

## ajaxActionRequest API

```javascript
Mautic.ajaxActionRequest(action, data, callback, showLoadingBar, queue, method)
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `action` | required | `'bundle:actionName'` |
| `data` | required | Object or serialized string |
| `callback` | optional | Success function |
| `showLoadingBar` | false | Show page loading bar |
| `queue` | false | Queue instead of abort |
| `method` | "POST" | HTTP method |

## Batch Processing

Load stats for multiple items efficiently:

```javascript
var ids = [];
mQuery('td.col-stats').each(function() {
    ids.push(mQuery(this).attr('data-stats'));
});

// Process in batches of 10
while (ids.length > 0) {
    let batch = ids.splice(0, 10);
    Mautic.ajaxActionRequest(
        'email:getStats',
        {ids: batch},
        function(response) {
            response.stats.forEach(function(stat) {
                mQuery('#count-' + stat.id).html(stat.count);
            });
        },
        false, true, "GET"  // queue=true prevents request collision
    );
}
```

## Moderated Intervals

Polling without overlapping requests:

```javascript
// Start interval
Mautic.setModeratedInterval('myKey', 'myCallback', 5000);

// Callback - MUST signal completion
Mautic.myCallback = function() {
    Mautic.ajaxActionRequest('bundle:check', {}, function(response) {
        // Process response
        Mautic.moderatedIntervalCallbackIsComplete('myKey');  // Required!
    });
};

// Stop interval (in OnUnload)
Mautic.clearModeratedInterval('myKey');
```

## Form Submission

### Using postForm

```javascript
Mautic.postForm(mQuery('#myForm'), function(response) {
    if (response.inMain) {
        Mautic.processPageContent(response);
    } else {
        Mautic.processModalContent(response, '#' + response.modalId);
    }
});
```

### Form Validation Callback

```javascript
// Set callback
mQuery('form[name="myform"]').data('submit-callback', 'validateMyForm');

Mautic.validateMyForm = function() {
    if (!mQuery('#required_field').val()) {
        alert('Field required');
        return false;  // Prevent submit
    }
    return true;
};
```

## Lazy Loading

```javascript
Mautic.loadStats = function() {
    var container = mQuery('#stats-container');
    if (!container.length) return;

    mQuery.get(container.data('url'), function(response) {
        response.target = '#stats-container';
        Mautic.processPageContent(response);
    });
};
```

## Error Handling

```javascript
mQuery.ajax({
    url: mauticAjaxUrl,
    data: {action: 'bundle:action'},
    success: function(response) {
        if (response.error) {
            Mautic.setFlashes(Mautic.addErrorFlashMessage(response.error));
        }
    },
    error: function(request, textStatus, errorThrown) {
        Mautic.processAjaxError(request, textStatus, errorThrown);
    }
});
```
