---
name: mautic-js
description: This skill should be used when the user asks to "write Mautic JavaScript", "create bundle JS", "add JavaScript to plugin", "mQuery", "Mautic.ajaxActionRequest", "bundle OnLoad", "OnLoad function", "chosen select", "Mautic modal", "loading indicator". Provides guide for writing JavaScript in Mautic bundles and plugins.
version: 1.1.0
---

# Mautic JavaScript Development

## File Location

Add JavaScript to the **main JS file** of your bundle/plugin (autoloaded by Mautic):

```
# Bundles
app/bundles/{BundleName}/Assets/js/{bundlename}.js

# Plugins
plugins/{PluginName}/Assets/js/{pluginname}.js
```

Examples:
- `app/bundles/EmailBundle/Assets/js/email.js`
- `app/bundles/LeadBundle/Assets/js/lead.js`
- `plugins/MauticFocusBundle/Assets/js/focus.js`

**Important:** Don't create separate JS files - add all code to the main bundle JS file.

## Core Rules

### 1. Always use mQuery (not $ or jQuery)

```javascript
mQuery('#myElement').val();
mQuery('.my-class').addClass('active');
```

### 2. Namespace functions under Mautic object

```javascript
// Correct
Mautic.myBundleOnLoad = function(container, response) { };
Mautic.myCustomFunction = function() { };

// Wrong - never do this
function myFunction() { }
```

## OnLoad Pattern (Required)

Every bundle JS file needs an OnLoad function. Name follows: `Mautic.{bundleName}OnLoad`

```javascript
// File: MyBundle/Assets/js/mybundle.js
Mautic.mybundleOnLoad = function(container, response) {
    // container = '#app-content' (loaded content selector)
    // response = server response data

    // Initialize search if on list page
    if (mQuery(container + ' #list-search').length) {
        Mautic.activateSearchAutocomplete('list-search', 'mybundle.entity');
    }

    // Initialize your components
    mQuery('#myButton').on('click.mybundle', function() {
        // Handle click
    });
};
```

### OnUnload (Cleanup)

```javascript
Mautic.mybundleOnUnload = function(id) {
    // Clear any intervals
    if (typeof MauticVars.moderatedIntervals['myInterval'] != 'undefined') {
        Mautic.clearModeratedInterval('myInterval');
    }
};
```

## AJAX Requests

### ajaxActionRequest (Primary Method)

```javascript
// Simple request
Mautic.ajaxActionRequest('mybundle:getData', {id: 123}, function(response) {
    if (response.success) {
        mQuery('#result').html(response.data);
    }
});

// With loading bar
Mautic.ajaxActionRequest('mybundle:save', formData, function(response) {
    // Handle response
}, true);  // true = show loading bar

// GET request
Mautic.ajaxActionRequest('mybundle:fetch', {id: 1}, callback, false, false, "GET");
```

## Common UI Patterns

### Loading Indicators

```javascript
Mautic.startPageLoadingBar();
Mautic.stopPageLoadingBar();

// For field labels
Mautic.activateLabelLoadingIndicator('field_id');
Mautic.removeLabelLoadingIndicator();
```

### Chosen Select (Dropdowns)

```javascript
// Activate
Mautic.activateChosenSelect('#mySelect');

// Update after changing options
mQuery('#mySelect').html(newOptions);
mQuery('#mySelect').trigger('chosen:updated');

// Destroy before replacing element
Mautic.destroyChosen(mQuery('#mySelect'));
```

### Tooltips

```javascript
mQuery('[data-toggle="tooltip"]').tooltip({html: true, container: 'body'});

// Destroy before removing element
mQuery('#element').tooltip('destroy');
```

## Event Binding

Always use namespaced events:

```javascript
// Bind with namespace
mQuery('#element').on('click.mybundle', handler);

// Unbind by namespace (cleanup)
mQuery('#element').off('.mybundle');

// Prevent duplicates
mQuery('#element').off('click.mybundle').on('click.mybundle', handler);
```

## Reinitialize After AJAX

After injecting HTML via AJAX, reinitialize Mautic components:

```javascript
// Full reinitialization
Mautic.onPageLoad('#container', response);

// Or manually activate elements:
mQuery('#newElement [data-toggle="tooltip"]').tooltip({html: true});
mQuery('#newElement a[data-toggle="ajax"]').on('click', function(e) {
    e.preventDefault();
    return Mautic.ajaxifyLink(this, e);
});
mQuery('#newElement [data-toggle="ajaxmodal"]').on('click.ajaxmodal', function(e) {
    e.preventDefault();
    Mautic.ajaxifyModal(this, e);
});
```

## Plugin Actions

For plugins, use format `plugin:bundlename:actionName`:

```javascript
Mautic.ajaxActionRequest('plugin:myfocus:getData', {id: 1}, callback);
```

## Best Practices

1. **Always check element exists**: `if (mQuery('#el').length) { }`
2. **Use ajaxActionRequest** for backend calls
3. **Handle errors**: `Mautic.processAjaxError(request, textStatus, errorThrown)`
4. **Clean up in OnUnload** - intervals, events, state
5. **Namespace all events** with bundle name

## Global Variables

- `mauticAjaxUrl` - AJAX endpoint URL
- `mauticBasePath` - Base path
- `mauticLang` - Translation strings

## Additional Resources

- **`references/ajax-patterns.md`** - Intervals, batch processing, forms
- **`references/ui-components.md`** - Modals, sortables, date pickers
