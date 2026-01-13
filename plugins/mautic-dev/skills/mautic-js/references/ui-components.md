# Mautic UI Components

## Modals

### Open Modal via AJAX

```javascript
// From element with data-toggle="ajaxmodal"
mQuery('[data-toggle="ajaxmodal"]').on('click.ajaxmodal', function(event) {
    event.preventDefault();
    Mautic.ajaxifyModal(this, event);
});

// Pass extra data
mQuery(this).data('form-data', {extraParam: 'value'});
Mautic.ajaxifyModal(this, event);
```

### Modal Events

```javascript
// After modal shown
mQuery('#myModal').on('shown.bs.modal', function() {
    Mautic.activateChosenSelect('#myModal select');
});

// Hide modal
mQuery('#myModal').modal('hide');
```

### Loading State

```javascript
Mautic.startModalLoadingBar('#MauticSharedModal');
Mautic.stopModalLoadingBar('#MauticSharedModal');
```

## Sortable Lists

```javascript
mQuery('#sortableList').sortable({
    items: '.sortable-item',
    axis: 'y',
    helper: function(e, ui) {
        ui.children().each(function() {
            mQuery(this).width(mQuery(this).width());
        });
        return ui;
    },
    stop: function(e, ui) {
        mQuery.ajax({
            type: "POST",
            url: mauticAjaxUrl + "?action=bundle:reorder",
            data: mQuery('#sortableList').sortable("serialize")
        });
    }
});
```

## Date/Time Pickers

```javascript
// DateTime
Mautic.activateDateTimeInputs('#field', 'datetime');

// Date only
Mautic.activateDateTimeInputs('#field', 'date');

// Time only
Mautic.activateDateTimeInputs('#field', 'time');

// Manual init
mQuery('#field').datetimepicker({
    format: 'Y-m-d H:i',
    lazyInit: true,
    validateOnBlur: false,
    allowBlank: true
});
```

## Double-Click to Edit

Common pattern for list items:

```javascript
mQuery('.item-row').on('dblclick', function(event) {
    event.preventDefault();
    mQuery(this).find('.btn-edit').first().click();
});
```

## Show/Hide Elements

```javascript
// Fade animations
mQuery('#container').fadeIn();
mQuery('#container').fadeOut();

// Slide animations
mQuery('#panel').slideDown('fast');
mQuery('#panel').slideUp('fast');
```

## Enable/Disable Fields

```javascript
// Disable
mQuery('#field').prop('disabled', true).addClass('disabled');
mQuery('#field').trigger('chosen:updated');  // If chosen

// Enable
mQuery('#field').prop('disabled', false).removeClass('disabled');
mQuery('#field').trigger('chosen:updated');
```
