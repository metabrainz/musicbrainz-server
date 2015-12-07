// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2010-2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var _ = require('lodash');
var getSimilarity = require('../edit/utility/similarity');
var clean = require('../common/utility/clean');
var isBlank = require('../common/utility/isBlank');
var getCookie = require('../common/utility/getCookie');
var setCookie = require('../common/utility/setCookie');
import {MIN_NAME_SIMILARITY} from '../common/constants';

MB.releaseEditor = MB.releaseEditor || {};


MB.releaseEditor.trackParser = {

    // These are all different types of dash
    separators: /(\s+[\-‒–—―]\s+|\s*\t\s*)/,

    // Leading "M." is for Japanese releases. MBS-3398
    trackNumber: /^(?:M[\.\-])?([０-９0-9]+(?:-[０-９0-9]+)?)(?:\.|．|\s?-|:|：|;|,|，|$)?/,
    vinylNumber: /^([０-９0-9a-z]+)(?:\/[０-９0-9a-z]+)?(?:\.|．|\s?-|:|：|;|,|，|$)?/i,

    trackTime: /\(?((?:[0-9０-９]+[：，．':,.])?[0-9０-９\?]+[：，．':,.][0-5０-５\?][0-9０-９\?])\)?$/,

    options: {
        hasTrackNumbers: optionCookie("trackparser_tracknumbers", true),
        hasTrackArtists: optionCookie("trackparser_trackartists", true),
        hasVinylNumbers: optionCookie("trackparser_vinylnumbers", true),
        useTrackNumbers: optionCookie("trackparser_usetracknumbers", true),
        useTrackNames: optionCookie("trackparser_usetracknames", true),
        useTrackArtists: optionCookie("trackparser_usetrackartists", true),
        useTrackLengths: optionCookie("trackparser_tracktimes", true)
    },

    parse: function (str, medium) {
        var self = this;

        var options = ko.toJS(this.options);
        var lines = _.reject(str.split('\n'), isBlank);

        var currentPosition = (medium && medium.hasPregap()) ? -1 : 0;
        var currentTracks;
        var previousTracks = [];
        var matchedTracks = {};
        var dataTrackPairs = [];
        var hasTocs;
        var releaseAC;

        // Mediums aren't passed in for unit tests.
        if (medium) {
            currentTracks = medium.tracks.peek().slice(0);
            previousTracks = currentTracks.slice(0);
            hasTocs = medium.hasToc();
            releaseAC = medium.release.artistCredit;

            // Don't add more tracks than the CDTOC allows. If there are data
            // tracks, then more can be added at the end.
            if (hasTocs && !medium.hasDataTracks()) {
                lines = lines.slice(0, currentTracks.length);
            }
        }

        var newTracksData = $.map(lines, function (line) {
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

            if (!currentTracks || !currentTracks.length) return data;

            // Check for tracks with similar names to existing tracks, so that
            // we can reuse them if possible. If the medium has a CDTOC, don't
            // do this because we can't move tracks around. Also don't do this
            // if the user says not to use track names.

            if (hasTocs || !options.useTrackNames) {
                data.matchedTrack = currentTracks.shift();
            } else {
                // Pair every parsed track object with every existing track,
                // along with their similarity.
                dataTrackPairs = dataTrackPairs.concat(
                    _(currentTracks)
                        .map(function (track) {
                            return self.matchDataWithTrack(data, track);
                        })
                        .compact().value()
                );
            }

            return data;
        });

        _(dataTrackPairs).sortBy("similarity").reverse()
            .each(function (match) {
                var data = match.data;
                var track = match.track;

                if (!data.matchedTrack && !matchedTracks[track.uniqueID]) {
                    data.matchedTrack = track;
                    matchedTracks[track.uniqueID] = 1;
                }
            })
            .value();

        var newTracks = _.map(newTracksData, function (data, index) {
            var matchedTrack = data.matchedTrack;
            var previousTrack = previousTracks[index];
            var matchedTrackAC = matchedTrack && matchedTrack.artistCredit;
            var previousTrackAC = previousTrack && previousTrack.artistCredit;

            // See if we can re-use the AC from the matched track, the previous
            // track at this position, or the release.
            var matchedAC = _.find([ matchedTrackAC, previousTrackAC, releaseAC ],
                function (ac) {
                    if (!ac || ac.isVariousArtists()) return false;

                    var names = ac.names();

                    return ac.isComplete() && (!data.artist ||
                        MB.releaseEditor.utils.similarNames(data.artist, ac.text()));
                }
            );

            if (matchedAC) {
                data.artistCredit = matchedAC.toJSON();
            }

            data.artistCredit = data.artistCredit || [{ name: data.artist || "" }];

            // If the AC has just a single artist, we can re-use the parsed
            // artist text as the credited name for that artist. Otherwise we
            // can't easily do anything with it because the parsed text likely
            // contains bits for every artist.
            if (data.artist && data.artistCredit.length === 1) {
                data.artistCredit[0].name = data.artist;
            }

            if (matchedTrack) {
                matchedTrack.position(data.position);

                if (options.useTrackNumbers) {
                    matchedTrack.number(data.number ? data.number : data.position);
                }

                if (options.useTrackNames) {
                    matchedTrack.name(data.name);
                }

                if (options.useTrackLengths && (!hasTocs || matchedTrack.isDataTrack.peek()) && data.formattedLength) {
                    matchedTrack.formattedLength(data.formattedLength);
                }

                if (options.useTrackArtists) {
                    matchedTrack.artistCredit.setNames(data.artistCredit);
                }

                return matchedTrack;
            }

            return MB.releaseEditor.fields.Track(data, medium);
        });

        if (medium) {
            currentTracks = medium.tracks.peek();

            var currentTrackCount = currentTracks.length;
            var difference = newTracks.length - currentTrackCount;
            var oldAudioTrackCount = medium.audioTracks.peek().length;

            // Make sure data tracks are contiguous at the end of the medium.
            if (medium.hasDataTracks()) {
                var dataTracksEnded = false;

                _.each(newTracks.slice(0).reverse(), function (t, index) {
                    // Don't touch the data track boundary if the total number
                    // of tracks is >= the previous number. The user can edit
                    // things manually if it needs fixing. Since we're
                    // iterating backwards, the condition is checking that we
                    // don't exceed the point where the audio tracks end.
                    if (difference >= 0) {
                        t.isDataTrack(index < (newTracks.length - oldAudioTrackCount));
                    // Otherwise, keep isDataTrack true for ones that stayed at
                    // the end, but unset it if they somehow moved up in the
                    // tracklist and are no longer contiguous.
                    } else if (dataTracksEnded) {
                        t.isDataTrack(false);
                    } else if (!t.isDataTrack()) {
                        dataTracksEnded = true;
                    }
                });
            }

            // Force a minimum number of audio tracks if there's a CDTOC.
            var newAudioTrackCount = _.sum(newTracks, function (t) {
                return t.isDataTrack() ? 0 : 1;
            });

            if (hasTocs && newAudioTrackCount < oldAudioTrackCount) {
                difference = oldAudioTrackCount - newAudioTrackCount;

                newTracks.splice.apply(
                    newTracks,
                    [newAudioTrackCount, 0].concat(_.times(difference, function (n) {
                        return MB.releaseEditor.fields.Track({
                            length: currentTracks[newAudioTrackCount + n].length.peek()
                        }, medium);
                    }))
                );

                _.each(newTracks, function (t, index) {
                    t.position(index + 1);
                });
            }
        }

        // MBS-7719: make sure the "Reuse previous recordings" button is
        // available for new tracks by saving any unset recordings onto the
        // new track instances.
        if (previousTracks && previousTracks.length) {
            _.each(newTracks, function (track, index) {
                delete track.previousTrackAtThisPosition;

                var previousTrack = previousTracks[index];

                // Don't save the recording that was at this position if the
                // *track* that was at this position was moved/reused.
                if (previousTrack && !matchedTracks[previousTrack.uniqueID]) {
                    var previousRecording = previousTrack.recording.peek();

                    if (previousRecording && previousRecording.gid) {
                        var currentRecording = track.recording.peek();

                        if (currentRecording !== previousRecording) {
                            track.recording.saved = previousRecording;
                            track.hasNewRecording(false);
                        }
                    }

                    // Save track ids, too.
                    if (previousTrack.gid) {
                        track.previousTrackAtThisPosition = {
                            id: previousTrack.id,
                            gid: previousTrack.gid
                        };
                    }
                }
            });
        }

        return newTracks;
    },

    parseLine: function (line, options) {
        var data = {};

        // trim only, keeping tabs and other space separators intact.
        line = line.trim();

        if (line === "") return data;

        // Parse track times first, because they could be confused with track
        // numbers if the line only contains a time.

        // Assume the track time is at the end.
        var match = line.match(this.trackTime);

        if (match !== null) {
            if (options.useTrackLengths && match[1] !== "?:??") {
                data.formattedLength = fullWidthConverter(match[1]);
                data.length = MB.releaseEditor.utils.unformatTrackLength(data.formattedLength);
            }
            // Remove the track time from the line.
            line = line.slice(0, -match[0].length);
        }

        // Parse the track number.
        if (options.hasTrackNumbers) {
            match = line.match(options.hasVinylNumbers ? this.vinylNumber : this.trackNumber);

            // There should always be a track number if this option's set.
            if (match === null) return {};

            if (options.useTrackNumbers) {
                data.number = fullWidthConverter(match[1]);

                if (/^\d+$/.test(data.number)) {
                    data.number = data.number.replace(/^0+(\d+)/, "$1");
                }
            }

            // Remove the track number from the line.
            line = line.slice(match[0].length);
        }

        // Parse the track title and artist.
        if (!options.hasTrackArtists) {
            if (options.useTrackNames) {
                data.name = clean(line);
            }
            return data;
        }

        // Split the string into parts, if there are any.
        var parts = line.split(this.separators),
            names = _.reject(parts, this.separatorOrBlank, this);

        // Only parse an artist if there's more than one name. Assume the
        // artist is the last name.

        if (names.length > 1) {
            var artist = names.pop();

            if (options.useTrackArtists) {
                data.artist = artist;
            }

            if (options.useTrackNames) {
                // Use whatever's left as the name, including any separators.
                var withoutArtist = _.take(parts, _.lastIndexOf(parts, artist));

                data.name = withoutArtist.join("")
                    .replace(new RegExp('^' + this.separators.source), '')
                    .replace(new RegExp(this.separators.source + '$'), '');
            }
        } else if (options.useTrackNames) {
            data.name = clean(line);
        }

        // Either of these could be the artist name (they may have to be
        // swapped by the user afterwards), so run `cleanArtistName` on both.

        if (options.useTrackNames) {
            data.name = this.cleanArtistName(data.name || "");
        }

        if (options.useTrackArtists) {
            data.artist = this.cleanArtistName(data.artist || "");
        }

        return data;
    },

    separatorOrBlank: function (str) {
        return this.separators.test(str) || isBlank(str);
    },

    cleanArtistName: function (name) {
        return clean(name)
            // Artist, The -> The Artist
            .replace(/(.*),\sThe$/i, "The $1")
            .replace(/\s*,/g, ",");
    },

    mediumToString: function (medium) {
        var options = ko.toJS(this.options);

        return _.reduce(medium.tracks(), function (memo, track) {
            if (options.hasTrackNumbers) {
                memo += track.number.peek() + ". ";
            }

            memo += track.name.peek() || "";

            if (options.hasTrackArtists) {
                var artist = track.artistCredit.text();

                if (artist) memo += " - " + artist;
            }

            memo += " (" + (track.formattedLength.peek() || "?:??") + ")";

            return memo + "\n";
        }, "");
    },

    matchDataWithTrack: function (data, track) {
        if (!track) return;

        var similarity = getSimilarity(data.name, track.name.peek());

        if (similarity >= MIN_NAME_SIMILARITY) {
            return { similarity: similarity, track: track, data: data };
        }
    }
};

function optionCookie(name, defaultValue) {
    var existingValue = getCookie(name);

    var observable = ko.observable(
        defaultValue ? existingValue !== "false" : existingValue === "true"
    );

    observable.subscribe(function (newValue) {
        setCookie(name, newValue);
    });

    return observable;
}

/* Convert fullwidth characters to standard halfwidth Latin. */
function fullWidthConverter(inputString) {
    if (inputString === "") {
        return "";
    }

    let i = inputString.length;
    let newString = [];

    do {
        newString.push(
            inputString[i-1].replace(/([\uFF01-\uFF5E])/g, function (str, p1) {
                return String.fromCharCode(p1.charCodeAt(0) - 65248);
            })
        );
    } while (--i);

    return newString.reverse().join("");
}

exports.fullWidthConverter = fullWidthConverter;
