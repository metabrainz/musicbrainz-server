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
MB.Control.ReleaseLabel = function($row, parent, labelno) {
    var self = MB.Object();

    self.$row = $row;
    self.parent = parent;
    self.labelno = labelno;

    if (!self.$row)
    {
        self.$catno_message = $('div.catno-container:first').clone ();
        self.$catno_message.insertAfter ($('div.catno-container:last'));
        self.$catno_message.hide ();

        self.$row = $('div.release-label:first').clone ();
        self.$label = self.$row.find ('span.label.autocomplete');
        self.$label.find ('input.id').val ('');
        self.$label.find ('input.gid').val ('');
        self.$label.find ('input.name').val ('');
        self.$row.find ('input.catno').val ('');
        self.$row.find ('*').each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').
                           replace('labels.0', "labels." + self.labelno));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').
                           replace('labels.0', "labels." + self.labelno));
            }
        });

        self.$row.insertAfter ($('div.release-label:last'));
        self.$row.find ('span.remove-label input').val ('0');
        self.$row.show ();
    }

    /**
     * markDeleted marks the track for deletion.
     */
    self.markDeleted = function () {
        self.$deleted.val('1');
        self.$row.hide ();
    };

    /**
     * isDeleted returns true if this track is marked for deletion.
     */
    self.isDeleted = function () {
        return self.$deleted.val () === '1';
    };

    self.catnoUpdate = function () {

        if (self.$catno.val ().match (/^B00[0-9A-Z]{7}$/))
        {
            self.$catno.data ('bubble').show ();
        }
        else
        {
            self.$catno.data ('bubble').hide ();
        }
    };

    self.$label = self.$row.find ('span.label.autocomplete');
    self.$catno = self.$row.find('input.catno');
    self.$catno_message = $('div.catno').eq(self.labelno);
    self.$deleted = self.$row.find ('span.remove-label input');

    self.$catno.bind ('change keyup focus', self.catnoUpdate);
    MB.Control.EntityAutocomplete ({ inputs: self.$label, allow_empty: true });

    self.$row.find ("a[href=#remove_label]").click (function () { self.markDeleted() });

    if (self.isDeleted ())
    {
        // if the label is marked as deleted, make sure it is displayed as such
        // after page load.
        self.markDeleted ();
    }

    return self;
};


