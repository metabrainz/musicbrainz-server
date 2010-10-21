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

MB.TrackParser = function (disc, textarea, serialized) {
    var self = MB.Object ();

    var getTrackInput = function () {
        self.inputlines = $.trim (self.textarea.val ()).split ("\n");
    };

    var removeTrackNumbers = function () {
        if (self.vinylnumbers.filter (':checked').val ())
        {
            $.each(self.inputlines, function (i) {
                self.inputlines[i] = this.replace(/^[\s\(]*[-\.０-９0-9a-z]+[\.\)\s]+/i, "");
            });
        }
        else if (self.tracknumbers.filter (':checked').val ())
        {
            $.each(self.inputlines, function (i) {
                self.inputlines[i] = this.replace(/^[\s\(]*([-\.０-９0-9\.]+(-[０-９0-9]+)?)[\.\)\s]+/, "");
            });
        }
    };

    var parseTimes = function () {
        self.inputdurations = [];

        $.each(self.inputlines, function (i) {

            var tmp = this.replace (/\(\?:\?\?\)\s?$/, '');
            self.inputlines[i] = tmp.replace(/\(?\s?([0-9０-９]*[：，．':,.][0-9０-９]+)\s?\)?$/,
                function (str, p1) { 
                    self.inputdurations[i] = MB.utility.fullWidthConverter(p1); return ""; 
                }
            );

        });
    }

    var cleanSpaces = function () {
        $.each(self.inputlines, function (i) {
            self.inputlines[i] = $.trim(self.inputlines[i]);
        });
    };

    var cleanTitles = function () {
        $.each(self.inputlines, function (i) {
            self.inputlines[i] = self.inputlines[i].replace (/(.*),\sThe$/i, "The $1")
                .replace (/\s*,/g, ",");
        });
    };

    var parseArtists = function () {
        self.inputartists = [];

        $.each(self.inputlines, function (i) {
            if (self.inputlines[i].match (self.artistseparator))
            {
                self.inputartists[i] = $.trim (
                    self.inputlines[i].split (self.artistseparator, 2)[1]
                        .replace(/(.*),\sThe$/i, "The $1")
                        .replace(/\s*,/g, ","));

                self.inputlines[i] = self.inputlines[i].split (self.artistseparator,1)[0];
            }
        });
    };

    var fillInData = function () {
        var map = {};

        $.each (self.originals, function (idx, track) {
            if (map[track.name] === undefined) {
                map[track.name] = [];
            }
            map[track.name].push (idx);
        });

        var lastused = self.originals.length - 1;

        var original = function (idx) {
            if (idx < self.originals.length)
            {
                return $.extend ({ 'position': idx+1 }, self.originals[idx]);
            }

            return undefined;
        };

        var moved = [];
        var inserted = [];
        var deleted = [];
        var no_change = [];

        var position = 1;

        // Match up inputtitles with existing tracks.
        $.each (self.inputtitles, function (idx, title) {
            var data = { 'length': self.inputdurations[idx], 'position': position };

            if (title === '')
            {
                return;
            }

            if (map[title] === undefined || map[title].length === 0)
            {
                data.row = ++lastused;
                data.name = title;
                inserted.push (data);
            }
            else if ($.inArray (idx, map[title]) !== -1)
            {
                data.row = idx;
                no_change.push (data);
                map[title].splice ($.inArray (idx, map[title]), 1);
            }
            else
            {
                data.row = map[title].pop ();
                moved.push (data);
            }

            position++;
        });

        $.each (map, function (key, value) {
            $.each (value, function (idx, row) { deleted.push(row) });
        });

        /* restore those which don't change from their serialized values. */
        $.each (no_change, function (idx, data) {
            var copy = original (data.row);
            copy.deleted = 0;
            copy.length = data.length;
            self.disc.getTrack (data.row).render (copy);
        });

        /* re-arrange any tracks which have moved. */
        $.each (moved, function (idx, data) {
            var copy = original (data.row);
            copy.deleted = 0;
            copy.position = data.position;
            copy.length = data.length;
            self.disc.getTrack (data.row).render (copy);
        });

        /* mark deleted tracks as such. */
        $.each (deleted, function (idx, row) {
            var copy = original (row);
            copy.deleted = 1;
            self.disc.getTrack (row).render (copy);
        });

        /* insert newly added tracks. */
        $.each (inserted, function (idx, data) {
            data.deleted = 0;

            self.disc.getTrack (data.row).render (data);
        });

        /* remove unused positions. */
        self.disc.removeTracks (lastused);

        /* sort the table view after all these edits. */
        self.disc.sort ();
    };

    var run = function () {
        self.inputartists = [];
        self.inputdurations = [];

        self.getTrackInput ();
        self.removeTrackNumbers ();
        self.parseTimes ();
        self.cleanSpaces ();
        self.cleanTitles ();
        self.inputtitles = self.inputlines;

        self.fillInData ();
    };

    /* public variables. */
    self.disc = disc;
    self.textarea = textarea;
    self.originals = $.isArray (serialized) ? serialized : [];
    self.artistseparator = new RegExp ("\\s[/\\t]");
    self.guesscase = $('#guesscase');
    self.tracknumbers = $('#tracknumbers');
    self.vinylnumbers = $('#vinylnumbers');
    self.tracktimes = $('#tracktimes');

    /* public methods. */
    self.getTrackInput = getTrackInput;
    self.removeTrackNumbers = removeTrackNumbers;
    self.parseTimes = parseTimes;
    self.cleanSpaces = cleanSpaces;
    self.cleanTitles = cleanTitles;
    /* 
       Various Artist releases are not currently supported, so parseArtists
       is commented out for now. --warp.

       self.parseArtists = parseArtists;
    */
    self.fillInData = fillInData;
    self.run = run;

    return self;
};
