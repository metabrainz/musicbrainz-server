

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

        $.each (self.inputtitles, function (idx, title) {

            var prefix = '#id-mediums\\.'+self.disc+'\\.tracklist\\.tracks\\.'+idx+'\\.';
            $(prefix + 'name').val (title);
            $(prefix + 'length').val (self.inputdurations[idx]);

        });

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
    self.textarea = $('#mediums\\.'+disc+'\\.tracklist');
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
