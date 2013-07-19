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

    self.$autocomplete = self.$container.find ('span.recording.autocomplete');
    self.$radio = self.$container.find ('input.clientmatch');

    self.$name = self.$container.find ('tr.clientmatch a.name');
    self.$gid = self.$container.find ('tr.clientmatch input.gid');
    self.$artist = self.$container.find ('tr.clientmatch td.artist');
    self.$length = self.$container.find ('tr.clientmatch td.length');
    self.$appears = self.$container.find ('tr.clientmatch span.appears');
    self.$comment = self.$container.find ('tr.clientmatch span.comment');

    self.renderReleaseGroups = function ($target, gid, rgs) {
        if (rgs) {
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
        }
    };

    self.selected = function (event) {

        /* this should come in through the second parameter to the
         * function, but it's getting lost somewhere, and I have not
         * been able to figure out why/where. --warp. */
        var data = self.$autocomplete.find ('input.name').data ('lookup-result');

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
            self.$comment.text ('');
            self.$comment.closest ('tr').hide ();
        }

        self.$radio.prop('checked', true);
        self.$radio.trigger ('change');
    };

    self.lookupHook = function (request) {

        $.extend (request.data, { 'a': self.artistname });

        return request;
    };

    MB.Control.EntityAutocomplete ({
        'inputs': self.$autocomplete,
        'lookupHook': self.lookupHook,
        'show_status': false
    });

    self.$autocomplete.bind ('lookup-performed', self.selected);

    return self;
};


