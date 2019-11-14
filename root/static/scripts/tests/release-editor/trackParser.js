// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import test from 'tape';

import {reduceArtistCredit} from '../../common/immutable-entities';
import fields from '../../release-editor/fields';
import trackParser from '../../release-editor/trackParser';
import releaseEditor from '../../release-editor/viewModel';

import * as common from './common';

function parserTest(name, callback) {
    test(name, function (t) {
        trackParser.options = {
            hasTrackNumbers: false,
            hasVinylNumbers: false,
            hasTrackArtists: false,
            useTrackNumbers: false,
            useTrackArtists: false,
            useTrackNames: false,
            useTrackLengths: false,
        };
        callback(t);
    });
}

parserTest('track numbers', function (t) {
    t.plan(1);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        hasVinylNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = [
        'a1  Kermis         02:04',
        'a2.  Glitch        02:51',
        'a3.Afrik Slang     02:11',
        '4 Rot Beat         01:07',
        '5. Pruik           02:21',
        '6.In Je Graff      03:21',
        '７ Ｈｉｌｌｗｏｏｄ   ０２：３４',
    ]
    .join('\n');

    common.trackParserTest(t, input, [
        {position: 1, number: 'a1', name: 'Kermis'},
        {position: 2, number: 'a2', name: 'Glitch'},
        {position: 3, number: 'a3', name: 'Afrik Slang'},
        {position: 4, number: '4', name: 'Rot Beat'},
        {position: 5, number: '5', name: 'Pruik'},
        {position: 6, number: '6', name: 'In Je Graff'},
        {position: 7, number: '7', name: 'Ｈｉｌｌｗｏｏｄ'},
    ]);
});

parserTest('parsing track durations with trailing whitespace (MBS-1284)', function (t) {
    t.plan(1);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = [
        '1. Forgotten Child    3:39    ',
        '2. Dirty Looks  4:34   ',
        '  3. Private Life  3:29  ',
        '4.  Never Can Wait  3:24 ',
    ]
    .join('\n');

    /* eslint-disable no-multi-spaces */
    common.trackParserTest(t, input, [
        {position: 1, name: 'Forgotten Child', formattedLength: '3:39'},
        {position: 2, name: 'Dirty Looks',     formattedLength: '4:34'},
        {position: 3, name: 'Private Life',    formattedLength: '3:29'},
        {position: 4, name: 'Never Can Wait',  formattedLength: '3:24'},
    ]);
    /* eslint-enable no-multi-spaces */
});

parserTest('numbers at the end of track names being wrongly interpreted as durations (MBS-2511, MBS-2902)', function (t) {
    t.plan(1);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = [
        '1. Criminology 2.5',
        '2. Love On A .45',
    ]
    .join('\n');

    common.trackParserTest(t, input, [
        {position: 1, name: 'Criminology 2.5', formattedLength: ''},
        {position: 2, name: 'Love On A .45', formattedLength: ''},
    ]);
});

parserTest("ignoring lines that don't start with a number when the option is set (MBS-2540)", function (t) {
    t.plan(1);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = '\
        1 Freeman Hardy & Willis Acid\n\n\
           Written-By – James*, Jenkinson* \n\n\
        5:42\n\
        2 Orange Romeda\n\n\
        Written-By – Eoin*, Sandison* \n\n\
        4:51 \n\
    ';

    common.trackParserTest(t, input, [
        {position: 1, name: 'Freeman Hardy & Willis Acid', formattedLength: ''},
        {position: 2, name: 'Orange Romeda', formattedLength: ''},
    ]);
});

parserTest('XX:XX:XX track times (MBS-3353)', function (t) {
    t.plan(1);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = '1. Love On A .45  05:22:31';

    common.trackParserTest(t, input, [
        {position: 1, name: 'Love On A .45', formattedLength: '5:22:31'},
    ]);
});

parserTest('internal track positions are updated appropriately after being reused', function (t) {
    t.plan(2);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var re = releaseEditor;
    releaseEditor.rootField.release(new fields.Release(common.testRelease));

    var release = releaseEditor.rootField.release();
    var medium = release.mediums()[0];

    medium.cdtocs = [];
    medium.toc(null);

    var input = trackParser.mediumToString(medium).split('\n').reverse().join('\n');

    medium.tracks(trackParser.parse(input, medium));

    var tracks = medium.tracks();

    t.equal(tracks[0].position(), 1, 'track 1 has position 1');
    t.equal(tracks[1].position(), 2, 'track 2 has position 2');
});

