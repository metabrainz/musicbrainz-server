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

MB.Control.ReleaseRecordingsSelect = function ($container, artistname, callback) {
    var self = MB.Object ();

    self.$container = $container;
    self.artistname = artistname;

    self.$search = self.$container.find ('input.recording');
    self.$radio = self.$container.find ('input.clientmatch');

    self.$name = self.$container.find ('tr.clientmatch a.name');
    self.$gid = self.$container.find ('tr.clientmatch input.gid');
    self.$artist = self.$container.find ('tr.clientmatch td.artist');
    self.$length = self.$container.find ('tr.clientmatch td.length');
    self.$appears = self.$container.find ('tr.clientmatch span.appears');
    self.$comment = self.$container.find ('tr.clientmatch span.comment');

    var render_release_groups = function ($target, rgs) {

        $target.empty ();

        var first = true;
        $.each (rgs, function (idx, item) {

            if (first)
            {
                first = false;
            }
            else
            {
                $target.append (", ");
            }

            var a = '<a href="/release-group/' + item.gid + '">' + item.name + '</a>';
            $target.append ($(a));
        });
    };

    var selected = function (event, data) {
        self.$name.text (data.name);
        self.$name.attr ('href', '/recording/' + data.gid);
        self.$gid.val (data.gid);
        self.$artist.text (data.artist);
        self.$length.text (data.length);
        render_release_groups (self.$appears, data.releasegroups);

        self.$container.find ('tr.clientmatch').show ();

        if (data.comment)
        {
            self.$comment.text (data.comment);
            self.$comment.closest ('tr').show ();
        }
        else
        {
            self.$comment.closest ('tr').hide ();
        }

        self.$radio.attr ('checked', true);
        self.$radio.trigger ('change');
    };

    var formatItem = function (ul, item) {
        var a = $("<a>").text (item.name);

        a.append (' - <span class="autocomplete-artist">' + item.artist + '</span>');

        if (item.releasegroups)
        {
            var rgs = {};
            /* don't display the same name multiple times. */
            $.each (item.releasegroups, function (idx, item) {
                rgs[item.name] = item.name;
            });

            a.append ('<br /><span class="autocomplete-appears">appears on: '
                      + MB.utility.keys (rgs).join (", ") + '</span>');
        }

        if (item.comment)
        {
            a.append ('<br /><span class="autocomplete-comment">(' + item.comment + ')</span>');
        }

        if (item.isrcs.length)
        {
            a.append ('<br /><span class="autocomplete-isrcs">isrcs: '
                      + item.isrcs.join (", ") + '</span>');
        }

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
    };

    var lookupHook = function (request) {

        $.extend (request.data, { 'a': self.artistname });

        return request;
    };

    self.selected = selected;

    MB.Control.Autocomplete ({
        'input': self.$search,
        'entity': 'recording',
        'select': self.selected,
        'formatItem': formatItem,
        'lookupHook': lookupHook
    });

    return self;
};


MB.Control.ReleaseRecordingsTrack = function (disc, track, row) {
    var self = MB.Object ();

    var $container = $('#select-recording-'+disc+'-'+track);

    self.$row = $(row);
    self.$matches = $container.find ('table.matches tbody');

    self.$link = self.$row.find ('span.recording');
    self.$gid = self.$row.find ('input.gid');
    self.$artist = self.$row.next ().find ('span.recording-artist');
    self.$use_recording = self.$row.next ().andSelf ().find ('span.recording');
    self.$add_recording = self.$row.find ('span.add-recording');

    var change = function (event) {
        var $row = $(this).closest ('tr');

        if ($row.hasClass ('addnew'))
        {
            self.$gid.val ('');
            self.$add_recording.show ();
            self.$use_recording.hide ();
        }
        else
        {
            $row.find ('td.recording a').clone ().appendTo (self.$link.empty ());

            self.$gid.val ($row.find ('input.gid').val ());
            self.$artist.text ($row.find ('td.artist').text ());

            self.$use_recording.show ();
            self.$add_recording.hide ();
        }
        
    };

    self.$matches.find ('input.recordingmatch').change (change);

    var artistname = self.$row.next ().find ('.track-artist').text ();
    self.select = MB.Control.ReleaseRecordingsSelect ($container, artistname, change);

    return self;
};

MB.Control.ReleaseRecordingsDisc = function (disc, fieldset) {
    var self = MB.Object ();

    self.tracks = [];

    $(fieldset).find ('tr.track').each (function (idx, row) {
        self.tracks.push (MB.Control.ReleaseRecordingsTrack (disc, idx, row));
    });

    return self;
};

MB.Control.ReleaseRecordings = function () {
    var self = MB.Object ();

    self.discs = [];

    $('fieldset.recording-assoc-disc').each (function (idx, disc) {
        var discno = $(disc).attr ('id').replace ('recording-assoc-disc-', '');

        self.discs.push (MB.Control.ReleaseRecordingsDisc (discno, disc));
    });

    MB.Control.BubbleCollection ($('a.change-recording'), $('div.select-recording'));

    return self;
};
