// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import {MAX_LENGTH_DIFFERENCE} from '../common/constants';
import {
  isCompleteArtistCredit,
  reduceArtistCredit,
} from '../common/immutable-entities';
import MB from '../common/MB';
import debounce from '../common/utility/debounce';

import releaseEditor from './viewModel';
import utils from './utils';

const recordingAssociation = {};

releaseEditor.recordingAssociation = recordingAssociation;

// This file contains code for finding suggested recording associations
// in the release editor.
//
// Levenshtein is used to compare track & recording titles, and track
// lengths are checked to be within 10s of recording lengths.
//
// Recordings from the same release group are preferred. Since there are
// usually less than 50 recordings in a release group, we request and cache
// all of them as soon as the release group changes. If there is no release
// group (i.e. one isn't selected), all recordings of the selected track's
// artists are searched using the web service.
//
// Direct database search is terrible at matching titles (a single
// apostrophe changes the entire set of results), so indexed search is
// used.

var releaseGroupRecordings = ko.observable(),
    etiRegex = /(\([^)]+\) ?)*$/;


recordingAssociation.getReleaseGroupRecordings = function (releaseGroup, offset, results) {
    if (!releaseGroup || !releaseGroup.gid) return;

    var query = utils.constructLuceneField(
        [utils.escapeLuceneValue(releaseGroup.gid)], "rgid",
    );

    utils.search("recording", query, 100, offset)
        .done(function (data) {
            results.push.apply(
                results, _.map(data.recordings, cleanRecordingData),
            );

            var countSoFar = data.offset + 100;

            if (countSoFar < data.count) {
                recordingAssociation.getReleaseGroupRecordings(releaseGroup, countSoFar, results);
            } else {
                releaseGroupRecordings(results);
            }
        })
        .fail(function () {
            _.delay(recordingAssociation.getReleaseGroupRecordings, 5000, releaseGroup, offset, results);
        });
};


function recordingQuery(track, name) {
    var params = {
        recording: [utils.escapeLuceneValue(name)],

        arid: _(track.artistCredit().names).map('artist.gid')
            .map(utils.escapeLuceneValue).value(),
    };

    var titleAndArtists = utils.constructLuceneFieldConjunction(params);
    var justTitle = utils.constructLuceneField(params.recording, "recording");
    var query = "(" + titleAndArtists + ")^2 OR (" + justTitle + ")";

    var duration = parseInt(track.length(), 10);

    if (duration) {
        var a = duration - MAX_LENGTH_DIFFERENCE;
        var b = duration + MAX_LENGTH_DIFFERENCE;

        duration = utils.constructLuceneField([`[${a} TO ${b}] OR \\-`], 'dur');
        query = "(" + query + ") AND " + duration;
    }

    return query;
}


function cleanRecordingData(data) {
    var clean = utils.cleanWebServiceData(data);

    clean.artist = reduceArtistCredit(clean.artistCredit);
    clean.video = !!data.video;

    var appearsOn = _(data.releases)
        .map(function (release) {
            // The webservice doesn't include the release group title, so
            // we have to use the release title instead.
            return {
                name: release.title,
                gid: release.id,
                releaseGroupGID: release["release-group"].id,
            };
        })
        .uniqBy('releaseGroupGID').value();

    clean.appearsOn = {
        hits: appearsOn.length,
        results: appearsOn,
        entityType: "release",
    };

    // Recording entities will have already been created and cached for
    // any existing recordings on the release. However, /ws/js/release does
    // not provide any appearsOn data. So now that we have it, we can add
    // it in.
    var recording = MB.entityCache[clean.gid];

    if (recording && !recording.appearsOn) {
        recording.appearsOn = _.clone(clean.appearsOn);

        recording.appearsOn.results = _.map(recording.appearsOn.results,
            function (appearance) {
                return MB.entity(appearance, "release");
            });
    }

    return clean;
}


function searchTrackArtistRecordings(track) {
    if (track._recordingRequest) {
        track._recordingRequest.abort();
        delete track._recordingRequest;
    }

    track.loadingSuggestedRecordings(true);

    var query = recordingQuery(track, track.name());

    track._recordingRequest = utils.search("recording", query)
        .done(function (data) {
            var recordings = matchAgainstRecordings(
                track, _.map(data.recordings, cleanRecordingData),
            );

            setSuggestedRecordings(track, recordings || []);
            track.loadingSuggestedRecordings(false);
        })
        .fail(function (jqXHR, textStatus) {
            if (textStatus !== "abort") {
                _.delay(searchTrackArtistRecordings, 5000, track);
            }
        });
}


// Allow the recording search autocomplete to also get better results.
// The standard /ws/js indexed search doesn't support sending artist or
// length info.

