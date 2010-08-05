/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

MB.Control.ReleaseLabel = function(row) {
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


MB.Control.ReleaseLabelContainer = function() {
    var self = MB.Object();

//     var addRow = function(event) {
//         event.preventDefault();

//         var row = $(self.template.draw ({ field: 'edit-release.labels.' + self.count }));
//         row.insertBefore (self.addButton);

//         MB.Control.ReleaseLabel(row);
//         self.count += 1;
//     };

//     self.template = MB.utility.template (
//         '<li class="release-label">' +
//             '<input type="checkbox" name="#{field}.removed" class="remove" /> ' +
//             '<input type="hidden" name="#{field}.label_id" class="label-id" />' +
//             '<input type="text" name="kuno" class="label-name" value="" />' +
//             ' &ndash; ' +
//             '<input class="catalog-number" name="#{field}.catalog_number" />' +
//         '</li>'
//     );

//     self.count = 0;
//     self.addRow = addRow;
//     self.ul = $('ul.release-labels');
//     self.addButton = $(MB.html.li({}, MB.html.button({}, 'Add a new release label')));
//     self.addButton.appendTo(self.ul).click (self.addRow);

    $('div.release-label').each (function (i) {
        MB.Control.ReleaseLabel($(this), self);
        self.count += 1;
    });

    return self;
}