MB.Control.ReleaseBarcode = function() {
    var self = MB.Object();

    self.$input = $('#id-barcode');
    self.$message = $('p.barcode-message');
    self.$confirm = $('p.barcode-confirm');
    self.count = 0;

    self.checkDigit = function (barcode) {
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

    self.validate = function (barcode) {
        return self.checkDigit (barcode.slice (0, 12)) === barcode[12];
    };

    self.clean = function () {
        var current = self.$input.val ();
        var barcode = current.replace (/[^0-9]/g, '');

        if (barcode !== current)
        {
            self.$input.val (barcode);
        }

        return barcode;
    };

    self.confirmation_required = function (required) {
        if (required)
        {
            self.$confirm.show ();
        }
        else
        {
            self.$confirm.hide ();
        }
    };

    self.update = function () {
        var barcode = self.clean ();

        if (barcode.length === 0)
        {
            self.$message.html ('');
            self.confirmation_required (false);
        }
        else if (barcode.length === 11)
        {
            self.$message.html (
                MB.text.Barcode.NoCheckdigitUPC + ' ' +
                MB.text.Barcode.CheckDigit.replace (
                    '#checkdigit#', self.checkDigit ('0' + barcode)));
            self.confirmation_required (true);
        }
        else if (barcode.length === 12)
        {
            if (self.validate ('0' + barcode))
            {
                self.$message.html (MB.text.Barcode.ValidUPC);
                self.confirmation_required (false);
            }
            else
            {
                self.$message.html (
                    MB.text.Barcode.InvalidUPC + ' ' +
                    MB.text.Barcode.DoubleCheck + ' ' +
                    MB.text.Barcode.CheckDigit.replace (
                        '#checkdigit#', self.checkDigit (barcode)));
                self.confirmation_required (true);
            }
        }
        else if (barcode.length === 13)
        {
            if (self.validate (barcode))
            {
                self.$message.html (MB.text.Barcode.ValidEAN);
                self.confirmation_required (false);
            }
            else
            {
                self.$message.html (MB.text.Barcode.InvalidEAN + ' ' +
                                    MB.text.Barcode.DoubleCheck);
                self.confirmation_required (true);
            }
        }
        else
        {
            self.$message.html (MB.text.Barcode.Invalid + ' ' +
                                MB.text.Barcode.DoubleCheck);
            self.confirmation_required (true);
        }
    };

    self.$input.bind ('change keyup', self.update);
    self.update ();

    return self;
};


MB.Control.ReleaseDate = function (bubble_collection) {
    var self = MB.Object ();

    self.bubbles = bubble_collection;

    self.inputs = [ $('#id-date\\.year'),
        $('#id-date\\.month'), $('#id-date\\.day') ]
    self.message = $('div.date');

    self.amazonEpoch = function () {
        return (self.inputs[0].val () == '1995' &&
                self.inputs[1].val () == '10' &&
                self.inputs[2].val () == '25');
    };

    self.januaryFirst = function () {
        return (parseInt (self.inputs[1].val (), 10) === 1 &&
                parseInt (self.inputs[2].val (), 10) === 1);
    };

    self.update = function (event) {
        var amazon = self.amazonEpoch ();
        var january = self.januaryFirst ();

        if (amazon || january)
        {
            self.bubble.show ();
        }
        else
        {
            self.bubble.hide ();
        }

        if (amazon)
        {
            $('p.amazon').show ();
        }
        else
        {
            $('p.amazon').hide ();
        }

        if (january)
        {
            $('p.january-first').show ();
        }
        else
        {
            $('p.january-first').hide ();
        }
    };

    $.each (self.inputs, function (idx, item) {
        item.bind ('change keyup focus', self.update);
    });

    self.bubble = self.bubbles.add (
        self.inputs[0].closest ('span.partial-date'), self.message);

    return self;
};

MB.Control.ReleaseInformation = function(action) {
    var self = MB.Object();

    self.bubbles = MB.Control.BubbleCollection ();
    self.release_date = MB.Control.ReleaseDate (self.bubbles);

    self.variousArtistsChecked = function () {
        if (self.artistcredit.isEmpty ())
        {
            var va = {
                'artist_name': MB.constants.VARTIST_NAME,
                'sortname': MB.constants.VARTIST_NAME,
                'name': '',
                'gid': MB.constants.VARTIST_GID,
                'id': ''
            };

            self.artistcredit.render ({ names: [ va ] });
        }
    };

    self.initialize = function () {

        self.bubbles.add ($('#id-name'), $('div.guess-case.bubble'));
        self.bubbles.add ($('#help-cta'), $('div.help-cta'));
        self.bubbles.add ($('#open-ac'), $('div.artist-credit'));
        self.bubbles.add ($('#id-barcode'), $('div.barcode'));
        self.bubbles.add ($('#id-annotation'), $('div.annotation'));
        self.bubbles.add ($('#id-comment'), $('div.comment'));

        MB.Control.GuessCase ('release', $('#id-name'));

        $('#id-various_artists').bind ('change.mb', function () {
            if ($(this).is(':checked'))
            {
                self.variousArtistsChecked ();
            }
        });

        if ($('div.artist-credit-box:eq(0) input.gid').val () ===
            MB.constants.VARTIST_GID)
        {
            $('#id-various_artists').attr ('checked', 'checked');
        }

        $('div.release-label').each (function () {
            self.addLabel ($(this));
        });

        $('#id-barcode').live ('change', function () {
            var barcode = $(this).val ().replace (/[^0-9]/g, '');
            $(this).val (barcode);
        });

        $('a[href=#add_label]').bind ('click.mb', function (event) {
            self.addLabel ();
            self.bubbles.hideAll ();
            event.preventDefault ();
        });

        self.artistcredit = MB.Control.ArtistCreditVertical (
            $('input#release-artist'), $('div.artist-credit'), $('input#open-ac')
        );

        MB.Control.EntityAutocomplete ({
            inputs: $('span.release-group.autocomplete'),
            allow_empty: (action !== 'edit')
        });
    };

    self.addLabel = function ($row) {
        var labelno = self.labels.length;
        var l = MB.Control.ReleaseLabel($row, self, labelno);

        self.labels.push (l);

        MB.Control.BubbleDocBase (self.bubbles, l.$catno, l.$catno_message);

        return l;
    };

    self.submit = function () {
        // always submit disabled inputs.
        $('input:disabled').removeAttr ('disabled');
    };

    self.barcode = MB.Control.ReleaseBarcode ();
    self.labels = [];

    self.initialize ();

    $('form.release-editor').bind ('submit.mb', self.submit);

    return self;
}

