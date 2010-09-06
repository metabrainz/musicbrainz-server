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

MB.Control.ReleaseRecordingsTrack = function (disc, track, row) {
    var self = MB.Object ();

    self.row = $(row);
    self.container = $('#select-recording-'+disc+'-'+track);
    self.radioname = 'select-recording-'+disc+'-'+track;

    self.link = self.row.find ('span.recording');
    self.gid = self.row.find ('input.gid');
    self.artist = self.row.next ().find ('span.recording-artist');
    self.use_recording = self.row.next ().andSelf ().find ('span.recording');
    self.add_recording = self.row.find ('span.add-recording');

    self.search = self.container.find ('input.recording');
    self.matches = self.container.find ('table.matches tbody');
    self.separator = self.matches.find ('tr.separator');

    var query = function (value) {

        if (value === '')
        {
            return false;
        }

        var artistname = self.row.next ().find ('.track-artist').text ();

        return {
            url: '/ws/js/recording', 
            data: { q: value, a: artistname },
        };
    };

    var renderMatches = function(data) {
        self.matches.find ('tr.clientmatch').remove ();

        if (data.length === 0)
        {
            self.matches.find ('tr.servermatch').show ();
            return;
        }

        self.matches.find ('tr.servermatch').hide ();

        var rec = MB.utility.template (
            '    <tr class="clientmatch recordingmatch">' +
                '  <td class="select">' +
                '    <input type="radio" name="' + self.radioname + '" class="recordingmatch" />' +
                '  </td>' +
                '  <td class="recording">' +
                '    <input type="hidden" class="gid" value="#{gid}" />' +
                '    <a href="/recording/#{gid}">#{name}</a>' +
                '  </td>' +
                '  <td class="artist">#{artist}</td>' +
                '  <td class="length">#{length}</td>' +
                '</tr>' +
                '<tr class="clientmatch releaselist">' +
                '  <td> </td>' +
                '  <td colspan="3">' + MB.text.AppearsOn + ' #{releasegroups}</td>' +
                '</tr>'
        );

        var rg = MB.utility.template ('<a href="/release-group/#{gid}">#{name}</a>');

        $.each (data, function (i, result) {

            var releasegroups = [];
            $.each (result.releasegroups, function (idx, item) {
                releasegroups.push (rg.draw (item));
            });

            result.releasegroups = releasegroups.join (", ");

            var html = rec.draw (result);

            $(html).insertBefore (self.separator);
        });

        self.matches.find ('tr.clientmatch input.recordingmatch').change (self.select);
    };

    var select = function(event) {
        var row = $(this).closest ('tr');

        if (row.hasClass ('addnew'))
        {
            self.gid.val ('');
            self.add_recording.show ();
            self.use_recording.hide ();
        }
        else
        {
            row.find ('td.recording a').clone ().appendTo (self.link.empty ());

            self.gid.val (row.find ('input.gid').val ());
            self.artist.text (row.find ('td.artist').text ());

            self.use_recording.show ();
            self.add_recording.hide ();
        }
    };

    var initialize = function() {
        self.autocomplete = MB.utility.AutoComplete (
            self.search, self.query, self.renderMatches);

        self.container.find ('a[href=#cancel-search]').click (function (event) {
            $(this).prev('input').val ('');
            self.renderMatches ([]);
        });

        self.matches.find ('tr.servermatch input.recordingmatch').change (self.select);
        self.matches.find ('tr.addnew input.newrecording').change (self.select);
    };

    self.query = query;
    self.renderMatches = renderMatches;
    self.select = select;
    self.initialize = initialize;

    self.initialize ();

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
        self.discs.push (MB.Control.ReleaseRecordingsDisc (idx, disc));
    });

    MB.Control.BubbleCollection ($('a.change-recording'), $('div.select-recording'));

    return self;
};
