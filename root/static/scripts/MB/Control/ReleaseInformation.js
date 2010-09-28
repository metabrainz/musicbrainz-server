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

    // FIXME: hardcoded static url in this template. --warp.
    var template = MB.utility.template (
        '<div class="release-label">' +
            '<input type="hidden" value="" name="labels.#{labelno}.label_id" id="id-labels.#{labelno}.label_id" class="label-id">' +
            '<label id="label-labels.#{labelno}.name" for="id-labels.#{labelno}.name" class="label-name">Label</label>' +
            '<input type="text" value="" name="labels.#{labelno}.name" id="id-labels.#{labelno}.name" class="label-name">' +
            '<label id="label-labels.#{labelno}.catalog_number" for="id-labels.#{labelno}.catalog_number" class="catno">Cat.No</label>' +
            '<input type="text" value="" name="labels.#{labelno}.catalog_number" id="id-labels.#{labelno}.catalog_number" class="catno">' +
            '<span class="remove-label">' +
            '  <input type="hidden" value="0" name="labels.#{labelno}.deleted" id="id-labels.#{labelno}.deleted">' +
            '  <a class="remove-label" href="#remove_label">' +
            '    <img src="/static/images/release_editor/remove-label.png" title="Remove Label" />' +
            '  </a>' +
            '</span>' +
        '</div>'
    );

    if (!self.row)
    {
        /* New release label, render the associated inputs. */
        self.row = $(template.draw ({ 'labelno': self.parent.labels.length }));
        self.row.appendTo ($('div.label-container').append ());
    }

    /**
     * toggleDelete (un)marks the track for deletion. Provide a boolean to delete
     * or undelete a track, or leave it empty to toggle.
     */
    var toggleDelete = function (value) {
        var deleted = (value === undefined) ? !parseInt (self.deleted.val ()) : value;
        if (deleted)
        {
            self.deleted.val('1');
            self.row.addClass('deleted');
            self.name.attr ('disabled', 'disabled');
            self.catno.attr ('disabled', 'disabled');
        }
        else
        {
            self.deleted.val ('0');
            self.row.removeClass('deleted');
            self.name.removeAttr ('disabled');
            self.catno.removeAttr ('disabled');
        }

        window.toggled = self;
    };

    /**
     * isDeleted returns true if this track is marked for deletion.
     */
    var isDeleted = function () {
        return self.deleted.val () === '1';
    };


    var autocompleted = function (event, data) {
        self.id.val(data.id);
        self.name.val(data.name).removeClass('error');

        event.preventDefault();
        return false;
    };

    var blurred = function (event) {
    };

    self.id = self.row.find('input.label-id');
    self.name = self.row.find('input.label-name');
    self.catno = self.row.find('input.catno');
    self.deleted = self.row.find ('span.remove-label input');

    self.parent = parent;
    self.template = template;
    self.autocompleted = autocompleted;
    self.toggleDelete = toggleDelete;
    self.blurred = blurred;

    self.name.bind('blur', self.blurred);
    self.name.result(self.autocompleted);
    self.name.autocomplete("/ws/js/label", MB.utility.autocomplete.options);

    self.row.find ("a[href=#remove_label]").click (function () { self.toggleDelete() });

    return self;
};


MB.Control.ReleaseBarcode = function() {
    var self = MB.Object();

    self.input = $('#id-barcode');
    self.message = $('p.barcode-message');
    self.suggestion = $('p.barcode-suggestion');
    self.count = 0;

    var checkDigit = function (barcode) {
        var weights = [ 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3 ];

        if (barcode.length !== 12)
        {
            return false;
        }

        var calc = 0;
        for (i = 0; i < 12; i++)
        {
            calc += parseInt (barcode[i]) * weights[i];
        }

        var checkdigit = 10 - (calc % 10);

        return checkdigit === 10 ? '0' : '' + checkdigit;
    };

    var validate = function (barcode) {
        return self.checkDigit (barcode.slice (0, 12)) === barcode[12];
    };

    var clean = function () {
        var barcode = self.input.val ().replace (/[^0-9]/g, '');

        self.input.val (barcode);

        return barcode;
    };

    var update = function () {
        var barcode = self.clean ();

        if (barcode.length === 11)
        {
            self.message.html (MB.text.Barcode.NoCheckdigitUPC);
            self.suggestion.html (MB.text.Barcode.CheckDigit.replace (
                '#checkdigit#', self.checkDigit ('0' + barcode)));
        }
        else if (barcode.length === 12)
        {
            if (self.validate ('0' + barcode))
            {
                self.message.html (MB.text.Barcode.ValidUPC);
                self.suggestion.html ("");
            }
            else
            {
                self.message.html (MB.text.Barcode.InvalidUPC);
                self.suggestion.html (MB.text.Barcode.DoubleCheck + ' ' +
                    MB.text.Barcode.CheckDigit.replace (
                        '#checkdigit#', self.checkDigit (barcode)));
            }
        }
        else if (barcode.length === 13)
        {
            if (self.validate (barcode))
            {
                self.message.html (MB.text.Barcode.ValidEAN);
                self.suggestion.html ('');
            }
            else
            {
                self.message.html (MB.text.Barcode.InvalidEAN);
                self.suggestion.html (MB.text.DoubleCheck);
            }
        }
        else
        {
            self.message.html (MB.text.Barcode.Invalid);
            self.suggestion.html (MB.text.DoubleCheck);
        }
    };

    self.checkDigit = checkDigit;
    self.validate = validate;
    self.clean = clean;
    self.update = update;

    self.input.bind ('change keyup', self.update);
    self.update ();

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

    self.barcode = MB.Control.ReleaseBarcode ();
    self.labels = [];
    self.initialize = initialize;
    self.addLabel = addLabel;

    self.initialize ();

    return self;
}

