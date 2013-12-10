MB.Control.LabelEdit = function (bubbles) {
    var self = {};

    var bubbles = MB.Control.BubbleCollection ();
    MB.Control.initialize_guess_case (bubbles, 'label', 'id-edit-label');

    MB.Control.Area('span.area.autocomplete', bubbles);

    return self;
};