recordingAssociation.autocompleteHook = function (track) {
    return function (args) {
        if (args.data.direct) return args;

        var newArgs = {
            url: "/ws/2/recording",
            data: {
                query: recordingQuery(track, args.data.q),
                fmt: "json",
            },
            dataType: "json",
        };

        newArgs.success = function (data) {
            // Emulate the /ws/js response format.
            var newData = _.map(data.recordings, cleanRecordingData);

            newData.push({
                current: (data.offset / 10) + 1,
                pages: Math.ceil(data.count / 10),
            });

            args.success(newData);
        };

        newArgs.error = args.error;
        newArgs.data.limit = 10;
        newArgs.data.offset = (args.data.page - 1) * 10;

        return newArgs;
    };
};


function watchTrackForChanges(track) {
    var name = track.name();
    var length = track.length();

    // We don't compare any artist credit changes, but we use the track
    // artists when searching the web service. If there are track changes
    // below but the AC is not complete, the ko.computed this is inside of
    // will re-evaluate once the user fixes the artist.
    var completeAC = isCompleteArtistCredit(track.artistCredit());

    // Only proceed if we need a recording, and the track has information
    // we can search for - this tab should be disabled otherwise, anyway.
    if (!name || !completeAC) return;

    var similarTo = function (prop) {
        return (utils.similarNames(track.name[prop], name) &&
                utils.similarLengths(track.length[prop], length));
    };

    // The current name/length is similar to the saved name/length.
    if (similarTo("saved")) {
        track.recording(track.recording.saved);
    }
    // The current name/length is similar to the original name/length.
    else if (similarTo("original")) {
        track.recording(track.recording.original.peek());
    }
    else {
        track.recording(null);
    }
}


recordingAssociation.findRecordingSuggestions = function (track) {
    var release = releaseEditor.rootField.release(),
        releaseGroup = release ? release.releaseGroup() : null,
        rgRecordings;

    if (releaseGroup && releaseGroup.gid) {
        // First look in releaseGroupRecordings.
        rgRecordings = releaseGroupRecordings();

        if (!rgRecordings) {
            // If they aren't loaded yet for some reason, wait until they are.

            if (!releaseGroupRecordings.loading) {
                releaseGroupRecordings.loading = releaseGroupRecordings.subscribe(
                    function () {
                        releaseGroupRecordings.loading.dispose();
                        delete releaseGroupRecordings.loading;

                        recordingAssociation.findRecordingSuggestions(track);
                    });
            }
            return;
        }
    }

    var recordings =
            matchAgainstRecordings(track, rgRecordings) ||
            // Or see if it still matches the current suggestion.
            matchAgainstRecordings(track, track.suggestedRecordings());

    if (recordings) {
        setSuggestedRecordings(track, recordings);
    } else {
        // Last resort: search all recordings of all the track's artists.
        searchTrackArtistRecordings(track);
    }
};


// Sets track.suggestedRecordings. If the track currently does not have
// a recording selected, it shifts the last used recording to the top of
// the suggestions list (if there is one).

function setSuggestedRecordings(track, recordings) {
    var lastRecording = track.recording.saved;

    if (!track.hasExistingRecording() && lastRecording) {
        recordings = _.union([lastRecording], recordings);
    }

    track.suggestedRecordings(recordings);
}


function matchAgainstRecordings(track, recordings) {
    if (!recordings || !recordings.length) return;

    var trackLength = track.length();
    var trackName = track.name();

    var matches = _(recordings)
        .filter(function (recording) {
            if (!utils.similarLengths(trackLength, recording.length)) {
                return false;
            }
            if (utils.similarNames(trackName, recording.name)) {
                return true;
            }
            var recordingWithoutETI = recording.name.replace(etiRegex, "");

            if (utils.similarNames(trackName, recordingWithoutETI)) {
                return true;
            }
        })
        .sortBy(function (recording) {
            var appearsOn = recording.appearsOn;
            return appearsOn ? appearsOn.results.length : 0;
        })
        .reverse()
        .sortBy(function (recording) {
            // Prefer that recordings with a length be at the top of the
            // suggestions list.
            if (!recording.length) {
                return MAX_LENGTH_DIFFERENCE + 1;
            }
            if (!trackLength) {
                return MAX_LENGTH_DIFFERENCE;
            }
            return Math.abs(trackLength - recording.length);
        })
        .value();

    if (matches.length) {
        return _.map(matches, function (match) {
            return MB.entity(match, "recording");
        });
    }
}


recordingAssociation.track = function (track) {
    debounce(function () { watchTrackForChanges(track) });
};

export default recordingAssociation;
