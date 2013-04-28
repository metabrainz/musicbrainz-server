MB.Control.LabelEdit = function (bubbles) {
    var self = MB.Object();

    self.bubbles = bubbles;
    self.$span = $('span.area.autocomplete');
    self.$name = self.$span.find ('input.name');
    self.$type = $('#id-type_id');

    MB.Control.EntityAutocomplete ({
        inputs: $('span.area.autocomplete')
    });

    self.$name.bind ('lookup-performed', function (event) {
        var data = self.$name.data ('lookup-result');

        self.$type.find ('option').removeAttr ('selected');
        var $select_option = data.type ?
            self.$type.find ('option[value='+data.type+']') :
            self.$type.find ('option:eq(0)');

        $select_option.attr ('selected', 'selected');
        self.$type.attr ('disabled', 'disabled');
    });

    self.$name.bind ('cleared.mb', function (event) {
        self.$type.removeAttr ('disabled');
    });

    self.$name.bind ('focus.mb', function (event) {
        var gid = self.$span.find ('input.gid').val ();
        if (gid)
        {
            self.bubble.show ();
            self.bubble.$content.find ('a.area')
                .attr ('href', '/area/' + gid)
                .text (self.$span.find ('input.name').val ());
        }
        else
        {
            self.bubble.hide ();
        }
    });

    self.bubble = self.bubbles.add (self.$span, $('div.area.bubble'));

    return self;
};
