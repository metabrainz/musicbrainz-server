

mbz.TrackParser = function (disc) {
    var self = mbz.Object ();


    var getTrackInput = function () {
        self.inputlines = $.trim (self.textarea.val ()).split ("\n");
    };

    var removeTrackNumbers = function () {
        if (self.vinylnumbers)
        {
            $.each(self.inputlines, function (i) {
                self.inputlines[i] = this.replace(/^[\s\(]*[-\.０-９0-9a-z]+[\.\)\s]+/i, "");
            });
        }
        else if (self.tracknumbers)
        {
            $.each(self.inputlines, function (i) {
                self.inputlines[i] = this.replace(/^[\s\(]*([-\.０-９0-9\.]+(-[０-９0-9]+)?)[\.\)\s]+/, "");
            });
        }
    };

    var parseTimes = function () {
        $.each(self.inputlines, function (i) {

            var tmp = this.replace (/\(\?:\?\?\)\s?$/, '');
            self.inputlines[i] = tmp.replace(/\(?\s?([0-9０-９]*[：，．':,.][0-9０-９]+)\s?\)?$/,
                function (str, p1) { self.inputdurations[i] = mbz.fullWidthConverter(p1); return ""; }
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
        $.each(self.inputlines, function (i) {
            if (self.inputlines[i].match (self.artistseparator))
            {
                self.inputartists[i] = inputlines[i].split (self.artistseparator, 2)[1]
                    .replace(/(.*),\sThe$/i, "The $1")
                    .replace(/\s*,/g, ",");

                self.inputlines[i] = self.inputlines[i].split (self.artistseparator,1)[0];
            }
        });
    };

    var fillInData = function () {

        var map = {};
        var originals = self.disc.originals ();
        $.each (originals, function (idx, track) {
            if (map[track.title] === undefined) {
                map[track.title] = [];
            }
            map[track.title].push (idx);
        });

        var moved = [];
        var inserted = [];
        var deleted = [];
        var no_change = [];

        var lastused = originals.length - 1;

        // Match up inputtitles with existing tracks.
        $.each (self.inputtitles, function (idx, title) {
            var pos = idx + 1;

            if (map[title] === undefined)
            {
                inserted.push ({ 'row': ++lastused, 'position': pos, 'title': title});
            }
            else if ($.inArray (idx, map[title]) !== -1)
            {
                no_change.push (idx);
                map[title].splice ($.inArray (idx, map[title]), 1);
            }
            else
            {
                moved.push ({ 'position': pos, 'row': map[title].pop () });
            }
        });

        $.each (map, function (key, value) {
            $.each (value, function (idx, row) { deleted.push(row) });
        });

        /* restore those which don't change from their serialized values. */
        $.each (no_change, function (idx, row) {
            var copy = self.disc.original (row);
            copy.length = self.inputdurations[idx];
            self.disc.renderTrack (row, copy);
        });

        /* re-arrange any tracks which have moved. */
        $.each (moved, function (idx, move) {
            var copy = self.disc.original (move.row);
            copy.position = move.position;
            copy.length = self.inputdurations[idx];
            self.disc.renderTrack (move.row, copy);
        });

        /* mark deleted tracks as such. */
        $.each (deleted, function (idx, row) {
            var copy = self.disc.original (row);
            copy.deleted = 1;
            self.disc.renderTrack (row, copy);
        });

        /* insert newly added tracks. */
        $.each (inserted, function (idx, data) {
            self.disc.renderTrack (data.row, {
                'position': data.position,
                'title': data.title,
                'deleted': 0,
                'length': self.inputdurations[idx]
            });
        });

        /* remove unused positions. */
        self.disc.removeTrackInputs (lastused);
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
    self.artistseparator = new RegExp ("\\s[/\\t]");
    self.textarea = $('#mediums\\.'+disc.number+'\\.tracklist');
    self.guesscase = $('#guesscase').attr ('checked');
    self.tracknumbers = $('#tracknumbers').attr ('checked');
    self.vinylnumbers = $('#vinylnumbers').attr ('checked');
    self.tracktimes = $('#tracktimes').attr ('checked');

    /* public methods. */
    self.getTrackInput = getTrackInput;
    self.removeTrackNumbers = removeTrackNumbers;
    self.parseTimes = parseTimes;
    self.cleanSpaces = cleanSpaces;
    self.cleanTitles = cleanTitles;
    self.parseArtists = parseArtists;
    self.fillInData = fillInData;
    self.run = run;

    return self;
};
