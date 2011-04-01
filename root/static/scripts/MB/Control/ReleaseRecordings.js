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

    self.renderReleaseGroups = function ($target, gid, rgs) {

        $target.empty ();

        var first = true;
        $.each (rgs.results, function (idx, item) {
            var a;

            if (first)
            {
                first = false;
            }
            else
            {
                $target.append (", ");
            }

            a = '<a target="_blank" href="/release-group/' + item.gid +
                '">' + MB.utility.escapeHTML (item.name) + '</a>';

            $target.append ($(a));
        });

        if (rgs.hits > rgs.results.length)
        {
            $target.append (
                $('<a target="_blank" href="/recording/' + gid + '/">...</a>'));
        }

        return rgs.results.length;
    };

    self.selected = function (event, data) {
        self.$name.text (data.name);
        self.$name.attr ('href', '/recording/' + data.gid);
        self.$gid.val (data.gid);
        self.$artist.text (data.artist);
        self.$length.text (data.length);
        self.renderReleaseGroups (self.$appears, data.gid, data.appears_on);

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

    self.lookupHook = function (request) {

        $.extend (request.data, { 'a': self.artistname });

        return request;
    };

    MB.Control.Autocomplete ({
        'entity': 'recording',
        'input': self.$search,
        'select': self.selected,
        'lookupHook': self.lookupHook
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
            self.$gid.val ('new');
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

    var artistname = $.trim (self.$row.next ().find ('.track-artist').text ());
    self.select = MB.Control.ReleaseRecordingsSelect ($container, artistname, change);

    return self;
};

MB.Control.ReleaseRecordingsDisc = function (parent, disc, fieldset) {
    var self = MB.Object ();

    self.parent = parent;
    self.tracks = [];
    self.$fieldset = $(fieldset);
    self.$edit = self.$fieldset.find ('a[href=#edit]');
    self.$nowloading = self.$fieldset.find ('div.recordings-loading');

    self.renderTrack = function (idx, $track, $bubble, data) {

        /* track. */
        $track.find ('.position').text (idx + 1);
        $track.find ('.name').text (data.name);
        $track.find ('.track-artist').text (data.artist_credit.preview);

        /* search bubble. */
        self.parent.addBubble ($track.find ('.change-recording'), $bubble.find ('div.select-recording'));

        $bubble.find ('tr.servermatch.recordingmatch').show ();
        $bubble.find ('tr.servermatch a.name').text (data.recording.name)
            .attr ('href', '/recording/' + data.recording.gid);

        $bubble.find ('tr.servermatch input.gid').val (data.recording.gid);
        $bubble.find ('tr.servermatch td.artist').text (data.recording.artist_credit.preview);
        $bubble.find ('tr.servermatch td.length').text (data.length);

        if (data.recording.comment)
        {
            $bubble.find ('tr.servermatch span.comment').text (data.recording.comment);
            $bubble.find ('tr.servermatch.comment').show ();
        }

        $bubble.find ('input.recording').val (data.recording.name);
    };

    self.load = function (data) {
        self.$nowloading.hide ();

        var $table = $('table.disc-template').clone ().show ()
            .appendTo (self.$fieldset);

        var $track_templates = $table.find ('tr.track.template').next ('tr.template').andSelf ();
        var $select_template = $('div.select-recording-container.template');

        $.each (data, function (idx, trk) {
            var $track = $track_templates.clone ().appendTo ($table);
            var $bubble = $select_template.clone ().insertAfter ($select_template);
            self.renderTrack (idx, $track, $bubble, trk);

            var name = 'rec_mediums.'+disc+'.associations.'+idx+'.gid';
            $track.find ('input.gid').attr ('name', name);

            var id = 'select-recording-'+disc+'-'+idx;
            $bubble.attr ('id', id).find ('input.recordingmatch').attr ('name', id);
            $track.removeClass ('template');
            $bubble.removeClass ('template');

            var rr_track = MB.Control.ReleaseRecordingsTrack (disc, idx, $track.eq(0));
            self.tracks.push (rr_track);

            var appears = rr_track.select.renderReleaseGroups (
                $bubble.find ('tr.servermatch span.appears'),
                trk.recording.gid, trk.recording.appears_on);

            if (appears)
            {
                $bubble.find ('tr.servermatch.releaselist').show ();
            }

            $bubble.find ('input.servermatch').attr ('checked', true).trigger ('change');
        });

        $track_templates.remove ();
    };

    self.lazyLoad = function () {
        var tracklist = self.$fieldset.find ('input.tracklist-id').val ();
        self.$fieldset.find ('.clickedit').hide ();
        self.$nowloading.show ();
        $.getJSON ('/ws/js/associations/' + tracklist, self.load);
    };

    self.initializeTracks = function () {
        self.$fieldset.find ('tr.track').each (function (idx, row) {
            self.tracks.push (MB.Control.ReleaseRecordingsTrack (disc, idx, row));
        });
    };

    if (self.$edit.length)
    {
        self.$edit.bind ('click.mb', self.lazyLoad);
    }
    else
    {
        self.initializeTracks ();
    }

    return self;
};

MB.Control.ReleaseRecordings = function () {
    var self = MB.Object ();

    self.discs = [];
    self.bc = MB.Control.BubbleCollection ();

    self.addBubble = function ($targets, $containers) {
        self.bc.add ($targets, $containers);

        $containers.each (function (idx, elem) {
            $(elem).bind ('bubbleOpen.mb', function (event) {
                $targets.eq (idx)
                    .text (MB.text.Done)
                    .removeClass ('negative')
                    .closest ('tr').find ('input.confirmed').val ("1");
            });

            $(elem).bind ('bubbleClose.mb', function (event) {
                $targets.eq (idx).text (MB.text.Change);
            });
        });
    };

    $('fieldset.recording-assoc-disc').each (function (idx, disc) {
        var discno = $(disc).attr ('id').replace ('recording-assoc-disc-', '');

        self.discs.push (MB.Control.ReleaseRecordingsDisc (self, discno, disc));
    });

    var $targets = $('tr.track:not(.template) .change-recording');
    var $containers = $('div.select-recording-container:not(.template) div.select-recording');

    self.addBubble ($targets, $containers);

    return self;
};
