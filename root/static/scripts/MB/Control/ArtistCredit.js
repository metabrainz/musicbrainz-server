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

MB.Control.ArtistCredit = function(obj, box, parent) {
    var self = MB.Object();

    self.template = MB.utility.template(
        '<tr class="artist-credit-box">' +
            '<td class="link">' +
            '  <a href="/" tabindex="-1">&nbsp;</a>' +
            '</td>' +
            '<td class="artist">' +
            '  <input type="text" class="name"></input>' +
            '  <input type="hidden" class="gid"></input>' +
            '  <input id="id-#{name}.artist_id" name="#{name}.artist_id" type="hidden" class="id" />' +
            '</td>' +
            '<td class="artistcredit">' +
            '  <input id="id-#{name}.name" name="#{name}.name" type="text" class="credit" />' +
            '</td>' +
            '<td class="joinphrase">' +
            '  <input id="id-#{name}.join_phrase" name="#{name}.join_phrase" type="text" class="join" />' +
            '</td>' +
        '</div>'
    );

    self.parent = parent;

    if (obj === null)
    {
        self.row = $(self.template.draw({
            "name": self.parent.prefix + ".names." + box
        }));
    }
    else
    {
        self.row = obj;
    }

    self.box = box;
    self.name = self.row.find ('input.name');
    self.credit = self.row.find ('input.credit');
    self.join = self.row.find ('input.join');
    self.gid = self.row.find ('input.gid');
    self.id = self.row.find ('input.id');
    self.link = self.row.find ('a');

    var joinChanged = function(event) {
        if (self.join.val() === "")
            return;

        self.parent.addArtistBox(self.box + 1);
    };

    var joinBlurred = function(event) {
        self.parent.renderPreview();
    };

    var nameBlurred = function(event) {
        /* mark the field as having an error if no lookup was
         * performed for this artist name. */
        if (self.name.val() !== "" && self.id.val() === "")
        {
            self.name.addClass('error');
        }

        self.parent.renderPreview();
    };

    var creditBlurred = function(event) {
        if (self.credit.val() === "")
            return;

        self.parent.addArtistBox(self.box + 1);
        self.parent.renderPreview();
    };

    var update = function(event, data) {
        self.name.val(data.name).removeClass('error');
        self.gid.val(data.gid);
        self.id.val(data.id);
        self.link.html ('link').
            attr('href', '/artist/'+data.gid).
            attr('title', data.comment);

        if (self.credit.val () === '')
        {
            self.credit.val (data.name);
        }

        self.parent.renderPreview();

        event.preventDefault();
        return false;
    };

    self.joinChanged = joinChanged;
    self.joinBlurred = joinBlurred;
    self.nameBlurred = nameBlurred;
    self.creditBlurred = creditBlurred;
    self.update = update;

//     self.join.bind('change keyup', self.joinChanged);
    self.join.bind('blur', self.joinBlurred);
    self.name.bind('blur', self.nameBlurred);
    self.credit.bind('blur', self.creditBlurred);

    self.name.result(self.update);
    self.name.autocomplete("/ws/js/artist", MB.utility.autocomplete.options);

    return self;
}

/* an ArtistCreditRow is a container for all the artist credits on a track. */
MB.Control.ArtistCreditRow = function(row, acrow) {
    var self = MB.Object();

    self.box = [];
    self.acrow = acrow;
    self.track_input = row.find ("td.artist input");

    var identify = function() {
        var id = self.acrow.find ('input.credit').eq(0).attr ('id');

        if (id === "id-artist_credit.names.0.artist_id")
        {
            self.prefix = "artist_credit";
            self.medium = -1;
            self.track = -1;
        }
        else
        {
            var matches = id.match(/mediums\.(\d+)\.tracklist\.tracks\.(\d+)\.artist_credit/);
            self.prefix = matches[0];
            self.medium = matches[1];
            self.track = matches[2];
        }
    };

    var initialize = function() {
        self.identify ();

        self.acrow.find('tr.artist-credit-box').each(function(i) {
            self.box[i] = MB.Control.ArtistCredit($(this), i, self);
        });

        self.track_input.autocomplete("/ws/js/artist", MB.utility.autocomplete.options);
        self.track_input.result(self.update);
        self.track_input.focus(function(event) {
            $('tr.artist-credit-row').not(self.acrow).hide();
            self.acrow.show();
        });

        /* always add an empty box when first initializing an artist credit row. */
        self.addArtistBox (self.box.length);
        self.acrow.hide ();
    };

    var update = function(event, data) {
        self.box[0].update(event, data);
    };

    var addArtistBox = function(i) {
        if (self.box[i]) {
            return;
        }

        self.box[i] = MB.Control.ArtistCredit(null, i, self);
        self.box[i].row.appendTo(self.acrow.find ('table.artist-credit tbody'));

        return self.box[i];
    };

    var copyArtist = function(artist) {
        $.each (artist.box, function (index, src) {
            dst = self.addArtistBox(index);
            dst.name.val(src.name.val());
            dst.join.val(src.join.val());
            dst.gid.val(src.gid.val());
            dst.id.val(src.id.val());
            dst.link.html(src.link.html());
            dst.link.attr('href', src.link.attr('href'));
            dst.link.attr('title', src.link.attr('title'));
        });

        self.renderPreview();
    };

    var renderPreview = function() {
        var preview = "";

        self.acrow.find ('tr.artist-credit-box').each(function(i, box) {
            preview += $(box).find('input.credit').val() + $(box).find('input.join').val();
        });

        self.track_input.val(preview);
    };

    self.identify = identify;
    self.initialize = initialize;
    self.update = update;
    self.addArtistBox = addArtistBox;
    self.copyArtist = copyArtist;
    self.renderPreview = renderPreview;

    self.initialize();

    return self;
};
