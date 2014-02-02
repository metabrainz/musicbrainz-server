// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.releaseEditor = MB.releaseEditor || {};


MB.releaseEditor.trackParser = {

    // These are all different types of dash
    separators: /(\s+[\-‒–—―]\s+|\s*\t\s*)/,

    // Leading "M." is for Japanese releases. MBS-3398
    trackNumber: /^(?:M[\.\-])?([０-９0-9]+(?:-[０-９0-9]+)?)(?:\.|．|\s?-|:|：|;|,|，|$)?/,
    vinylNumber: /^([０-９0-9a-z]+)(?:\/[０-９0-9a-z]+)?(?:\.|．|\s?-|:|：|;|,|，|$)?/i,

    trackTime: /\(?((?:[0-9０-９]+[：，．':,.])?[0-9０-９\?]+[：，．':,.][0-5０-５\?][0-9０-９\?])\)?$/,

    options: {
        trackArtists: MB.utility.optionCookie("trackparser_trackartists"),
        trackNumbers: MB.utility.optionCookie("trackparser_tracknumbers"),
        trackTimes: MB.utility.optionCookie("trackparser_tracktimes"),
        vinylNumbers: MB.utility.optionCookie("trackparser_vinylnumbers")
    },

    parse: function (str, medium) {
        var self = this;

        var options = ko.toJS(this.options);
        var lines = _.reject(_.lines(str), _.isBlank);

        var currentPosition = 0;
        var currentTracks, hasTocs, releaseAC;

        // Mediums aren't passed in for unit tests.
        if (medium) {
            currentTracks = medium.tracks.peek().slice(0);
            hasTocs = medium.cdtocs > 0;
            releaseAC = medium.release.artistCredit;
        }

        if (hasTocs) {
            // Don't add more tracks than the CDTOC allows.
            lines = lines.slice(0, currentTracks.length);
        }

        var newTracks = $.map(lines, function (line) {
            var data = self.parseLine(line, options);

            // We should've parsed at least some values, otherwise something
            // went wrong. Returning undefined removes this result from
            // newTracks.
            if (!_.any(_.values(data))) return;

            currentPosition += 1;
            data.position = currentPosition;

            if (data.number === undefined) {
                data.number = currentPosition;
            }

            // Check for tracks with similar names to existing tracks, so that
            // we can reuse them if possible. If the medium has a CDTOC, don't
            // do this because we can't move tracks around.
            var matchedTrack = null;

            if (hasTocs) {
                matchedTrack = currentTracks && currentTracks.shift();

            } else if (currentTracks) {
                for (var j = 0, len = currentTracks.length; j < len; j++) {
                    var track = currentTracks[j];
                    var name = track.name.peek();

                    if (MB.utility.nameIsSimilar(data.name, name)) {
                        if (matchedTrack !== null) {
                            // There are multiple tracks with the same name.
                            // We can't be sure which one is correct.
                            matchedTrack = null;
                            break;
                        }
                        matchedTrack = track;
                    }
                }

                if (matchedTrack) {
                    // Don't match >1 parsed tracks to the same existing track.
                    currentTracks = _.without(currentTracks, matchedTrack);
                }
            }

            var matchedTrackAC = matchedTrack && matchedTrack.artistCredit;

            // See if we can re-use the AC from the matched track or the release.
            var matchedAC = _.find([ releaseAC, matchedTrackAC ],
                function (ac) {
                    if (!ac || ac.isVariousArtists()) return false;

                    var names = ac.names();

                    return ac.isComplete() (!data.artist ||
                        MB.utility.nameIsSimilar(data.artist, ac.text()));
                }
            );

            if (matchedAC) data.artistCredit = matchedAC.toJSON();

            if (data.artist) {
                data.artistCredit = data.artistCredit || [{ name: data.artist }];

                // If the AC has just a single artist, we can re-use the parsed
                // artist text as the credited name for that artist. Otherwise
                // we can't easily do anything with it because the parsed text
                // likely contains bits for every artist.
                if (data.artistCredit.length === 1) {
                    data.artistCredit[0].name = data.artist;
                }
            }

            if (matchedTrack) {
                matchedTrack.number(data.number ? data.number : i + 1);
                matchedTrack.name(data.name);

                if (options.trackTimes && !hasTocs && data.formattedLength) {
                    matchedTrack.formattedLength(data.formattedLength);
                }

                if (options.trackArtists) {
                    matchedTrack.artistCredit.setNames(data.artistCredit);
                }
                return matchedTrack;
            }

            return MB.releaseEditor.fields.Track(data, medium);
        });

        // Force the number of tracks if there's a CDTOC.
        var currentTrackCount = medium ? medium.tracks.peek().length : -1;

        if (hasTocs && newTracks.length < currentTrackCount) {
            var difference = currentTrackCount - newTracks.length;

            while (difference-- > 0) newTracks.push({});
        }

        return newTracks;
    },

    parseLine: function (line, options) {
        var data = {};

        // trim only, keeping tabs and other space separators intact.
        line = _.trim(line);

        if (line === "") return data;

        // Parse track times first, because they could be confused with track
        // numbers if the line only contains a time.

        // Assume the track time is at the end.
        var match = line.match(this.trackTime);

        if (match !== null) {
            if (options.trackTimes && match[1] !== "?:??") {
                data.formattedLength = MB.utility.fullWidthConverter(match[1]);
                data.length = MB.utility.unformatTrackLength(data.formattedLength);
            }
            // Remove the track time from the line.
            line = line.slice(0, -match[0].length);
        }

        // Parse the track number.
        if (options.trackNumbers) {
            match = options.vinylNumbers ? line.match(this.vinylNumber)
                                         : line.match(this.trackNumber);

            // There should always be a track number if this option's set.
            if (match === null) return {};

            data.number = MB.utility.fullWidthConverter(match[1]);

            if (/^\d+$/.test(data.number)) {
                data.number = data.number.replace(/^0+(\d+)/, "$1");
            }

            // Remove the track number from the line.
            line = line.slice(match[0].length);
        }

        // Parse the track title and artist.
        if (!options.trackArtists) {
            data.name = _.clean(line);
            return data;
        }

        // Split the string into parts, if there are any.
        var parts = line.split(this.separators),
            names = _.reject(parts, this.separatorOrBlank, this);

        // Only parse an artist if there's more than one name. Assume the
        // artist is the last name.

        if (names.length > 1) {
            data.artist = names.pop();

            // Use whatever's left as the name, including any separators.
            data.name = _.trim(
                _.first(parts, _.lastIndexOf(parts, data.artist)).join(""),
                this.separators
            );
        }
        else {
            data.name = _.clean(line);
        }

        // Either of these could be the artist name (they may have to be
        // swapped by the user afterwards), so run `cleanArtistName` on both.

        data.name = this.cleanArtistName(data.name || "");
        data.artist = this.cleanArtistName(data.artist || "");

        return data;
    },

    separatorOrBlank: function (str) {
        return this.separators.test(str) || _.isBlank(str);
    },

    cleanArtistName: function (name) {
        return _.clean(name)
            // Artist, The -> The Artist
            .replace(/(.*),\sThe$/i, "The $1")
            .replace(/\s*,/g, ",");
    },

    mediumToString: function (medium) {
        var options = ko.toJS(this.options);

        return _.reduce(medium.tracks(), function (memo, track) {
            if (options.trackNumbers) {
                memo += track.number.peek() + ". ";
            }

            memo += track.name.peek() || "";

            if (options.trackArtists) {
                var artist = track.artistCredit.text();

                if (artist) memo += " - " + artist;
            }

            if (options.trackTimes) {
                var length = track.formattedLength.peek();

                memo += " (" + (length || "?:??") + ")";
            }

            return memo + "\n";
        }, "");
    }
};
