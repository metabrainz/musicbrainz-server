MB.Control.AccountEdit = function (bubbles) {
    var self = MB.Object();

    MB.Control.EntityAutocomplete ({
        inputs: $('span.area.autocomplete')
    });

    return self;
};

