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


MB.Control.ReleaseGroup = function (action, parent) {
    var self = MB.Object();

    self.parent = parent;
    self.$span = $('span.release-group.autocomplete');
    self.$name = self.$span.find ('input.name');
    self.$type = $('#id-type_id');

    MB.Control.EntityAutocomplete ({
        inputs: $('span.release-group.autocomplete'),
        allow_empty: (action !== 'edit')
    });

    self.$name.bind ('lookup-performed', function (event) {
        var data = self.$name.data ('lookup-result');

        self.$type.find ('option').prop('selected', false);
        var $select_option = data.type ?
            self.$type.find ('option[value='+data.type+']') :
            self.$type.find ('option:eq(0)');

        $select_option.prop('selected', true);
        self.$type.prop('disabled', true);
    });

    self.$name.bind ('cleared.mb', function (event) {
        self.$type.prop('disabled', false);
    });

    self.$name.bind ('focus.mb', function (event) {
        var gid = self.$span.find ('input.gid').val ();
        if (gid)
        {
            self.bubble.show ();
            self.bubble.$content.find ('a.release-group')
                .attr ('href', '/release-group/' + gid)
                .text (self.$span.find ('input.name').val ());

            var disambig = self.$span.find ('input.comment').val ();
            if (disambig)
            {
                self.bubble.$content.find ('span.release-group.comment').text (' (' + disambig + ')').show ();
            }
            else
            {
                self.bubble.$content.find ('span.release-group.comment').text ("").hide ();
            }
        }
        else
        {
            self.bubble.hide ();
        }
    });

    self.bubble = self.parent.bubbles.add (self.$span, $('div.release-group.bubble'));

    return self;
};


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
        $('div.catno-container:first').clone ().hide ()
            .insertAfter ($('div.catno-container:last'));

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

    self.docBubbleUpdate = function () {
        var show_bubble = false;

        if (self.$catno.val ().match (/^B00[0-9A-Z]{7}$/))
        {
            show_bubble = true;
            self.$doc_bubble.find ('.catno.bubble').show ();
        }
        else
        {
            self.$doc_bubble.find ('.catno.bubble').hide ();
        }

        var gid = self.$label.find ('input.gid').val ();
        if (gid)
        {
            show_bubble = true;
            self.$doc_bubble.find ('.label.bubble').show ();
            self.$doc_bubble.find ('a.label').attr ('href', '/label/' + gid)
                .attr ('title', self.$label.find ('input.sortname').val ())
                .text (self.$label.find ('input.name').val ());

            var disambig = self.$label.find ('input.comment').val ();
            if (disambig)
            {
                self.$doc_bubble.find ('span.label.comment').text (' (' + disambig + ')').show ();
            }
            else
            {
                self.$doc_bubble.find ('span.label.comment').text ("").hide ();
            }
        }
        else
        {
            self.$doc_bubble.find ('.label.bubble').hide ();
        }

        self.bubble.toggle (show_bubble);
    };

    self.$label = self.$row.find ('span.label.autocomplete');
    self.$catno = self.$row.find('input.catno');
    self.$doc_bubble = $('div.catno-container div.bubble').eq(self.labelno);
    self.$deleted = self.$row.find ('span.remove-label input');

    self.$label.find ('input.name').bind ('focus.mb', self.docBubbleUpdate);
    self.$catno.bind ('change.mb keyup.mb focus.mb', self.docBubbleUpdate);
    MB.Control.EntityAutocomplete ({ inputs: self.$label, allow_empty: true });

    self.$row.find ("a[href=#remove_label]").click (function () { self.markDeleted() });

    if (self.isDeleted ())
    {
        // if the label is marked as deleted, make sure it is displayed as such
        // after page load.
        self.markDeleted ();
    }

    self.bubble = MB.Control.BubbleDocBase (
        self.parent.bubbles, self.$catno.closest ('div.release-label'), self.$doc_bubble);

    return self;
};


