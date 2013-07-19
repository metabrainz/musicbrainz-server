/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010-2011 MetaBrainz Foundation

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

MB.Control.ReleaseTrack = function (parent, $track, $artistcredit) {
    var self = MB.Object ();

    self.parent = parent;
    self.bubble_collection = self.parent.bubble_collection;

    self.$row = $track;
    self.$acrow = $artistcredit;

    self.$position = $track.find ('td.position span');
    self.$number = $track.find ('td.position input');
    self.$title = $track.find ('td.title input.track-name');
    self.$id = $track.find ('td.title input[type=hidden]');
    self.$artist = $track.find ('td.artist input');
    self.$length = $track.find ('td.length input');
    self.$deleted = $track.find ('td input.deleted');

    self.$moveDown = self.$row.find ("input.track-down");
    self.$moveUp = self.$row.find ("input.track-up");

    /**
     * render enters the supplied data into the form fields for this track.
     */
    self.render = function (data) {
        self.$position.text (data.position);
        if (data.number)
        {
            self.$number.val (data.number);
        }
        else
        {
            self.$number.val (self.position ());
        }

        self.$id.val (data.id);
        self.$title.val (data.name);
        if (self.getDuration () === null || !self.parent.hasToc ())
        {
            /* do not allow changes to track times if the disc has a TOC. */
            self.setDuration (data.length)
        }
        data.deleted = parseInt (data.deleted, 10);
        self.$deleted.val (data.deleted);
        if (data.artist_credit)
        {
            self.artist_credit.render (data.artist_credit);
            self.updateVariousArtists ();
        }

        if (data.deleted)
        {
            self.$row.addClass ('deleted');
        }
        else
        {
            self.$row.removeClass ('deleted');
        }

        return self;
    };

    /**
     * blurLength updates the internal (millisecond) representation of
     * a track length if a user changed it, and it adds a colon to the
     * track length if the user omitted it
     */
    self.blurLength = function (event) {
        var length = self.$length.val ();
        length = length.replace (/^([0-9]*)([0-9][0-9])$/, "$1:$2");

        self.setDuration (MB.utility.unformatTrackLength (length));
    };

    /**
     * Guess Case the track title.
     */
    self.guessCase = function () {
        self.$title.val (MB.GuessCase.track.guess (self.$title.val ()));
        self.artist_credit.guessCase ();
    };

    /**
     * deleteTrack marks the track for deletion.
     */
    self.deleteTrack = function () {
        self.$deleted.val('1');
        self.bubble_collection.hideAll();
        self.$row.hide ();
        self.$row.addClass ('deleted');

        self.parent.updateTrackNumbers ();
    };

    /* disableTracklistEditing disables the position and duration inputs and
       disables the remove track button if a CDTOC is present. */
    self.disableTracklistEditing = function () {
        if (!self.parent.hasToc ())
            return;

        self.$moveDown.unbind ('click.mb');
        self.$moveUp.unbind ('click.mb');

        self.$length.prop('disabled', true);
        self.$row.find ("input.remove-track").hide ();

        self.$position.add(self.$length)
            .add (self.$moveDown)
            .add (self.$moveUp)
            .attr('title', MB.text.DoNotChangeTracks)
            .addClass('disabled-hint');
    };

    /**
     * updateVariousArtists will mark the disc as VA if the artist for this
     * track is different from the release artist.
     */
    self.updateVariousArtists = function () {
        if (self.isDeleted () || self.artist_credit.isReleaseArtist ())
            return;

        self.parent.setVariousArtists ();
    };

    /**
     * isDeleted returns true if this track is marked for deletion.
     */
    self.isDeleted = function () {
        return self.$deleted.val () === '1';
    };

    /**
     * set track duration in ms.
     */
    self.setDuration = function (duration)
    {
        var duration_str = MB.utility.formatTrackLength (duration);

        if (duration_str === self.duration_str)
            return;

        self.duration = duration;
        self.duration_str = duration_str;
        self.$length.val (duration_str);
    };

    /**
     * get track duration in ms.  if original_duration is provided
     * that value will be returned if it looks like the value wasn't
     * changed.
     */
    self.getDuration = function (original_duration)
    {
        if (original_duration)
        {
            var original_str = MB.utility.formatTrackLength (original_duration);

            return (original_str === self.$length.val ()
                    ? original_duration
                    : MB.utility.unformatTrackLength (self.$length.val ()));
        }
        else
        {
            return MB.utility.unformatTrackLength (self.$length.val ());
        }
    };

    /**
     * remove removes the associated inputs and table rows.
     */
    self.remove = function () {
        self.$row.remove ();
        self.$acrow.remove ();
    };


    /**
     * set or read track position.
     */
    self.position = function (val) {
        if (val !== undefined)
        {
            if (self.$number.val () === self.$position.text ())
            {
                self.$number.val (val);
            }

            self.$position.text (val);
        }

        return parseInt (self.$position.text (), 10);
    };

    self.number = function (val) {
        if (val !== undefined)
        {
            self.$number.val (val);
        }

        return self.$number.val ();
    };

    self.title = function (val) {
        if (val !== undefined)
        {
            self.$title.val (val);
        }

        return self.$title.val ();
    };

    self.artistCreditText = function (val) {
        if (val !== undefined)
        {
            self.artist_credit.render({
                "names": [{
                    "artist": { "name": val },
                    "name": val
                }]
            });
        }

        return self.$artist.val();
    };

    /**
     * move the track up/down.
     */
    self.moveUp = function ()
    {
        var pos = self.position ();
        if (pos > 1)
        {
            // sorted_tracks is zero-based.
            var other = self.parent.sorted_tracks[pos - 2];

            // position() may change the number() if it looks
            // like an integer, so get these before they're changed.
            var self_number = self.number ();
            var other_number = other.number ();

            // set correct integer track positions.
            self.position (pos - 1);
            other.position (pos);

            // set correct free-text track numbers.
            other.number (self_number);
            self.number (other_number);
        }

        self.parent.sort ();
    };

    self.moveDown = function ()
    {
        // sorted_tracks is zero-based.
        var trk = self.parent.sorted_tracks[self.position ()];
        if (trk)
        {
            trk.moveUp ();
        }
    }

    self.$length.bind ('blur.mb', self.blurLength);
    self.$row.find ("input.remove-track").bind ('click.mb', self.deleteTrack);
    self.$row.find ("input.guesscase-track").bind ('click.mb', self.guessCase);

    self.$moveDown.bind ('click.mb', self.moveDown);
    self.$moveUp.bind ('click.mb', self.moveUp);

    var $target = self.$row.find ("td.artist input");
    var $button = self.$row.find ("a[href=#credits]");
    self.bubble_collection.add ($button, self.$acrow);
    self.artist_credit = MB.Control.ArtistCreditRow ($target, self.$acrow, $button);

    self.duration = null;
    self.duration_str = '?:??';

    if (self.isDeleted ())
    {
        self.$row.addClass('deleted');
    }

    return self;
};

