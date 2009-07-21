(function($) {

// $ chain extensions
$.fn.extend({
    // Turn an input[type="checkbox"] element into a toggle button
    toggleButton: function(options) {
        return this.each(function() {
            new jQuery.toggle(this, options);
        });
    },

    // Bind a function to callback when the button is toggled on
    on: function(callback) {
        return this.bind('toggleOn', callback)
    },

    // Bind a function to callback when the button is toggled off
    off: function(callback) {
        return this.bind('toggleOff', callback)
    },

    toggleOn: function() { return this.trigger('toggleOn') },
    toggleOff: function() { return this.trigger('toggleOff') }
});

// The plugin itself
jQuery.toggle = function(checkbox, options)
{
    var settings = {
        on_graphic: '/static/images/release_editor/edit-on.png',      // Class to apply when on
        off_graphic: '/static/images/release_editor/edit-off.png',    // Class to apply when off
        initial: false,             // Whether the button is initial toggled on or off (true or false)
    };
    jQuery.extend(settings, options);

    var currentlyOn = settings.initial;

    var $check = $(checkbox).hide()
        .bind('toggleOn', function() {
            currentlyOn = true;
            $check.attr('checked', 'checked');
            $img.attr('src', settings.on_graphic);
        })
        .bind('toggleOff', function() {
            currentlyOn = false;
            $check.removeAttr('checked');
            $img.attr('src', settings.off_graphic);
        });

    var $button = $('<button>').addClass('image-button').insertAfter(checkbox)
        .click(function(event) {
            event.preventDefault();
            $check.trigger(currentlyOn ? 'toggleOff' : 'toggleOn')
        });

    var $img = $('<img>').attr('src', currentlyOn ? settings.on_graphic : settings.off_graphic).appendTo($button);

    if(currentlyOn)
        $button.attr('checked', 'checked');
};

$.fn.extend({
    imageButton: function(src, options) {
        options = jQuery.extend({}, options, { src: src });
        return this.each(function() { 
            new jQuery.imageButton(this, options);
        })
    },
    disable: function() {
        this.trigger('disable');
    },
    enable: function() {
        this.trigger('enable')
    },
});

jQuery.imageButton = function(button, options)
{
    options = jQuery.extend({}, {
        src: '',
        down: '',
        over: '',
        disabled: '',
    }, options);

    var $button = $(button).addClass('image-button');
    var $img = $('<img>').appendTo($button).attr('src', options.src);

    function change(src) {
        if(src.length > 0)
            $img.attr('src', src);
    };

    $button.hover(function() { })
        .mousedown(function() { change(options.down) })
        .mouseup(function() { change(options.src) })
        .mouseover(function() { change(options.over) })
        .bind('disable', function() {
            $button.attr('disabled', 'disabled');
            change(options.disabled);
        }).bind('enable', function() {
            $button.removeAttr('disabled');
            change(options.src);
        });
};

})(jQuery);