parserTest('MBS-7451: track parser can clear TOC track lengths', function (t) {
    t.plan(1);

    var re = releaseEditor;
    releaseEditor.rootField.release(new fields.Release(common.testRelease));

    var release = releaseEditor.rootField.release();
    var medium = release.mediums()[0];

    medium.cdtocs = ['1'];

    trackParser.options.useTrackLengths = true;

    // The string does not include track numbers.
    var input = trackParser.mediumToString(medium);

    // Re-enable track numbers so that parsing anything fails.
    trackParser.options.hasTrackNumbers = true;

    medium.tracks(trackParser.parse(input, medium));

    var tracks = medium.tracks();

    t.deepEqual(
        _.invokeMap(tracks, 'length'),
        _.map(medium.original().tracklist, 'length'),
        'track lengths are unchanged',
    );
});

parserTest('can parse only numbers, titles, artists, or lengths (MBS-3730, MBS-3732)', function (t) {
    t.plan(16);

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        hasVinylNumbers: true,
        hasTrackArtists: true,
        useTrackNumbers: true,
    });

    var release = new fields.Release({
        mediums: [{
            tracks: [{
                number: '1',
                name: 'foo',
                artistCredit: {names: [{name: 'bar'}]},
                length: 180000,
            }],
        }],
    });

    releaseEditor.rootField.release(release);

    // Parse only numbers
    var medium = release.mediums()[0];
    medium.tracks(trackParser.parse('A1. FOO! - BAR! (2:55)', medium));

    var track = medium.tracks()[0];
    t.equal(track.number(), 'A1', 'number was used');
    t.equal(track.name(), 'foo', 'name was not used');
    t.equal(reduceArtistCredit(track.artistCredit()), 'bar', 'artist was not used');
    t.equal(track.formattedLength(), '3:00', 'length was not used');

    // Parse only titles
    Object.assign(trackParser.options, {
        useTrackNumbers: false,
        useTrackNames: true,
    });

    medium.tracks(trackParser.parse('B1. FOO! - BAR! (2:55)', medium));

    track = medium.tracks()[0];
    t.equal(track.number(), 'A1', 'number was not used');
    t.equal(track.name(), 'FOO!', 'name was used');
    t.equal(reduceArtistCredit(track.artistCredit()), 'bar', 'artist was not used');
    t.equal(track.formattedLength(), '3:00', 'length was not used');

    // Parse only artists
    Object.assign(trackParser.options, {
        useTrackNames: false,
        useTrackArtists: true,
    });

    medium.tracks(trackParser.parse('B1. oof - BAR! (2:55)', medium));

    track = medium.tracks()[0];
    t.equal(track.number(), 'A1', 'number was not used');
    t.equal(track.name(), 'FOO!', 'name was not used');
    t.equal(reduceArtistCredit(track.artistCredit()), 'BAR!', 'artist was used');
    t.equal(track.formattedLength(), '3:00', 'length was not used');

    // Parse only lengths
    Object.assign(trackParser.options, {
        useTrackArtists: false,
        useTrackLengths: true,
    });

    medium.tracks(trackParser.parse('B1. oof - rab (2:55)', medium));

    track = medium.tracks()[0];
    t.equal(track.number(), 'A1', 'number was not used');
    t.equal(track.name(), 'FOO!', 'name was not used');
    t.equal(reduceArtistCredit(track.artistCredit()), 'BAR!', 'artist was not used');
    t.equal(track.formattedLength(), '2:55', 'length was used');
});

parserTest('Does not lose previous recordings (MBS-7719)', function (t) {
    t.plan(11);

    var trackParser = releaseEditor.trackParser;

    Object.assign(trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
    });

    var release = new fields.Release({
        mediums: [
            {
                tracks: [
                    {
                        id: 1,
                        gid: '7aeebcb5-cc99-4c7f-82bc-f2da35200081',
                        name: 'Old Track 1',
                        recording: {
                            gid: 'adbd01f7-7d69-43cc-95b5-d3a163be44ef',
                            name: 'Old Recording 1',
                        },
                    },
                    {
                        id: 2,
                        gid: '8a45fd90-3ee0-4344-ad07-97187950112d',
                        name: 'Old Track 2',
                        recording: {
                            gid: '81a5d436-d16f-4bff-8be6-5fd29c1ce0fc',
                            name: 'Old Recording 2',
                        },
                    },
                    {
                        id: 3,
                        gid: '5e420411-b097-4d04-8d2e-2d62b7e2e884',
                        name: 'This Track Will Be Moved',
                        recording: {
                            gid: '843910ac-4c11-4c3f-9a8a-1056d161dd2f',
                            name: 'Old Recording 3',
                        },
                    },
                ],
            },
        ],
    });

    releaseEditor.rootField.release(release);
    var medium = release.mediums()[0];
    var oldRecordings = _(medium.tracks()).invokeMap('recording').value();

    medium.tracks(
        trackParser.parse(
            '1. Completely Different Title\n' +
            '2. This Track Will Be Moved\n' +
            '3. Another Completely Different Title',
            medium,
        ),
    );
    var newTracks = medium.tracks();
    var newRecordings = _(newTracks).invokeMap('recording').value();

    t.ok(!newTracks[0].id, 'first track has no id');
    t.ok(!newTracks[0].gid, 'first track has no gid');
    t.notEqual(oldRecordings[0], newRecordings[0], 'first recording is different');
    t.notEqual(oldRecordings[1], newRecordings[1], 'second recording is different');
    t.equal(oldRecordings[2], newRecordings[1], 'third recording is reused from second track');
    t.equal(release.tracksWithUnsetPreviousRecordings().length, 1, 'there’s 1 previous recording available');

    releaseEditor.reuseUnsetPreviousRecordings(release);
    newTracks = medium.tracks();
    newRecordings = _(newTracks).invokeMap('recording').value();

    t.equal(newTracks[0].id, 1, 'previous first track’s id is used');
    t.equal(newTracks[0].gid, '7aeebcb5-cc99-4c7f-82bc-f2da35200081', 'previous first track’s gid is used');
    t.equal(oldRecordings[0], newRecordings[0], 'previous first recording is reused');
    t.notEqual(oldRecordings[1], newRecordings[1], 'second recording is still different');
    t.equal(oldRecordings[2], newRecordings[1], 'third recording is still reused from second track');
});