MB.Control.ReleaseBarcode = function() {
    var self = MB.Object();

    self.$input = $('#id-barcode');
    self.$message = $('p.barcode-message');
    self.$confirm = $('p.barcode-confirm');
    self.$no_barcode = $('#id-no_barcode');
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
        if (self.$no_barcode.is (':checked'))
        {
            self.$input.val ("");
            self.$input.prop('disabled', true);
        }
        else
        {
            self.$input.prop('disabled', false);
        }

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
    self.$no_barcode.bind ('change blur', self.update);
    self.update ();

    return self;
};


MB.Control.ReleaseDate = function (inputs, bubble_collection) {
    var self = MB.Object ();

    self.bubbles = bubble_collection;

    self.inputs = $.map(inputs, function (i) { return $(i); });
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

        self.bubble.toggle (amazon || january);
        $('p.amazon').toggle(amazon);
        $('p.january-first').toggle(january);
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
        self.bubbles.add ($('#id-packaging_id'), $('div.packaging'));
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
            $('#id-various_artists').prop('checked', true);
        }

        $('div.release-label').each (function () {
            self.addLabel ($(this));
        });

        $('div.release-event').each (function () {
            self.addEvent ($(this));
        });

        $('#id-barcode').on('change', function () {
            var barcode = $(this).val ().replace (/[^0-9]/g, '');
            $(this).val (barcode);
        });

        $('a[href=#add_label]').bind ('click.mb', function (event) {
            self.addLabel ();
            self.bubbles.hideAll ();
            event.preventDefault ();
        });

        $('a[href=#add_event]').bind ('click.mb', function (event) {
            event.preventDefault ();
            event = self.addEvent();
            self.bubbles.hideAll ();
            $("#id-events\\." + event.eventno + "\\.country_id").val('');
        });

        self.artistcredit = MB.Control.ArtistCreditVertical (
            $('input#release-artist'), $('div.artist-credit'), $('input#open-ac')
        );
    };

    self.addLabel = function ($row) {
        var labelno = self.labels.length;
        var l = MB.Control.ReleaseLabel($row, self, labelno);

        self.labels.push (l);

        return l;
    };

    self.addEvent = function ($row) {
        var eventno = self.events.length;
        var l = MB.Control.ReleaseEvent($row, self, eventno, self.bubbles);

        self.events.push (l);

        return l;
    };

    self.submit = function () {
        // always submit disabled inputs.
        $('input:disabled').prop('disabled', false);
    };

    self.release_group = MB.Control.ReleaseGroup (action, self);
    self.barcode = MB.Control.ReleaseBarcode ();
    self.labels = [];
    self.events = [];

    self.initialize ();

    $('form.release-editor').bind ('submit.mb', self.submit);

    return self;
}

/**
 * MB.Control.ReleaseEvent keeps track of the country/date inputs.
 */
MB.Control.ReleaseEvent = function($row, parent, eventno, bubble_collection) {
    var self = MB.Object();

    self.$row = $row;
    self.parent = parent;
    self.eventno = eventno;

    if (!self.$row)
    {
        $('div.catno-container:first').clone ().hide ()
            .insertAfter ($('div.catno-container:last'));

        self.$row = $('div.release-event:first').clone ();
        self.$row.find ('input').val('');

        self.$row.find ('*').each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').
                           replace('events.0', "events." + self.eventno));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').
                           replace('events.0', "events." + self.eventno));
            }
        });

        self.$row.insertAfter ($('div.release-event:last'));
        self.$row.find ('span.remove-event input').val ('0');
        self.$row.show ();
    }

    MB.Control.ReleaseDate(self.$row.find('span.partial-date input'),
                          bubble_collection);

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

    self.$deleted = self.$row.find ('span.remove-event input');

    self.$row.find ("a[href=#remove_event]").click (function () { self.markDeleted() });

    if (self.isDeleted ())
    {
        // if the event is marked as deleted, make sure it is displayed as such
        // after page load.
        self.markDeleted ();
    }

    return self;
};

