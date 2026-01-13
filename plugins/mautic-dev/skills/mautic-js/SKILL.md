---
name: mautic-js
description: This skill should be used when the user asks to "write JavaScript for Mautic", "create JS functionality", "add client-side behavior", "implement AJAX calls in Mautic", "add keyboard shortcuts", "work with mQuery", "create OnLoad functions", or needs guidance on Mautic's JavaScript patterns, conventions, and best practices.
version: 0.1.0
---

# Mautic JavaScript Development

This skill provides guidance for writing JavaScript code in the Mautic application following established patterns and conventions.

## Core Concepts

### Global Objects

Mautic uses two global objects for JavaScript:

- **`Mautic`** - Main namespace for all bundle-specific functions
- **`MauticVars`** - Storage for global state variables

### jQuery with noConflict

Mautic uses jQuery in noConflict mode aliased as `mQuery`:

```javascript
var mQuery = jQuery.noConflict(true);
window.jQuery = mQuery;
```

Always use `mQuery` instead of `$` or `jQuery` in Mautic code.

### Icon Classes

Mautic uses Remix Icons with `ri-` prefix:

```javascript
// Spinner
'ri-loader-3-line ri-spin'

// Common icons
'ri-close-line'
'ri-check-line'
'ri-arrow-down-s-line'
'ri-arrow-up-s-line'
'ri-add-line'
'ri-draggable'
```

## Bundle JavaScript Pattern

Each bundle's JavaScript file follows a consistent pattern with OnLoad and OnUnload functions.

### OnLoad Functions

OnLoad functions initialize bundle-specific functionality when content loads:

```javascript
Mautic.emailOnLoad = function (container, response) {
    // Initialize search autocomplete
    if (mQuery(container + ' #list-search').length) {
        Mautic.activateSearchAutocomplete('list-search', 'email');
    }

    // Initialize bundle-specific functionality
    Mautic.initEmailDynamicContent();
};
```

**Parameters:**
- `container` - CSS selector for the content container (usually `'#app-content'`)
- `response` - AJAX response object with optional data

### OnUnload Functions

OnUnload functions clean up when navigating away:

```javascript
Mautic.emailOnUnload = function(id) {
    if (id === '#app-content') {
        delete Mautic.listCompareChart;
    }

    // Clear moderated intervals
    if (typeof MauticVars.moderatedIntervals['emailSendProgress'] != 'undefined') {
        Mautic.clearModeratedInterval('emailSendProgress');
    }
};
```

## AJAX Requests

### ajaxActionRequest

Use for calling AjaxController actions:

```javascript
Mautic.ajaxActionRequest(
    'lead:getLeadCount',           // action
    {id: id},                       // data
    function (response) {           // success callback
        if (response.success) {
            elem.html(response.html);
        }
    },
    false,                          // showLoadingBar
    true,                           // queue
    "GET"                           // method (default: POST)
);
```

### Standard jQuery AJAX

For custom AJAX calls, use mQuery with Mautic patterns:

```javascript
mQuery.ajax({
    showLoadingBar: true,
    url: mauticAjaxUrl,
    type: "POST",
    data: query,
    dataType: "json",
    success: function (response) {
        if (response.success) {
            // Handle success
        }
        Mautic.stopPageLoadingBar();
    },
    error: function (request, textStatus, errorThrown) {
        Mautic.processAjaxError(request, textStatus, errorThrown);
    }
});
```

### Global AJAX Variables

```javascript
mauticAjaxUrl      // Base URL for AJAX requests
mauticAjaxCsrf     // CSRF token (auto-added to POST requests)
mauticContent      // Current content identifier
mauticEnv          // Environment ('dev' or 'prod')
mauticLang         // Translation strings object
```

## Loading Indicators

### Page Loading Bar

```javascript
Mautic.startPageLoadingBar();
Mautic.stopPageLoadingBar();
```

### Button Loading Indicator

```javascript
Mautic.activateButtonLoadingIndicator(button);
Mautic.removeButtonLoadingIndicator(button);
```

### Label Loading Indicator

```javascript
Mautic.activateLabelLoadingIndicator('elementId');
Mautic.removeLabelLoadingIndicator();
```

### Icon Spinning

```javascript
Mautic.startIconSpinOnEvent(event);
Mautic.stopIconSpinPostEvent();
```

## Translations

Use `Mautic.translate()` for translatable strings:

```javascript
// Simple translation
var message = Mautic.translate('mautic.core.error');

// With parameters
var message = Mautic.translate('mautic.lead.count', {count: 5});
```

Translations are defined in PHP and passed to JavaScript via `mauticLang` object.

## Keyboard Shortcuts

Use Mousetrap library via `Mautic.addKeyboardShortcut`:

```javascript
Mautic.addKeyboardShortcut(
    'g d',                              // key sequence
    'Load the Dashboard',               // description
    function (e) {                      // callback
        mQuery('#mautic_dashboard_index').click();
    },
    'global'                            // section (optional)
);
```