MB.Control.ReleaseRecordingsTrack = function (parent, disc, track, row) {
    var self = MB.Object ();

    self.parent = parent;
    self.$container = $('#select-recording-'+disc+'-'+track);
    self.$row = $(row);
    self.$confirmed = self.$row.find ('input.confirmed');
    self.$matches = self.$container.find ('table.matches tbody');

    self.$link = self.$row.find ('span.recording');
    self.$gid = self.$row.find ('input.gid');
    self.$artist = self.$row.next ().find ('span.recording-artist');
    self.$use_recording = self.$row.next ().addBack ().find ('span.recording');
    self.$add_recording = self.$row.find ('span.add-recording');

    self.$use_suggested = self.$container.find ('button.use-suggested');
    self.$search_recording = self.$container.find ('button.search-recording');
    self.$add_new = self.$container.find ('button.add-new');
    self.$update_recording = self.$row.next().next();

    self.change = function (event, $row) {
        if (! $row)
        {
            $row = $(this).closest ('tr');
        }

        if ($row.hasClass ('addnew'))
        {
            self.$gid.val ('new');
            self.$add_recording.show ();
            self.$use_recording.hide ();
            self.$update_recording.find('span').hide();
        }
        else
        {
            $row.find ('td.recording a').clone ().appendTo (self.$link.empty ());
            self.$link.append(
                MB.html.span(
                    {},
                    ' (' + $row.find ('td.length').text() + ')'
                )
            );
            var comment = $row.nextAll ('.comment:eq(0)').find ('td span.comment').text ();

            if (comment !== '')
            {
                self.$link.append (' <span class="comment">(' + comment + ')</span>');
            }

            self.$gid.val ($row.find ('input.gid').val ());
            self.$artist.text ($row.find ('td.artist').text ());

            self.$use_recording.show ();
            self.$add_recording.hide ();

            self.$update_recording.find('span').show();
        }
    };

    self.confirmed = function () {
        self.$confirmed.val ("1");
        self.$container.find ('div.confirm-recording').hide ();
        self.$container.find ('div.search-recording').show ();
    };

    self.select_first_suggestion = function () {
        var $suggestion_rows = self.$container.find ('tr.servermatch');
        var $rec = $suggestion_rows.eq (0);
        self.$container.find ('input.newrecording').prop('checked', false);
        $suggestion_rows.find ('input.servermatch').prop('checked', false);
        $rec.find ('input.servermatch').prop('checked', true);

        return $rec;
    };

    self.select_add_new_recording = function () {
        var $suggestion_rows = self.$container.find ('tr.servermatch');
        $suggestion_rows.find ('input.servermatch').prop('checked', false);

        return self.$container.find ('input.newrecording')
            .prop('checked', true).closest ('tr');
    };

    self.use_suggested = function (event) {
        self.confirmed ();

        self.change (null, self.select_first_suggestion ());
        self.bubble.hide ();

        event.preventDefault ();
        return false;
    };

    self.search_recording = function (event) {
        self.confirmed ();

        self.change (null, self.select_first_suggestion ());
        self.bubble.hide ();
        self.bubble.show ();

        event.preventDefault ();
        return false;
    };

    self.add_new = function (event) {
        self.confirmed ();

        self.change (null, self.select_add_new_recording ());
        self.bubble.hide ();

        event.preventDefault ();
        return false;
    };

    self.addBubble = function ($target, $container) {
        self.parent.parent.bc.add ($target, $container);

        $container.bind ('bubbleOpen.mb', function (event) {
            if (self.$confirmed.val ())
            {
                $target.text (MB.text.Done).removeClass ('negative');
            }
        });

        $container.bind ('bubbleClose.mb', function (event) {
            if (self.$confirmed.val ())
            {
                $target.text (MB.text.Change).removeClass ('negative');
            }
        });
    };

    self.$use_suggested.bind ('click.mb', self.use_suggested);
    self.$search_recording.bind ('click.mb', self.search_recording);
    self.$add_new.bind ('click.mb', self.add_new);

    self.$matches.find ('input.recordingmatch').bind ('change.mb', self.change);

    var artistname = _.clean (self.$row.next ().find ('.track-artist').text ());
    self.select = MB.Control.ReleaseRecordingsSelect (self.$container, artistname, self.change);

    self.addBubble (
        self.$row.find ('.change-recording'),
        self.$container.find ('div.select-recording'));

    self.bubble = self.$row.find ('.change-recording').data ('bubble');

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
        $track.find ('.length').text('(' + MB.utility.formatTrackLength(data.length) + ')');
        $track.find ('.track-artist').text (data.artist_credit.preview);

        $bubble.find ('tr.servermatch.recordingmatch').show ();
        $bubble.find ('tr.servermatch a.name').text (data.recording.name)
            .attr ('href', '/recording/' + data.recording.gid);

        $bubble.find ('tr.servermatch input.gid').val (data.recording.gid);
        $bubble.find ('tr.servermatch td.artist').text (data.recording.artist_credit.preview);
        $bubble.find ('tr.servermatch td.length').text (MB.utility.formatTrackLength(data.recording.length));

        if (data.recording.comment)
        {
            $bubble.find ('tr.servermatch span.comment').text (data.recording.comment);
            $bubble.find ('tr.servermatch.comment').show ();
        }

        $bubble.find ('input.recording').val (data.recording.name);
    };

    self.load = function (data) {
        self.$nowloading.hide ();

        var $table = $('table.disc-template').clone ().appendTo (self.$fieldset)
            .show ().removeClass ('disc-template');

        var $track_templates = $table.find ('tr.track.template').next ('tr.template').addBack ();
        var $select_template = $('div.select-recording-container.template');

        $.each (data, function (idx, trk) {
            var $track = $track_templates.clone ().appendTo ($table);
            var $bubble = $select_template.clone ().insertAfter ($select_template);
            self.renderTrack (idx, $track, $bubble, trk);

            var name_prefix = 'rec_mediums.'+disc+'.associations.'+idx;
            $track.find ('input.gid').attr ('name', name_prefix + '.gid');
            $track.find ('input.confirmed').attr ('name', name_prefix + '.confirmed');
            $track.find ('input.edit_sha1').attr ('name', name_prefix + '.edit_sha1')
                .val (trk.edit_sha1);

            var id = 'select-recording-'+disc+'-'+idx;
            $bubble.attr ('id', id).find ('input.recordingmatch').attr ('name', id);
            $track.removeClass ('template');
            $bubble.removeClass ('template');

            var rr_track = MB.Control.ReleaseRecordingsTrack (self, disc, idx, $track.eq(0));
            self.tracks.push (rr_track);

            var appears = rr_track.select.renderReleaseGroups (
                $bubble.find ('tr.servermatch span.appears'),
                trk.recording.gid, trk.recording.appears_on);

            if (appears)
            {
                $bubble.find ('tr.servermatch.releaselist').show ();
            }

            $bubble.find ('input.servermatch').prop('checked', true).trigger ('change');
        });

        $track_templates.remove ();
    };

    self.lazyLoad = function () {
        var medium = self.$fieldset.find ('input.medium-id').val ();
        self.$fieldset.find ('.clickedit').hide ();
        self.$nowloading.show ();
        $.getJSON ('/ws/js/associations/' + medium, self.load);
    };

    self.initializeTracks = function () {
        self.$fieldset.find ('tr.track').each (function (idx, row) {
            self.tracks.push (MB.Control.ReleaseRecordingsTrack (self, disc, idx, row));
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

    $('fieldset.recording-assoc-disc').each (function (idx, disc) {
        var discno = $(disc).attr ('id').replace ('recording-assoc-disc-', '');

        self.discs.push (MB.Control.ReleaseRecordingsDisc (self, discno, disc));
    });

    return self;
};

$(function() {
    $('#id-propagate_all_track_changes').change(function() {
        $('input.copy-to-recording').prop('checked', $(this).prop('checked'));
    });
});