parserTest('parsing fullwidth numbers', function (t) {
    t.plan(1);

    Object.assign(releaseEditor.trackParser.options, {
        hasTrackNumbers: true,
        useTrackNumbers: true,
        useTrackNames: true,
        useTrackLengths: true,
    });

    var input = '１ Ｆｏｏ ２：３４';

    common.trackParserTest(t, input, [
        {position: 1, name: 'Ｆｏｏ', formattedLength: '2:34'},
    ]);
});

parserTest("parses track times for data tracks if there's a disc ID (MBS-8409)", function (t) {
    t.plan(2);

    var trackParser = releaseEditor.trackParser;
    Object.assign(trackParser.options, {useTrackLengths: true});

    var release = new fields.Release({
        id: 1,
        mediums: [
            {
                id: 1,
                cdtocs: ['fake'],
                tracks: [
                    {
                        id: 1,
                        gid: '33705d86-ab4f-4bed-9a6c-1a690df7e70b',
                        name: 'Track 1',
                        length: 12000,
                    },
                    {
                        id: 2,
                        gid: 'bd43814d-096d-48d7-8ff8-634baa0a8aa6',
                        name: 'Track 2',
                        length: 0,
                        isDataTrack: true,
                    },
                ],
            },
        ],
    });

    releaseEditor.rootField.release(release);

    var medium = release.mediums()[0];
    var tracks = medium.tracks();

    medium.tracks(trackParser.parse('1:23\n2:34', medium));
    t.equal(tracks[0].length(), 12000, 'length of non-data track did not change');
    t.equal(tracks[1].length(), 154000, 'length of data track changed');
});

parserTest('data track boundary is unchanged if the track count is >= the previous one (MBS-8410)', function (t) {
    t.plan(1);

    var trackParser = releaseEditor.trackParser;
    trackParser.options.useTrackNames = true;

    var release = new fields.Release({
        id: 1,
        mediums: [
            {
                id: 1,
                tracks: [
                    {id: 1, name: 'Track A'},
                    {id: 2, name: 'Track B', isDataTrack: true},
                ],
            },
        ],
    });

    releaseEditor.rootField.release(release);

    var medium = release.mediums()[0];
    medium.tracks(trackParser.parse('Track B\nTrack A\nCool Bonus Vid', medium));

    t.deepEqual(
        _.map(medium.tracks(), function (t) {
            return {id: t.id, name: t.name(), isDataTrack: t.isDataTrack()};
        }),
        [
            {id: 2, name: 'Track B', isDataTrack: false},
            {id: 1, name: 'Track A', isDataTrack: true},
            {id: undefined, name: 'Cool Bonus Vid', isDataTrack: true},
        ],
    );
});

parserTest('force number of tracks to equal CD TOC', function (t) {
    t.plan(3);

    trackParser.options.useTrackNames = true;

    var release = new fields.Release({
        id: 1,
        mediums: [
            {
                id: 1,
                cdtocs: ['fake'],
                tracks: [
                    {id: 1, name: 'Track A'},
                    // data tracks should not be included in count
                    {id: 2, name: 'Track B', isDataTrack: true},
                ],
            },
        ],
    });

    releaseEditor.rootField.release(release);

    var medium = release.mediums()[0];
    medium.tracks(trackParser.parse(
        'Track A\n' +
        'Very Different Title\n' +
        'Another Data Track',
        medium,
    ));

    t.equal(medium.audioTracks().length, 1);
    t.equal(medium.dataTracks().length, 2);
    t.deepEqual(_.invokeMap(medium.tracks(), 'name'), ['Track A', 'Very Different Title', 'Another Data Track']);
});
