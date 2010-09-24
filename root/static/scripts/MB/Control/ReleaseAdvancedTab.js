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

// FIXME: move the following to constants?
MB.Control._disabled_colour = '#AAA';

// FIXME: hardcoded static url in this template. --warp.
MB.Control.track_template = MB.utility.template (
    '<tr class="track">' +
        '<td class="position">' +
        '  <input class="pos" id="id-#{tracklist}.#{trackno}.position"' +
        '         name="#{tracklist}.#{trackno}.position" value="#{position}" type="text">' +
        '</td>' +
        '<td class="title">' +
        '  <input id="id-#{tracklist}.#{trackno}.id" name="#{tracklist}.#{trackno}.id" value="" type="hidden">' +
        '  <input id="id-#{tracklist}.#{trackno}.name" name="#{tracklist}.#{trackno}.name" value="" type="text" class="track-name" >' +
        '</td>' +
        '<td class="artist"></td>' +
        '<td class="length">' +
        '  <input class="track-length" id="id-#{tracklist}.#{trackno}.length" name="#{tracklist}.#{trackno}.length" size="5" value="?:??" type="text">' +
        '</td>' +
        '<td class="delete">'+
        '  <input type="hidden" value="0" name="#{tracklist}.#{trackno}.deleted" id="id-#{tracklist}.#{trackno}.deleted" />' +
        '  <a class="disc-remove-track" href="#remove_track">' +
        '    <img src="/static/images/release_editor/remove-track.png" title="Remove Track" />' +
        '  </a>' +
        '</td>' +
    '</tr>');


MB.Control.ReleaseTrack = function (track, artistcredit) {
    var self = MB.Object ();

    self.row = track;
    self.acrow = artistcredit;

    self.position = track.find ('td.position input');
    self.title = track.find ('td.title input.track-name');
    self.id = track.find ('td.title input[type=hidden]');
    self.preview = track.find ('td.artist input.artist-credit-preview');
    self.length = track.find ('td.length input');
    self.deleted = track.find ('td.delete input');

    /**
     * render enters the supplied data into the form fields for this track.
     */
    var render = function (data) {
        self.position.val (data.position);
        self.title.val (data.title);
        self.id.val (data.id);
        self.preview.val (data.preview);
        self.length.val (data.length);
        self.deleted.val (data.deleted);
        if (data.artist)
        {
            self.preview.val (data.artist.preview);
        }

        if (data.deleted)
        {
            self.row.addClass ('deleted');
        }
        else
        {
            self.row.removeClass ('deleted');
        }

        return self;
    };

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
        }
        else
        {
            self.deleted.val ('0');
            self.row.removeClass('deleted');
        }
        var trackpos = 1;

        self.row.closest ('tbody').find ('tr.track').each (
            function (idx, elem) {
                $(elem).find('input.pos').val (trackpos);
                if (! $(elem).hasClass ('deleted'))
                {
                    trackpos += 1;
                }
            }
        );
    };

    /**
     * isDeleted returns true if this track is marked for deletion.
     */
    var isDeleted = function () {
        return self.deleted.val () === '1';
    };


    /**
     * remove removes the associated inputs and table rows.
     */
    var remove = function () {
        self.row.remove ();
        self.acrow.remove ();
    };
    
    self.render = render;
    self.toggleDelete = toggleDelete;
    self.isDeleted = isDeleted;
    self.remove = remove;

    self.row.find ("a[href=#remove_track]").click (function () { self.toggleDelete() });
    self.artist_credit = MB.Control.ArtistCreditRow (self.row, self.acrow);

    if (self.isDeleted ())
    {
        self.row.addClass('deleted');
    }

    return self;
};

