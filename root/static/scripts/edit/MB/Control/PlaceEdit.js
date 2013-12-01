MB.Control.PlaceEdit = function (bubbles) {
    var self = {};

    var bubbles = MB.Control.BubbleCollection ();
    MB.Control.initialize_guess_case (bubbles, 'place', 'id-edit-place');

    MB.Control.Area('span.area.autocomplete', bubbles)

    return self;
};
