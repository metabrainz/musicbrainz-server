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

/**
 * MB.Control.ReleaseLabel keeps track of the label/catno inputs.
 */
MB.Control.ReleaseLabel = function(row, parent) {
    var self = MB.Object();

    self.row = row;
    self.parent = parent;

    var template = MB.utility.template (
        '<div class="release-label">' +
            '<input type="hidden" value="0" name="labels.#{labelno}.deleted" id="id-labels.#{labelno}.deleted">' +
            '<input type="hidden" value="" name="labels.#{labelno}.label_id" id="id-labels.#{labelno}.label_id" class="label-id">' +
            '<label id="label-labels.#{labelno}.name" for="id-labels.#{labelno}.name" class="label-name">Label</label>' +
            '<input type="text" value="" name="labels.#{labelno}.name" id="id-labels.#{labelno}.name" class="label-name">' +
            '<label id="label-labels.#{labelno}.catalog_number" for="id-labels.#{labelno}.catalog_number" class="catno">Cat.No</label>' +
            '<input type="text" value="" name="labels.#{labelno}.catalog_number" id="id-labels.#{labelno}.catalog_number" class="catno">' +
        '</div>'
    );

    if (!self.row)
    {
        /* New release label, render the associated inputs. */
        self.row = $(template.draw ({ 'labelno': self.parent.labels.length }));
        self.row.appendTo ($('div.label-container').append ());
    }

    var autocompleted = function (event, data) {
        self.id.val(data.id);
        self.name.val(data.name).removeClass('error');

        event.preventDefault();
        return false;
    };

    var blurred = function (event) {
    };

                                         self.parent = parent;
    self.template = template;
    self.name = self.row.find('input.label-name');
    self.id = self.row.find('input.label-id');
    self.autocompleted = autocompleted;
    self.blurred = blurred;

    self.name.bind('blur', self.blurred);
    self.name.result(self.autocompleted);
    self.name.autocomplete("/ws/js/label", MB.utility.autocomplete.options);

    return self;
};


MB.Control.ReleaseInformation = function() {
    var self = MB.Object();

    var initialize = function () {

        $('div.release-label').each (function (i) {
            self.labels.push (MB.Control.ReleaseLabel($(this), self));
        });

        $('#id-barcode').live ('change', function () {
            var barcode = $(this).val ().replace (/[^0-9]/g, '');
            $(this).val (barcode);
        });

        $('a[href=#add_label]').click (function (event) {
            self.addLabel ();
            event.preventDefault ();
        });

        var annotation = $('#annotation');
        annotation.focus (function() { annotation.css('height','70px'); });
        annotation.blur (function() {
            if (!annotation.attr('value'))
            {
                annotation.css('height','10px');
            }
        });

        self.artistcredit = MB.Control.ArtistCreditVertical (
            $('input#release-artist'), $('div.artist-credit')
        );
    };

    var addLabel = function () {
        var labels = self.labels.length;

        self.labels.push (MB.Control.ReleaseLabel (null, self));
    };

    self.labels = [];
    self.initialize = initialize;
    self.addLabel = addLabel;

    self.initialize ();

    return self;
}