MB.Control.ReleaseDisc = function (disc) {
    var self = MB.Object ();

    /**
     * fullTitle returns the disc title prefixed with 'Disc #: '.  Or just
     * 'Disc #' if the disc doesn't have a title.
     */
    var fullTitle = function () {
        var title = '';
        if (!self.title.hasClass ('jquery_placeholder'))
        {
            title = self.title.val ();
        }

        return 'Disc ' + (self.number + 1) + (title ? ': '+title : '');
    };

    /**
     * addTrack renders new tr.track and tr.track-artist-credit rows in the
     * tracklist table.  It copies the release artistcredit.
     */
    var addTrack = function (event) {
        var trackno = self.tracks.length;

        var previous = self.table.find ('tr.track').last ();

        /* render tr.track. */
        self.table.append (MB.Control.track_template.draw ({
                tracklist: 'mediums.'+self.number+'.tracklist.tracks',
                trackno: trackno,
                position: trackno + 1,
        }));

        var row = self.table.find ('tr.track').last ();

        /* set artist credit preview in tr.track. */
        newartist = row.find ('td.artist');
        newartist.append ($('div#release-artist > input').clone ());

        var preview = newartist.find ('.artist-credit-preview');
        if (previous)
        {
            var prev_preview = previous.find ('.artist-credit-preview');
            preview.attr ('disabled', prev_preview.attr ('disabled'));
            preview.css ('color', prev_preview.css ('color'));
        }
        else
        {
            preview.attr ('disabled', 'disabled');
            preview.css ('color', MB.Control._disabled_colour);
        }

        /* render tr.track-artist-credit. */
        var acrow = $('<tr class="track-artist-credit">').
            append ($('<td colspan="5">').
                    append ($('div#release-artist div.ac-balloon0').clone ()).
                    append ($('div#release-artist table.artist-credit').clone ()));

        acrow.insertAfter (row);

        /* update the ids for both artist credit and artist credit preview. */
        var trackprefix = 'mediums.'+self.number+'.tracklist.tracks.'+trackno+'.';
        var replace_ids = function (idx, element) {
            var item = $(element);
            item.attr ('id', 'id-' + trackprefix + item.attr('name'));
            item.attr ('name', trackprefix + item.attr('name'));
        };

        newartist.find('*').each (replace_ids);
        acrow.find ('*').each (replace_ids);

        self.tracks.push (MB.Control.ReleaseTrack (row, acrow));
        self.sorted_tracks.push (self.tracks[self.tracks.length - 1]);

        if (event !== undefined)
        {
            /* and scroll down to the new position of the 'Add Track' button if possible. */
            $('html').animate({'scrollTop': $('html').scrollTop () + row.height ()}, 100);
        }
    };

    /**
     * getTrack merely returns the track from self.tracks if the track
     * exists.  If the track does not exist yet getTrack will
     * repeatedly call addTrack until it does.
     */
    var getTrack = function (idx) {
        while (idx >= self.tracks.length)
        {
            self.addTrack ();
        }

        return self.tracks[idx];
    };

    /**
     * removeTracks removes all table rows for unused track positions.  It expects
     * the position of the lastused track as input.
     */
    var removeTracks = function (lastused) {
        while (lastused + 1 < self.tracks.length)
        {
            self.tracks.pop ().remove ();
        }
    };

    /**
     * sort sorts all the table rows by the 'position' input.
     */
    var sort = function () {
        self.sorted_tracks = [];
        $.each (self.tracks, function (idx, item) { self.sorted_tracks.push (item); });

        self.sorted_tracks.sort (function (a, b) {
            return parseInt (a.position.val ()) - parseInt (b.position.val ());
        });

        $.each (self.sorted_tracks, function (idx, track) {
            if (idx)
            {
                track.row.insertAfter (self.sorted_tracks[idx-1].acrow);
                track.acrow.insertAfter (track.row);
            }
        });
    };

    /**
     * updateArtistColumn makes sure the enabled/disabled state of each of the artist
     * inputs matches the checkbox at the top of the column.
     */
    var updateArtistColumn = function () {
        var artists = self.table.find ('tr.track td.artist input');
        if (self.artist_column_checkbox.filter(':checked').val ())
        {
            artists.removeAttr('disabled').css('color', 'inherit');
        }
        else
        {
            artists.attr('disabled','disabled').css('color', MB.Control._disabled_colour);
            MB.Control.artist_credit_hide_rows (self.table);
        }
    };

    self.fieldset = disc;
    self.table = self.fieldset.find ('table.medium');
    self.artist_column_checkbox = self.table.find ('th.artist input');

    self.number = parseInt (self.fieldset.find ('input.tracklist-id').attr ('id').
                            match ('id-mediums\.([0-9])\.tracklist')[1]);

    self.tracks = [];
    self.sorted_tracks = [];

    /* the title and format inputs move between the fieldset and the textareas
     * of the basic view.  Therefore we cannot rely on them being children of
     * self.fieldset, and we need to find them based on their id attribute. */
    self.title = $('#id-mediums\\.'+self.number+'\\.name');
    self.format_id = $('#id-mediums\\.'+self.number+'\\.format_id');

    self.fieldset.find ('table.medium tbody tr.track').each (function (idx, item) {
        self.tracks.push (
            MB.Control.ReleaseTrack ($(item), $(item).next('tr.track-artist-credit'))
        );
    });

    self.fullTitle = fullTitle;
    self.addTrack = addTrack;
    self.getTrack = getTrack;
    self.removeTracks = removeTracks;
    self.sort = sort;
    self.updateArtistColumn = updateArtistColumn;

    $("#mediums\\."+self.number+"\\.add_track").click(self.addTrack);
    self.artist_column_checkbox.bind ('change', self.updateArtistColumn);

    self.updateArtistColumn ();
    self.sort ();

    return self;
};