Common shortcuts pattern:
- `g <key>` - Go to section (g d = dashboard, g c = contacts)
- `f <key>` - Feature toggle (f m = admin menu)
- Single keys - Context actions (e = edit, c = create)

## Moderated Intervals

Prevent overlapping AJAX requests with moderated intervals:

```javascript
// Set interval
Mautic.setModeratedInterval(
    'uniqueKey',           // identifier
    'callbackFunction',    // Mautic function name
    5000,                  // timeout in ms
    params                 // optional parameters
);

// Mark callback complete (call at end of callback)
Mautic.moderatedIntervalCallbackIsComplete('uniqueKey');

// Clear interval
Mautic.clearModeratedInterval('uniqueKey');
```

## Flash Messages

```javascript
// Add error flash
const flashMessage = Mautic.addFlashMessage('Error message');
Mautic.setFlashes(flashMessage);

// Add info flash
const flashMessage = Mautic.addInfoFlashMessage('Info message');
Mautic.setFlashes(flashMessage);

// With auto-close disabled
Mautic.setFlashes(flashMessage, false);
```

## Event Handling

### Document Ready

```javascript
mQuery(document).ready(function() {
    // Initialize on page load
});
```

### Event Delegation

```javascript
mQuery(container).on('click', '.selector', function(e) {
    e.preventDefault();
    // Handle click
});
```

### Form Events

```javascript
mQuery('#form').on('change', function() {
    mQuery(this).submit();
}).on('submit', function(e) {
    e.preventDefault();
    Mautic.refreshData(mQuery(this));
});
```

## UI Components

### Chosen Select

```javascript
Mautic.activateChosenSelect('#selectId');
Mautic.destroyChosen(mQuery('#selectId'));

// Trigger update after modifying options
mQuery('#selectId').trigger('chosen:updated');
```

### Tooltips

```javascript
mQuery('[data-toggle="tooltip"]').tooltip({html: true});
```

### Sortable Lists

```javascript
mQuery('#container').sortable({
    items: '.sortable-item',
    handle: '.ri-draggable',
    axis: 'y',
    stop: function(e, ui) {
        // Handle reorder
    }
});
```

### DateTimePicker

```javascript
mQuery('#field').datetimepicker({
    format: 'Y-m-d H:i',
    lazyInit: true,
    validateOnBlur: false,
    allowBlank: true,
    scrollMonth: false,
    scrollInput: false
});
```

## Common Patterns

### Toggle Switch Pattern

```javascript
Mautic.toggleLeadSwitch = function(toggleId, query, action) {
    var toggleOn  = 'ri-toggle-fill text-success';
    var toggleOff = 'ri-toggle-line text-danger';
    var spinClass = 'ri-spin ri-loader-3-line ';

    // Show spinner
    mQuery('#' + toggleId).removeClass(toggleOn + ' ' + toggleOff)
        .addClass(spinClass);

    mQuery.ajax({
        url: mauticAjaxUrl,
        type: "POST",
        data: query,
        dataType: "json",
        success: function (response) {
            mQuery('#' + toggleId).removeClass(spinClass);
            if (response.success) {
                mQuery('#' + toggleId).addClass(
                    action == 'add' ? toggleOn : toggleOff
                );
            }
        }
    });
};
```

### Lazy Loading Pattern

```javascript
Mautic.lazyLoadContent = function() {
    const container = mQuery('#container');
    if (!container.length) return;

    const targetUrl = container.data('target-url');
    mQuery.get(targetUrl, function(response) {
        response.target = '#container';
        Mautic.processPageContent(response);
    });
};
```

### Filter Form Pattern

```javascript
var filterForm = mQuery('#filters');
if (filterForm.length) {
    filterForm.on('change', function() {
        filterForm.submit();
    }).on('keyup', function() {
        filterForm.delay(200).submit();
    }).on('submit', function(e) {
        e.preventDefault();
        Mautic.refreshContent(filterForm);
    });
}
```

## File Organization

Bundle JavaScript files are located at:
```
app/bundles/{BundleName}/Assets/js/{bundle}.js
```

Core JavaScript is at:
```
app/bundles/CoreBundle/Assets/js/1.core.js
```

## Additional Resources

### Reference Files

For detailed patterns and complete examples, consult:
- **`references/ajax-patterns.md`** - Complete AJAX request patterns
- **`references/ui-components.md`** - UI component initialization

### Mautic Core Functions

Essential functions available globally:
- `Mautic.processPageContent(response)` - Process AJAX page response
- `Mautic.activateSearchAutocomplete(id, bundle)` - Initialize search
- `Mautic.makeModalsAlive(elements)` - Initialize modal triggers
- `Mautic.makeLinksAlive(elements)` - Initialize AJAX links
- `Mautic.dismissConfirmation()` - Close confirmation modal
