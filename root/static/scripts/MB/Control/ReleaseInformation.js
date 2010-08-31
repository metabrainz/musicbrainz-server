
MB.Control.ReleaseBarcode = function(row) {
    var self = MB.Object();

    var autocompleted = function (event, data) {
        self.id.val(data.id);
        self.name.val(data.name).removeClass('error');

        event.preventDefault();
        return false;
    };

    var blurred = function (event) {
    };

    self.name = row.find('input.label-name');
    self.id = row.find('input.label-id');
    self.autocompleted = autocompleted;
    self.blurred = blurred;

//     var removeToggle = new MB.Control.ToggleButton(MB.url.ReleaseEditor.removeImages);
//     removeToggle.draw(row.find('input.remove'));

    self.name.bind('blur', self.blurred);
    self.name.result(self.autocompleted);
    self.name.autocomplete("/ws/js/label", MB.utility.autocomplete.options);

    return self;
};