MB.Control.ReleaseAdvancedTab = function () {
    var self = MB.Object ();

    var addDisc = function () {
        var discs = self.discs.length;
        var lastdisc_bas = $('.basic-disc').last ();
        var lastdisc_adv = $('.advanced-disc').last ();

        var newdisc_bas = lastdisc_bas.clone ().insertAfter (lastdisc_bas);
        var newdisc_adv = lastdisc_adv.clone ().insertAfter (lastdisc_adv);

        newdisc_adv.find ('tbody').empty ();

        var h3 = newdisc_bas.find ("h3");
        h3.text (h3.text ().replace (/[0-9]+/, discs + 1));

        var legend = newdisc_adv.find ("legend");
        legend.text (legend.text ().replace (/[0-9]+/, discs + 1));

        var mediumid = new RegExp ("mediums.[0-9]+");
        var update_ids = function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').replace(mediumid, "mediums."+discs));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').replace(mediumid, "mediums."+discs));
            }
        };

        newdisc_bas.find ("*").each (update_ids);
        newdisc_adv.find ("*").each (update_ids);

        /* clear the cloned rowid for this medium and tracklist, so a
         * new medium and tracklist will be created. */
        $("#id-mediums\\."+discs+"\\.id").val('');
        $("#id-mediums\\."+discs+"\\.position").val(discs + 1);
        $("#id-mediums\\."+discs+"\\.tracklist\\.id").val('');
        $('#id-mediums\\.'+discs+'\\.tracklist\\.serialized').val('[]');

        newdisc_bas.find ('textarea').empty ();

        var new_disc = MB.Control.ReleaseDisc (newdisc_adv, self);

        self.discs.push (new_disc);

        /* and scroll down to the new position of the 'Add Disc' button if possible. */
        /* FIXME: this hardcodes the fieldset bottom margin, shouldn't do that. */
        var newpos = lastdisc_adv.height () ? lastdisc_adv.height () + 12 : lastdisc_bas.height ();
        $('html').animate({ scrollTop: $('html').scrollTop () + newpos }, 500);

        return new_disc;
    };

    self.tab = $('div.advanced-tracklist');
    self.discs = [];
    self.addDisc = addDisc;

    self.tab.find ('fieldset.advanced-disc').each (function (idx, item) {
        self.discs.push (MB.Control.ReleaseDisc ($(item)));
    });

    $('form').bind ('submit', function () {
        self.tab.find ('tr.track td.artist input').removeAttr('disabled');
    });

    return self;
};