MB.Control.ReleaseDisc = function (parent, $disc) {
    var self = MB.Object ();

    self.$fieldset = $disc;
    self.parent = parent;
    self.bubble_collection = self.parent.bubble_collection;
    self.track_count = null;

    /**
     * addTrack renders new tr.track and tr.track-artist-credit rows in the
     * tracklist table.  It copies the release artistcredit.
     */
    self.addTrack = function () {
        var trackno = 0;
        $.each (self.tracks, function (idx, item) {
            if (item.isDeleted ())
                return;

            var pos = item.position ()
            if (pos > trackno)
            {
                trackno = pos;
            }
        });

        var previous = null;
        if (self.$table.find ('tr.track').length)
        {
            previous = self.$table.find ('tr.track').last ();
        }

        var $row = self.$template.find ('tr.track').clone ();
        var $acrow = self.$template.find ('tr.track-artist-credit').clone ();

        self.$table.append ($row).append ($acrow);

        var trk = MB.Control.ReleaseTrack (self, $row, $acrow);
        trk.position (trackno + 1);

        self.tracks.push (trk);
        self.sorted_tracks.push (trk);

        /* if the release artist is VA, clear out the track artist. */
        if (trk.artist_credit.isVariousArtists ())
        {
            trk.artist_credit.clear ();
        }

        trk.disableTracklistEditing ();
    };

    self.addTrackEvent = function (event) {
        var count = parseInt (self.$add_track_count.val (), 10);

        if (!count || count < 1)
        {
            count = 1;
        }

        while (count)
        {
            self.addTrack ();
            count = count - 1;
        }

        self.$add_track_count.val(1);
    };


    /**
     * getTrack merely returns the track from self.tracks if the track
     * exists.  If the track does not exist yet getTrack will
     * repeatedly call addTrack until it does.
     */
    self.getTrack = function (idx) {
        while (idx >= self.tracks.length)
        {
            self.addTrack ();
        }

        return self.tracks[idx];
    };

    self.getTracksAtPosition = function (pos) {

        var ret = [];
        $.each (self.tracks, function (idx, item) {
            if (item.position () === pos)
            {
                ret.push (item);
            }
        });

        return ret;
    };

    /**
     * removeTracks removes all table rows for unused track positions.  It expects
     * the position of the last used track as input.
     */
    self.removeTracks = function (lastused) {
        while (lastused + 1 < self.tracks.length)
        {
            self.tracks.pop ().remove ();
        }

        if (lastused === 0)
        {
            self.sorted_tracks = [];
        }
    };

    /**
     * sort sorts all the table rows by the 'position' input.
     */
    self.sort = function () {
        self.sorted_tracks = [];
        $.each (self.tracks, function (idx, item) { self.sorted_tracks.push (item); });

        self.sorted_tracks.sort (function (a, b) {
            return a.position () - b.position ();
        });

        $.each (self.sorted_tracks, function (idx, track) {
            if (idx)
            {
                track.$row.insertAfter (self.sorted_tracks[idx-1].$acrow);
                track.$acrow.insertAfter (track.$row);
            }
        });
    };

    /**
     * updateArtistColumn makes sure the enabled/disabled state of each of the artist
     * inputs matches the checkbox at the top of the column.
     */
    self.updateArtistColumn = function () {

        if (self.$artist_column_checkbox.is (':checked'))
        {
            $.each (self.tracks, function (idx, item) {
                item.artist_credit.enableTarget ();
                item.artist_credit.$artist_input.removeClass ('column-disabled');
            });
        }
        else
        {
            /* opening a bubble will disable the input, and re-enable
               it on close.  make sure to close these bubbles _before_
               trying to disable the associated input. */
            self.bubble_collection.hideAll ();

            $.each (self.tracks, function (idx, item) {
                item.artist_credit.disableTarget ();
                item.artist_credit.$artist_input.addClass ('column-disabled');
            });
        }
    };

    /* 'up' is visual, so the disc position decreases. */
    self.moveUp = function () {
        var oldpos = self.position ()
        if (oldpos > 1)
        {
            self.position (oldpos - 1);
            self.parent.moveDisc (oldpos, self);
        }
    };

    /* 'down' is visual, so the disc position increases. */
    self.moveDown = function () {
        var oldpos = self.position ()
        self.position (oldpos + 1);
        self.parent.moveDisc (oldpos, self);
    };

    self.clearDisc = function () {
        self.edits.clearEdits ();
        self.tracklist = [];
        self.removeTracks (-1);
        self.expand ();
    };

    self.removeDisc = function (chained) {
        self.clearDisc ();

        self.$deleted.val ("1");
        self.$fieldset.addClass ('deleted');

        self.parent.removeDisc (self);
        self.position (0);
    };

    self.isDeleted = function () {
        return self.$deleted.val () == "1";
    };

    self.isEmpty = function () {
        if (! self.expanded)
        {
            return false;
        }

        if (self.tracks.length === 0)
        {
            return true;
        }
        else if (self.tracks.length === 1 &&
                 self.tracks[0].$title.val () === '' &&
                 self.tracks[0].getDuration () === null)

        {
            /* this track was most probably added by "Add Disc" ->
             * "Manual entry", which means this disc should still be
             * considered empty. */
            return true;
        }
        else
        {
            var deleted = true;
            $.each (self.tracks, function (idx, trk) {
                deleted = deleted && trk.isDeleted ();
            });

            /* if all tracks are deleted, the disc is empty. */
            return deleted;
        }
    };

    self.position = function (val) {
        if (val !== undefined)
        {
            self.$position.val (val);
            self.$fieldset.find ('span.discnum').text (val);
        }

        return parseInt (self.$position.val (), 10);
    };

    self.submit = function () {
        if (self.expanded)
        {
            self.updateTrackNumbers ();
            self.edits.saveEdits (self.tracklist, self.tracks);
        }

        var clear_title = true;
        self.parent.updateDiscTitle (clear_title);
    };

    self.getReleaseArtist = function () {
        $release_artist = $('table.tracklist-template tr.track-artist-credit');

        var names = [];
        var preview = "";
        $release_artist.find ('tr.artist-credit-box').each (function (idx, row) {
            names[idx] = {
                "artist": {
                    "name": $(row).find ('input.name').val (),
                    "gid": $(row).find ('input.gid').val (),
                    "id": $(row).find ('input.id').val ()
                },
                "name": $(row).find ('input.credit').val (),
                "join_phrase": $(row).find ('input.join').val ()
            };

            preview += names[idx].name + names[idx].join;
        });

        return { names: names, preview: preview };
    };

    self.changeTrackArtists = function (data) {
        if (!MB.release_artist_json)
        {
            return data;
        }

        /* if MB.release_artist_json is not null, the user has changed the release
           artist and wants to change track artists too.

           The following code compares the artist for each track to the previous
           release artist, if they are the same we need to update the artist for
           that track with the new release artist.
        */
        $.each (data, function (idx, track) {
            if (track.artist_credit.names.length === MB.release_artist_json.names.length)
            {
                var update = true;

                $.each (MB.release_artist_json.names, function (idx, credit) {
                    tmp = track.artist_credit.names[idx];
                    if (credit.name !== tmp.name || credit.id !== tmp.id)
                    {
                        update = false;
                        return false;
                    }
                });

                if (update)
                {
                    data[idx].artist_credit = self.getReleaseArtist ();
                }
            }
        });

        return data;
    };

    self.collapse = function () {
        self.expanded = false;
        self.edits.saveEdits (self.tracklist, self.tracks);

        /* Free up memory used for the tracklist.
           FIXME: shouldn't do this immediatly, but only after N other discs
           have been opened. */
        self.tracklist = null;

        self.$table.hide ();
        self.removeTracks (0);
        self.$fieldset.removeClass ('expanded');
        self.$collapse_icon.hide ();
        self.$expand_icon.show ();
    };

    self.expand = function () {
        self.expanded = true;
        var data = self.edits.loadEdits ();

        var use_data = function (data) {
            self.loadTracklist (data);
            self.fixTrackCount ();

            var vaTracklist = false;
            $.each(data, function(idx, track) {
                var thisArtistStr = MB.utility.structureToString(track.artist_credit);
                if (idx > 0 && lastArtistStr != thisArtistStr) {
                    vaTracklist = true;
                    return false;
                }

                lastArtistStr = thisArtistStr;
                return true;
            });

            if (vaTracklist) {
                self.$fieldset.find('input.artistcolumn').click().trigger('change');
            }
        };

        self.$nowloading.show ();
        self.$fieldset.addClass ('expanded');
        self.$expand_icon.hide ();
        self.$collapse_icon.show ();

        if (data)
        {
            self.tracklist = jQuery.extend (true, {}, data);
            use_data (data);
        }
        else if (!self.tracklist)
        {
            /* FIXME: ignore result if the disc has been collapsed in
               the meantime.  --warp. */
            var medium_id = self.$medium_id.val ();
            if (medium_id)
            {
                $.getJSON ('/ws/js/medium/' + medium_id, {}, function (data) {

                    /* do a deep clone of our input to ensure that we always have
                       a copy of the data as loaded from /js/medium, without any
                       changes. */
                    self.tracklist = jQuery.extend (true, {}, data.tracks);
                    use_data (self.changeTrackArtists (data.tracks));
                });
            }
            else
            {
                use_data ([]);
            }
        }
        else
        {
            /* empty disc, we're not loading remote data. */
            self.$nowloading.hide ();
        }
    };


    self.loadTracklist = function (data) {

        self.trackparser = MB.TrackParser.Parser (self, data);

        self.removeTracks (data.length);

        $.each (data, function (idx, trk) {
            if (!trk.hasOwnProperty ('position'))
            {
                trk.position = idx + 1;
            }

            if (!trk.hasOwnProperty ('deleted'))
            {
                trk.deleted = 0;
            }

            if (!trk.hasOwnProperty ('name'))
            {
                trk.name = "";
            }

            self.getTrack (idx).render (trk);
        });

        self.sort ();
        self.$table.show ();
        self.$nowloading.hide ();
    };

    self.tocTrackCount = function() {
        var releaseTocCount = MB.medium_cdtocs[self.number],
        parsedTocCount = self.$toc.val().split(/\s+/)[1];

        return releaseTocCount || parsedTocCount || null;
    }

    /* if this medium has a toc, force the correct number of tracks
       (adding or removing tracks as neccesary). */
    self.fixTrackCount = function () {
        if (!self.hasToc ())
            return;

        self.track_count = self.tocTrackCount();
        self.removeTracks (self.track_count);
        self.getTrack (self.track_count - 1);
    };

    self.guessCase = function () {
        self.guessCaseTitle ();

        $.each (self.tracks, function (idx, item) { item.guessCase (); });
    };

    self.guessCaseTitle = function () {
        self.$title.val (MB.GuessCase.release.guess (self.$title.val ()));
    };


    /**
     * isVariousArtists returns false only if all tracks on the disc are identical
     * to the release artist.
     */
    self.isVariousArtists = function () {
        return self.various_artists;
    };

    self.hasToc = function () {
        return MB.medium_cdtocs[self.number] || self.$toc.val () !== '';
    };

    /**
     * Allow a track to mark this disc as various artists.  There currently is no way
     * to change this back to single artists.
     */
    self.setVariousArtists = function () {
        self.various_artists = true;
    };

    /**
     * Disable the disc title field if there is only one disc and the
     * title is not set.  If the "clear" argument is true, remove the
     * disc title if present.
     */
    self.disableDiscTitle = function (clear) {
        if (clear)
        {
            self.$title.val ('');
        }

        if (self.$title.val () === '')
        {
            self.$title.prop('disabled', true);
            self.$title.siblings ('input.icon.guesscase-medium').hide ();
        }
    };

    /**
     * Reset free-text track numbers back to their integer values.
     */
    self.resetTrackNumbers = function (event) {
        self.updateTrackNumbers ();
        $.each (self.sorted_tracks, function (idx, item) {
            item.number (item.position ());
        });
    };

    self.hasComplexArtistCredits = function() {
        var x = false;
        $.each(self.sorted_tracks, function (idx, item) {
            x = item.artist_credit.isComplex();
            return !x;
        });
        return x;
    };

    /**
     * Swap track titles with artist credits (and replace artist credits with track titles)
     */
    self.swapArtistsAndTitles = function (event) {
        var requireConf = self.hasComplexArtistCredits();
        if (!requireConf || (requireConf && confirm(MB.text.ConfirmSwap))) {
            // Ensure that we can edit track artists
            self.$artist_column_checkbox.prop('checked', true);
            self.updateArtistColumn();

            $.each (self.sorted_tracks, function(idx, item) {
                var oldTitle = item.title ();

                item.title(item.artistCreditText());
                item.artistCreditText(oldTitle);
            });
        }
    };

    /**
     * Update remaining track numbers / positions after a track in the
     * tracklist has been deleted.
     */
    self.updateTrackNumbers = function () {
        var trackpos = 1;

        $.each (self.sorted_tracks, function (idx, item) {
            item.position (trackpos);

            if (!item.isDeleted ())
            {
                trackpos += 1;
            }
        });
    };


    /**
     * Open the trackparser.
     */
    self.openTrackParser = function (event) {
        MB.Control.release_track_parser.openDialog (event, self);
    };

    /**
     * Enable the disc title field if there are multiple discs.
     */
    self.enableDiscTitle = function () {
        self.$title.prop('disabled', false);
        self.$title.siblings ('input.icon.guesscase-medium').show ();
    };

    self.$table = self.$fieldset.find ('table.medium');
    self.$artist_column_checkbox = self.$table.find ('th.artist input');

    self.number = parseInt (self.$fieldset.attr ('id').match ('mediums\.([0-9]+)\.advanced-disc')[1], 10);

    self.various_artists = false;
    self.expanded = false;
    self.tracklist = null;
    self.tracks = [];
    self.sorted_tracks = [];
    self.trackparser = MB.TrackParser.Parser (self, []);

    var $format = self.$fieldset.find ('.advanced-medium-format-and-title');
    self.$toc = $format.find ('input.toc');
    self.$title = $format.find ('input.name');
    self.$deleted = $format.find ('input.deleted');
    self.$position = $format.find ('input.position');
    self.$format_id = $format.find ('input.format');
    self.$medium_id = $format.find ('input.id');
    self.$medium_id_for_recordings = self.$fieldset.find ('input.medium_id_for_recordings');

    self.$title.siblings ('input.guesscase-medium').bind ('click.mb', self.guessCaseTitle);

    self.edits = MB.Control.ReleaseEdits ($('#id-mediums\\.'+self.number+'\\.edits'));

    self.$expand_icon = self.$fieldset.find ('input.expand-disc');
    self.$collapse_icon = self.$fieldset.find ('input.collapse-disc');
    self.$nowloading = self.$fieldset.find ('div.tracklist-loading');

    self.$template = $('table.tracklist-template');

    self.$fieldset.find ('table.medium tbody tr.track').each (function (idx, item) {
        self.tracks.push (
            MB.Control.ReleaseTrack (self, item, item.next('tr.track-artist-credit'))
        );
    });

    self.$add_track_count = self.$fieldset.find ('input.add-track-count');
    self.$fieldset.find ('.reset-track-numbers').bind ('click.mb', self.resetTrackNumbers);
    self.$fieldset.find ('.swap-artists-and-titles').bind ('click.mb', self.swapArtistsAndTitles);
    self.$fieldset.find ('input.track-parser').bind ('click.mb', self.openTrackParser);
    self.$fieldset.find ('input.add-track').bind ('click.mb', self.addTrackEvent);
    self.$fieldset.find ('input.disc-down').bind ('click.mb', self.moveDown);
    self.$fieldset.find ('input.disc-up').bind ('click.mb', self.moveUp);
    self.$fieldset.find ('input.remove-disc')
        .bind ('click.mb', function (ev) { self.removeDisc (); });
    self.$expand_icon.bind ('click.mb', function (ev) { self.expand (); });
    self.$collapse_icon.bind ('click.mb', function (ev) { self.collapse (); });

    self.$artist_column_checkbox.bind ('change', self.updateArtistColumn);

    self.updateArtistColumn ();
    self.enableDiscTitle ();
    self.sort ();

    if (self.isDeleted ())
    {
        self.$fieldset.addClass ('deleted');
    }
    else
    {
        self.$fieldset.removeClass ('deleted');
    }

    if (self.hasToc ())
    {
        self.$fieldset.find ('div.add-track').hide ();
    }
    else
    {
        self.$fieldset.find ('div.add-track').show ();
    }


    return self;
};

