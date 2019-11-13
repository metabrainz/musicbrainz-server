// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import test from 'tape';

import validation from '../../edit/validation';
import fields from '../../release-editor/fields';
import releaseEditor from '../../release-editor/viewModel';

import '../../release-editor/init';

function validationTest(name, callback) {
    test(name, function (t) {
        const loadMedia = fields.Release.prototype.loadMedia;
        fields.Release.prototype.loadMedia = _.noop;

        callback(t);

        validation.errorFields([]);
        fields.Release.prototype.loadMedia = loadMedia;
    });
}

validationTest("non-loaded mediums validate, even though they have no tracks (MBS-7222)", function (t) {
    t.plan(8);

    releaseEditor.action = "edit";

    releaseEditor.releaseLoaded({
        mediums: [
            {id: 123, position: 1, tracks: []},
        ],
    });

    var release = releaseEditor.rootField.release(),
        medium = release.mediums()[0];

    t.ok(!medium.loaded(), "medium is not loaded");
    t.ok(!medium.needsTracks(), "medium doesn't require tracks");
    t.ok(!medium.needsTrackInfo(), "medium doesn't require track info");
    t.ok(!medium.needsRecordings(), "medium doesn't require recordings");
    t.ok(!release.needsMediums(), "release doesn't need mediums");
    t.ok(!release.needsTracks(), "release doesn't need tracks");
    t.ok(!release.needsTrackInfo(), "release doesn't need track info");
    t.ok(!release.needsRecordings(), "release doesn't need recordings");
});

validationTest("duplicate release countries are rejected, including null ones (MBS-7624)", function (t) {
    t.plan(5);

    releaseEditor.action = "edit";

    releaseEditor.releaseLoaded({
        events: [
            {countryID: 123, date: {year: 1999}},
            {countryID: 123, date: {year: 2000}},
            {countryID: null, date: {year: 1999}},
            {countryID: null, date: {year: 2000}},
        ],
    });

    var release = releaseEditor.rootField.release();
    var events = release.events();

    t.ok(events[0].isDuplicate());
    t.ok(events[1].isDuplicate());
    t.ok(events[2].isDuplicate());
    t.ok(events[3].isDuplicate());
    t.ok(validation.errorsExist());
});

validationTest('duplicate label/catalog number pairs are rejected (MBS-8137)', function (t) {
    t.plan(9);

    releaseEditor.action = 'edit';

    var label1 = {name: 'Foo', id: 123};
    var label2 = {name: 'Bar', id: 456};

    releaseEditor.releaseLoaded({
        labels: [
            {label: label1, catalogNumber: 'ABC-123'},
            {label: label1, catalogNumber: 'ABC-123'},
            {label: null, catalogNumber: 'ABC-456'},
            {label: null, catalogNumber: 'ABC-456'},
            {label: label2, catalogNumber: null},
            {label: label2, catalogNumber: null},
            {label: null, catalogNumber: null},
            {label: null, catalogNumber: null},
        ],
    });

    var labels = releaseEditor.rootField.release().labels();

    t.ok(labels[0].isDuplicate());
    t.ok(labels[1].isDuplicate());
    t.ok(labels[2].isDuplicate());
    t.ok(labels[3].isDuplicate());
    t.ok(labels[4].isDuplicate());
    t.ok(labels[5].isDuplicate());

    // Empty release labels aren't duplicates of each other, they're ignored
    t.ok(!labels[6].isDuplicate());
    t.ok(!labels[7].isDuplicate());

    t.ok(validation.errorsExist());
});
