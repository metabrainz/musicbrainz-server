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

MB.Control.ChangeRecording = function(trackchanges, selectrecording) {
    var self = MB.Object();

    self.trackchanges = trackchanges;
    self.selectrecording = selectrecording;
    self.recordinglookup = selectrecording.find('input.recording');
    self.matches = selectrecording.find('table.matches tbody');


    var initialize = function() {

        self.trackchanges.find ('a.change-recording').click (function (event) {
            $('tr.select-recording').not(self.selectrecording).hide ();
            self.selectrecording.toggle ();
            event.preventDefault ();
        });

        self.selectrecording.find ('a.selectrecording').click (self.selectClick);

        self.autocomplete = MB.utility.AutoComplete (
            self.recordinglookup, self.query, self.renderMatches);
    };

    var selectClick = function (event) {
        var gid = $(this).next('.gid').val ();

        if (gid)
        {
            self.trackchanges.find ('input.gid').val (gid);
            self.trackchanges.find ('span.recording').empty ().append (
                $(this).closest('tr').find('td.name').contents ().clone ());

            self.trackchanges.find ('span.recording').show ();
            self.trackchanges.find ('span.add-recording').hide ();
        }
        else
        {
            self.trackchanges.find ('input.gid').val ('');
            self.trackchanges.find ('span.recording').hide ();
            self.trackchanges.find ('span.add-recording').show ();
        }

        self.selectrecording.hide ();
        event.preventDefault ();
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
            '<tr class="clientmatch recordingmatch">' +
                '<td class="select">' +
                '  <a href="#select" class="selectrecording">select</a>' +
                '  <input type="hidden" class="gid" value="#{gid}" />' +
                '</td>' +
                '<td class="name"><a href="/recording/#{gid}">#{name}</a></td>' +
                '<td class="artist">#{artist}</td>' +
                '<td class="release">#{release}</td>' +
                '<td class="pos">#{trackpos}</td>' +
                '<td class="length">#{length}</td>' +
            '</tr>'
        );

        var extra = MB.utility.template (
            '<tr class="clientmatch recordingmatch">' +
                '<td class="select"> </td>' +
                '<td class="name"> </td>' +
                '<td class="artist"> </td>' +
                '<td class="release">#{release}</td>' +
                '<td class="pos">#{trackpos}</td>' +
                '<td class="length"> </td>' +
            '</tr>'
        );

        $.each (data, function (i, result) {

            $.each (result.releases, function (j, release) {

                $.extend(release, result);
                var html = j ? extra.draw (release) : rec.draw (release);

                $(html).appendTo (self.matches).find (
                    'td.select a').click (self.selectClick);
            });
        });
    };

    var artistname = function () {
        return self.trackchanges.find ('.track-artist').text ();
    };

    var query = function (value) {

        if (value === '')
        {
            return false;
        }

        return {
            url: '/ws/js/recording', 
            data: { q: value, a: artistname () },
        };
    };

    self.initialize = initialize;
    self.selectClick = selectClick;
    self.renderMatches = renderMatches;
    self.query = query;

    self.initialize ();

    return self;
};


MB.Control.ReleasePreviewTrack = function (row) {
    var self = MB.Object ();

    self.row = row;
    self.recording = $(row).next ('tr.select-recording');

    var position = function () {
        return parseInt ($(self.row).find ('td.position span.new').text ());
    };

    var insertAfter = function (previewtrack) {
        $(self.row).insertAfter (previewtrack.recording);
        $(self.recording).insertAfter (self.row);
    };

    self.position = position;
    self.insertAfter = insertAfter;
    self.changerecording = MB.Control.ChangeRecording ($(self.row), $(self.recording));

    return self;
};

MB.Control.ReleasePreviewDisc = function (fieldset) {
    var self = MB.Object ();

    self.table = $(fieldset).find('table.preview-changes');
    self.rows = [];

    var sort = function () {
        self.rows.sort (function (a, b) {
            return a.position () - b.position ();
        });

        $.each (self.rows, function (idx, row) {
            if (idx)
            {
                row.insertAfter (self.rows[idx-1]);
            }
        });
    };

    self.sort = sort;

    self.table.find ('tr.track-changes').each (function (idx, tr) {
        self.rows.push (MB.Control.ReleasePreviewTrack (tr));
    });

    self.sort ();

    return self;
};

MB.Control.ReleasePreview = function () {
    var self = MB.Object ();

    self.discs = [];

    $('fieldset.preview-changes-disc').each (function (idx, disc) {
        self.discs.push (MB.Control.ReleasePreviewDisc (disc));
    });

    return self;
};