MB.Control.ReleaseTracklist = function () {
    var self = MB.Object ();

    $('#release-editor table.tbl th input[type="checkbox"]').show();

    self.bubble_collection = MB.Control.BubbleCollection ();
    self.bubble_collection.setType (MB.Control.BubbleRow);

    self.emptyDisc = function () {
        var disc = self.lastDisc ();
        if (disc && disc.isEmpty ())
        {
            /* currently the last disc is empty, so just re-use that. */
            disc.clearDisc ();
            return disc;
        }
        else
        {
            return self.addDisc ();
        }
    };

    self.addDisc = function () {
        var discs = self.discs.length;
        var newposition = 1;
        var i;

        for (i = self.positions.length; i >= 0; i--)
        {
            if (self.positions[i])
            {
                newposition = i + 1;
                break;
            }
        }

        var $lastdisc = $('.advanced-disc').last ();
        var $newdisc = $lastdisc.clone ().insertAfter ($lastdisc);

        $newdisc.find ('table.medium.tbl tbody').empty ();
        $newdisc.find ("legend").find ('span.discnum').text (newposition);

        var mediumid = new RegExp ("mediums.[0-9]+");

        $newdisc.find ("*").addBack ().each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').replace(mediumid, "mediums."+discs));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').replace(mediumid, "mediums."+discs));
            }
        });

        /* clear the cloned rowid for this medium and tracklist, so a
         * new medium and tracklist will be created. */
        $("#id-mediums\\."+discs+"\\.id").val('');
        $("#id-mediums\\."+discs+"\\.name").val('');
        $("#id-mediums\\."+discs+"\\.position").val(newposition);
        $("#id-mediums\\."+discs+"\\.id").val('');
        $('#id-mediums\\.'+discs+'\\.deleted').val('0');
        $('#id-mediums\\.'+discs+'\\.edits').val('');
        $('#id-mediums\\.'+discs+'\\.toc').val('');

        var new_disc = MB.Control.ReleaseDisc (self, $newdisc);

        new_disc.expand ();
        self.discs.push (new_disc);
        self.positions[new_disc.position()] = new_disc;

        /* and scroll down to the new position of the 'Add Disc' button if possible. */
        /* FIXME: this hardcodes the fieldset bottom margin, shouldn't do that. */
        var newpos = $lastdisc.height () ? $lastdisc.height () + 12 : $lastdisc.height ();
        $('html').animate({ scrollTop: $('html').scrollTop () + newpos }, 500);

        self.updateDiscTitle ();

        return new_disc;
    };

    self.moveDisc = function (oldpos, disc) {
        var newpos = disc.position ();
        other = self.positions[newpos];
        if (!other)
        {
            self.positions[newpos] = disc;
            delete self.positions[oldpos];

            return true;
        }

        other.position (oldpos);
        self.positions[oldpos] = other;
        self.positions[newpos] = disc;

        if (newpos < oldpos)
        {
            disc.$fieldset.insertBefore (other.$fieldset);
        }
        else
        {
            other.$fieldset.insertBefore (disc.$fieldset);
        }

        return true;
    };

    self.removeDisc = function (disc) {
        var startpos = disc.position ();
        var i;

        delete self.positions[startpos];

        for (i = startpos + 1; i < self.positions.length; i++)
        {
            disc = self.positions[i];
            if (!disc)
            {
                /* do not move any discs beyond a possible gap. */
                break;
            }
            disc.moveUp ();
        }

        self.updateDiscTitle ();
    };

    self.guessCase = function () {
        $.each (self.discs, function (idx, disc) { disc.guessCase (); });
    };

    self.submit = function (event) {
        $.each (self.discs, function (idx, disc) {
            disc.submit (event);
        });
    };

    /* When the page is loaded, discs may not be displayed in the
       correct order.  This function will be called after
       initialization to fix the displayed order. */
    self.orderDiscs = function () {
        if (self.positions.length > 1)
        {
            var prev_disc = undefined;
            $.each (self.positions, function (pos, disc) {
                if (prev_disc && disc)
                {
                    disc.$fieldset.insertAfter (prev_disc.$fieldset);
                }

                if (disc)
                {
                    prev_disc = disc;
                }
            });
        }
    }

    /* Returns the last disc, i.e. the disc with the highest position() which
       has not been deleted. */
    self.lastDisc = function () {
        var pos = self.positions.length;
        while (pos > 0)
        {
            if (self.positions[pos])
            {
                return self.positions[pos];
            }
            pos--;
        }

        return null;
    }

    self.updateDiscTitle = function (clear) {
        var pos = self.positions.length;
        var count = 0;
        var firstdisc = 1;
        while (pos > 0)
        {
            if (self.positions[pos])
            {
                firstdisc = pos;
                count++;
            }
            pos--;
        }

        if (count === 1)
        {
            self.positions[firstdisc].disableDiscTitle (clear);
        }
        else if (self.positions[firstdisc])
        {
            self.positions[firstdisc].enableDiscTitle ();
        }
    };

    self.variousArtistsWarning = function (event) {
        var $va = $('.artist-credit-box input.name.various-artists');

        if (!$va.length)
        {
            self.$va_warning.hide ();
        }
        else
        {
            var affected = {};

            $va.each (function (idx, elem) {
                var $trkrow = $(elem).parents ('tr.track-artist-credit').prevAll('*:eq(0)');

                var disc = _.clean ($trkrow.parents ('fieldset.advanced-disc').find ('legend').text ());

                if (!affected.hasOwnProperty (disc))
                {
                    affected[disc] = [];
                }

                affected[disc].push ($trkrow.find ('input.pos').val ());
            });

            var $ul = self.$va_warning.show ().find ('ul').empty ();

            $.each (affected, function (discpos, tracks_with_va) {
                $ul.append ('<li>' + discpos + ', tracks ' + tracks_with_va.join (", ") + '</li>');
            });

        }

    };

    $("a[href=#guesscase]").click (function () {
        self.guessCase ();
    });

    $("#release-editor").on("VariousArtists", ".artist-credit-box input.name",
        self.variousArtistsWarning);

    self.$va_warning = $('div.various-artists.warning');
    self.$tab = $('div.advanced-tracklist');
    self.discs = [];
    self.positions = [];

    self.$tab.find ('fieldset.advanced-disc').each (function (idx, item) {
        var disc = MB.Control.ReleaseDisc (self, $(item));
        self.discs.push (disc);
        self.positions[disc.position()] = disc;
    });

    $('form.release-editor').bind ('submit.mb', self.submit);

    self.updateDiscTitle ();
    self.orderDiscs ();

    if (self.discs.length < 4)
    {
        $.each (self.discs, function (idx, disc) { disc.expand (); });
    }

    return self;
};

$('document').ready (function () {
    if ($('li.current input').attr ("name") == "step_tracklist") {
        MB.Control.release_tracklist = MB.Control.ReleaseTracklist ();
    };
});

