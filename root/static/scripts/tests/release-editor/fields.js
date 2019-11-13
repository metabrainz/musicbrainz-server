// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import test from 'tape';

import fields from '../../release-editor/fields';

import * as common from './common';

import '../../common/MB/Control/Autocomplete';

function fieldTest(name, callback) {
    test(name, function (t) {
        callback(t, common.setupReleaseAdd());
    });
}

fieldTest("release group types being preserved after editing the name", function (t, release) {
    t.plan(2);

    var releaseGroup = release.releaseGroup;
    releaseGroup().typeID(3);
    releaseGroup().secondaryTypeIDs([1, 3, 5]);

    var $autocomplete = $("<input/>").val("foo");

    ko.applyBindingsToNode($autocomplete[0], {
        autocomplete: {
            entity: "release-group",
            currentSelection: releaseGroup,
            entityConstructor: fields.ReleaseGroup,
        },
    });

    $autocomplete.val("bar").trigger("input");

    t.equal(releaseGroup().typeID(), 3, "primary type is preserved");
    t.deepEqual(releaseGroup().secondaryTypeIDs(), [1, 3, 5], "secondary types are preserved");

    $autocomplete.entitylookup("destroy");
});

fieldTest("mediums having their \"loaded\" observable set correctly", function (t, release) {
    t.plan(6);

    var mediums = release.mediums;

    mediums([
        new fields.Medium({ tracks: [] }),
        new fields.Medium({ tracks: [{}] }),
        new fields.Medium({ id: 1, tracks: [] }),
        new fields.Medium({ originalID: 1, tracks: [] }),
        new fields.Medium({ id: 1, tracks: [{}] }),
        new fields.Medium({ originalID: 1, tracks: [{}] }),
    ]);

    t.equal(mediums()[0].loaded(), true, "medium without id or tracks is considered loaded");
    t.equal(mediums()[1].loaded(), true, "medium without id but with tracks is considered loaded");
    t.equal(mediums()[2].loaded(), false, "medium with id but without tracks is considered not loaded")
    t.equal(mediums()[3].loaded(), false, "medium with originalID but without tracks is considered not loaded");
    t.equal(mediums()[4].loaded(), true, "medium with id and with tracks is considered loaded")
    t.equal(mediums()[5].loaded(), true, "medium with originalID and with tracks is considered loaded");

});

fieldTest("loading a medium doesn't overwrite its original edit data", function (t, release) {
    t.plan(11);

    var medium = new fields.Medium({
        id: 123,
        position: 1,
        formatID: 1,
        name: "foo",
        tracks: [],
    }, release);

    release.mediums([medium]);

    medium.position(2);
    medium.formatID(2);
    medium.name("bar");

    t.ok(!medium.loaded(), "medium is not loaded");

    var original = medium.original();

    t.equal(original.position, 1, "original position is 1");
    t.equal(original.format_id, 1, "original format_id is 1");
    t.equal(original.name, "foo", "original name is foo");

    medium.tracksLoaded({
        tracks: [{ position: 1, name: "~fooo~", length: 12345 }],
    });

    t.ok(medium.loaded(), "medium is loaded");

    original = medium.original();

    t.equal(original.position, 1, "original position is still 1");
    t.equal(original.format_id, 1, "original format_id is still 1");
    t.equal(original.name, "foo", "original name is still foo");

    var loadedTrack = original.tracklist[0];

    t.equal(loadedTrack.position, 1, "loaded track position is 1");
    t.equal(loadedTrack.name, "~fooo~", "loaded track name is ~foooo~");
    t.equal(loadedTrack.length, 12345, "loaded track length is 12345");
});

fieldTest("data tracks are appended with a correct position if there's a pregap (MBS-8013)", function (t, release) {
    t.plan(1);

    var medium = new fields.Medium({ tracks: [] }, release);
    medium.hasPregap(true);
    medium.hasDataTracks(true);

    t.equal(medium.tracks()[1].position(), 1);
});

fieldTest("tracks are set correctly when the cdtoc is changed", function (t, release) {
    t.plan(7);

    function lengthsAndPositions() {
        return _.map(medium.tracks(), function (t) {
            return { length: t.length(), position: t.position() };
        });
    }

    var toc1 = "1 7 171327 150 22179 49905 69318 96240 121186 143398";
    var toc2 = "1 5 180562 150 28552 55959 88371 125305";

    var tocData1 = [
        { length: 294000, position: 1 },
        { length: 370000, position: 2 },
        { length: 259000, position: 3 },
        { length: 359000, position: 4 },
        { length: 333000, position: 5 },
        { length: 296000, position: 6 },
        { length: 372000, position: 7 },
    ];

    var tocData2 = [
        { length: 379000, position: 1 },
        { length: 365000, position: 2 },
        { length: 432000, position: 3 },
        { length: 492000, position: 4 },
        { length: 737000, position: 5 },
    ];

    var medium = new fields.Medium({ tracks: [] }, release);

    // 7 tracks added
    medium.toc(toc1);
    t.deepEqual(lengthsAndPositions(), tocData1);

    // 2 tracks removed, lengths are changed
    medium.toc(toc2);
    t.deepEqual(lengthsAndPositions(), tocData2);

    // 2 tracks added, pregap doesn't affect positions
    medium.hasPregap(true);
    medium.toc(toc1);
    t.deepEqual(lengthsAndPositions(), Array.prototype.concat({ length: undefined, position: 0 }, tocData1));

    // 2 tracks removed, data tracks left at end
    medium.hasDataTracks(true);
    medium.toc(toc2);
    t.deepEqual(
        lengthsAndPositions(),
        Array.prototype.concat({ length: undefined, position: 0 }, tocData2, { length: undefined, position: 6 }),
    );
    t.ok(_.last(medium.tracks()).isDataTrack());

    // 2 tracks added, data tracks left at end
    medium.toc(toc1);
    t.deepEqual(
        lengthsAndPositions(),
        Array.prototype.concat({ length: undefined, position: 0 }, tocData1, { length: undefined, position: 8 }),
    );
    t.ok(_.last(medium.tracks()).isDataTrack());
});

fieldTest("track times entered as integers are converted into HH:MM:SS", function (t, release) {
    t.plan(11);

    var medium = new fields.Medium({ tracks: [{}] }, release);

    const tests = [
        {input: "5", output: "0:05"},
        {input: "69", output: "1:09"},
        {input: "174", output: "2:54"},
        {input: "6000", output: "1:00:00"},
        {input: "7400", output: "1:14:00"},
        {input: "7482", output: "2:04:42"},
        {input: "10000", output: "1:00:00"},
        {input: "96900", output: "26:55:00"},
        {input: "160000", output: "16:00:00"},
        {input: "166000", output: "46:06:40"},
        {input: "3723494", output: "1034:18:14"},
    ];

    tests.forEach(({input, output}) => {
        medium.tracks()[0].formattedLengthChanged(input);
        t.equal(medium.tracks()[0].formattedLength(), output, "length " + input + " is formatted as " + output);
    });
});
