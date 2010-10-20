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

MB.Control.ArtistCredit = function(obj, boxnumber, container) {
    var self = MB.Object();

    self.container = container;

    if (obj === null)
    {
        self.row = self.container.box[boxnumber - 1].row.clone ();

        var nameid = new RegExp ("artist_credit.names.[0-9]+");
        self.row.find ("*").each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').
                           replace(nameid, "artist_credit.names." + boxnumber));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').
                           replace(nameid, "artist_credit.names." + boxnumber));
            }
        });
    }
    else
    {
        self.row = obj;
    }

    self.boxnumber = boxnumber;
    self.name = self.row.find ('input.name');
    self.credit = self.row.find ('input.credit');
    self.join = self.row.find ('input.join');
    self.gid = self.row.find ('input.gid');
    self.id = self.row.find ('input.id');
    self.link = self.row.find ('a');

    var clear = function () {
        self.name.val ('');
        self.credit.val ('');
        self.join.val ('');
        self.gid.val ('');
        self.id.val ('');
        self.link.val ('');
        self.link.html ('');
    };

    var render = function (data) {

        self.name.val(data.name).removeClass('error');
        self.join.val(data.join);
        self.credit.val (data.credit);
        self.gid.val(data.gid);
        self.link.html ('link').
            attr('href', '/artist/'+data.gid).
            attr('title', data.comment);

        if (self.credit.val () === '')
        {
            self.credit.val (data.name);
        }

    };

    var update = function(event, data) {
        if (data.name)
        {
            self.render (data);
            self.container.renderPreview();
        }

        event.preventDefault();
        return false;
    };

    var joinBlurred = function(event) {
        self.container.renderPreview();
    };

    var nameBlurred = function(event) {
        /* mark the field as having an error if no lookup was
         * performed for this artist name. */
        if (self.name.val() !== "" && self.id.val() === "")
        {
            self.name.addClass('error');
        }

        self.container.renderPreview();
    };

    var creditBlurred = function(event) {
        if (self.credit.val() === "")
            return;

        self.container.addArtistBox(self.boxnumber + 1);
        self.container.renderPreview();
    };

    var isEmpty = function () {
        return (self.name.val () === '' &&
                self.credit.val () === '' &&
                self.join.val () === '');
    };

    self.clear = clear;
    self.render = render;
    self.update = update;
    self.joinBlurred = joinBlurred;
    self.nameBlurred = nameBlurred;
    self.creditBlurred = creditBlurred;
    self.isEmpty = isEmpty;

    self.join.bind('blur', self.joinBlurred);
    self.name.bind('blur', self.nameBlurred);
    self.credit.bind('blur', self.creditBlurred);

    MB.Control.Autocomplete ({
        'input': self.name,
        'entity': 'artist',
        'select': self.update,
    });

    if (obj === null)
    {
        /* we need to empty some variables if we created a new artist
         * credit by cloning the previous artist. */
        self.clear ();
    }

    return self;
}

/* an ArtistCreditContainer is the base container for all the artist credits 
   on a track or the release. */
MB.Control.ArtistCreditContainer = function(input, artistcredits) {
    var self = MB.Object();

    self.box = [];
    self.artistcredits = artistcredits;
    self.artist_input = input;

    var initialize = function() {

        self.artistcredits.find('.artist-credit-box').each(function(i) {
            self.box[i] = MB.Control.ArtistCredit($(this), i, self);
        });

        if (self.box.length == 0)
        {
            throw MB.utility.exception (
                'ArtistCreditBoxNotFound',
                'Atleast one div.artist-credit-box is required, none were found.');
        }

        MB.Control.Autocomplete ({
            'input': self.artist_input,
            'entity': 'artist',
            'select': self.update,
        });

        if (! self.box[self.box.length - 1].isEmpty ())
        {
            /* always add an empty box when there isn't one. */
            self.addArtistBox (self.box.length);
        }
    };

    var update = function(event, data) {
        event.preventDefault();
        self.box[0].update(event, data);
    };

    var addArtistBox = function(i) {
        if (self.box[i]) {
            return self.box[i];
        }

        self.box[i] = MB.Control.ArtistCredit(null, i, self);
        self.box[i].row.insertAfter (self.box[i-1].row);

        return self.box[i];
    };

    var renderPreview = function() {
        var preview = "";

        self.artistcredits.find ('.artist-credit-box').each(function(i, box) {
            preview += $(box).find('input.credit').val() + $(box).find('input.join').val();
        });

        self.artist_input.val(preview);
    };

    var render = function (data) {
        $.each (data.names, function (idx, item) {

            var box = self.addArtistBox (idx);
            box.render (item);
        });

        self.renderPreview ();
    };

    var isVariousArtists = function () {
        return self.box[0].gid.val () === MB.constants.VARTIST_GID;
    };

    var clear = function () {
        $.each (self.box, function (idx, item) {
            item.clear ();
        });

        self.renderPreview ();
    };

    self.initialize = initialize;
    self.update = update;
    self.addArtistBox = addArtistBox;
    self.renderPreview = renderPreview;
    self.render = render;
    self.isVariousArtists = isVariousArtists;
    self.clear = clear;

    self.initialize ();

    return self;
};

MB.Control.artist_credit_hide_rows = function (parent) {
    parent.find ('tr.track-artist-credit').hide();
}

/* an ArtistCreditRow is the container for all the artist credits on a track. */
MB.Control.ArtistCreditRow = function (row, acrow) {
    var self = MB.Control.ArtistCreditContainer (row.find ("td.artist input"), acrow);

    var initialize = function () {
        self.artist_input.focus(function(event) {
            $('tr.track-artist-credit').not(self.artistcredits).hide();

            self.artistcredits.show ();
        });
    };

    self.initialize = initialize;

    self.initialize ();

    return self;
};

/* ArtistCreditVertical is the container for all the artist credits on the
   release (which appears on the information page).  It is currently identical
   to a plain container. */
MB.Control.ArtistCreditVertical = MB.Control.ArtistCreditContainer;

