// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import '../typeInfo';

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import test from 'tape';

import MB from '../../common/MB';
import validation from '../../edit/validation';
import fields from '../../release-editor/fields';

import * as common from './common';

var releaseEditor = MB.releaseEditor;
MB.formatsWithDiscIDs = [1];

function addReleaseTest(name, callback) {
    test(name, function (t) {
        var data = $.extend(true, {}, common.testRelease);
        var medium = data.mediums[0];

        medium.originalID = medium.id;

        delete medium.id;
        delete data.labels[0].id;
        delete data.labels[1].id;

        callback(t, common.setupReleaseAdd(data));

        MB.entityCache = {};
        validation.errorFields([]);
    });
}

test("releaseReorderMediums edits are not generated for new releases", function (t) {
    t.plan(1);

    var release = new fields.Release({
        mediums: [
            {position: 1, tracks: [{name: "foo"}]},
            {position: 2, tracks: [{name: "bar"}]},
        ],
    });

    releaseEditor.rootField.release(release);

    common.createMediums(release);

    t.equal(releaseEditor.edits.mediumReorder(release).length, 0);
});

test("MBS-7453: release group edits strip whitespace from name", function (t) {
    t.plan(1);

    var release = new fields.Release({name: "  Foo  oo "});

    t.equal(releaseEditor.edits.releaseGroup(release)[0].name, "Foo oo");
});

function editReleaseTest(name, callback) {
    test(name, function (t) {
        callback(t, common.setupReleaseEdit());
        validation.errorFields([]);
        releaseEditor.externalLinksEditData({});
        releaseEditor.hasInvalidLinks = validation.errorField(ko.observable(false));
    });
}

editReleaseTest("releaseAddAnnotation edit is generated for existing release", function (t, release) {
    t.plan(1);

    release.annotation("foooooo");

    t.deepEqual(releaseEditor.edits.annotation(release), [
      {
        entity: "868cc741-e3bc-31bc-9dac-756e35c8f152",
        text: "foooooo",
        edit_type: 35,
        hash: "aaef07d691a28785980903fe976cc4827e8731fa",
      },
    ]);
});

editReleaseTest("releaseDeleteReleaseLabel edit is generated for existing release", function (t, release) {
    t.plan(1);

    release.labels.remove(release.labels()[0]);

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
      {
        edit_type: 36,
        hash: "b6cf0e5b82d3ab32124df85bc5e824e612d1237a",
        release_label: 27903,
      },
    ]);
});

editReleaseTest("releaseDeleteReleaseLabel edit is generated when label/catalog number fields are cleared (MBS-7287)", function (t, release) {
    t.plan(1);

    var releaseLabel = release.labels()[0];
    releaseLabel.label(new MB.entity.Label({}));
    releaseLabel.catalogNumber("");

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
      {
        edit_type: 36,
        hash: "b6cf0e5b82d3ab32124df85bc5e824e612d1237a",
        release_label: 27903,
      },
    ]);
});

editReleaseTest("releaseEditReleaseLabel edits are generated for existing release", function (t, release) {
    t.plan(1);

    release.labels()[0].catalogNumber("WPC6-10046");
    release.labels()[1].label(null);

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
      {
        release_label: 27903,
        label: 30265,
        catalog_number: "WPC6-10046",
        edit_type: 37,
        hash: "20e2df134a7e1d477950b85d16c9cdf7f2d2778a",
      },
      {
        release_label: 64842,
        label: null,
        catalog_number: "WPC6-10045",
        edit_type: 37,
        hash: "348a0d63ef950babd4ef636d1162dae67c8503a5",
      },
    ]);
});

editReleaseTest("mediumDelete edit is generated for existing release", function (t, release) {
    t.plan(1);

    releaseEditor.removeMedium(release.mediums()[0]);

    t.deepEqual(releaseEditor.edits.medium(release), [
      {
        edit_type: 53,
        medium: 249113,
        hash: "e1ae70a7a8cbf0dc0f838672d8041489cd023847",
      },
    ]);
});

editReleaseTest("releaseGroupEdit edits should not include unchanged fields (MBS-8212)", function (t, release) {
    t.plan(1);

    releaseEditor.copyTitleToReleaseGroup(true);
    release.name('Blah');

    t.deepEqual(releaseEditor.edits.releaseGroup(release), [
        {
          edit_type: 21,
          gid: "1c205925-2cfe-35c0-81de-d7ef17df9658",
          hash: "6b8e1d79cb7a109986781e453bd954558cb6bf19",
          name: "Blah",
        },
    ]);
});

test("mediumEdit and releaseReorderMediums edits are generated for non-loaded mediums", function (t) {
    t.plan(6);

    var release = new fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [
            {id: 123, name: "foo", position: 1},
            {id: 456, name: "bar", position: 2},
        ],
    });

    releaseEditor.rootField.release(release);

    var medium1 = release.mediums()[0];
    var medium2 = release.mediums()[1];

    t.ok(!medium1.loaded(), "medium 1 is not loaded");
    t.ok(!medium2.loaded(), "medium 2 is not loaded");

    releaseEditor.moveMediumDown(medium1);

    t.equal(medium1.position(), 2, "medium 1 now has position 2");
    t.equal(medium2.position(), 1, "medium 2 now has position 1");

    medium1.name("foo!");
    medium1.formatID(1);

    medium2.name("bar!");
    medium2.formatID(2);

    t.deepEqual(releaseEditor.edits.medium(release), [
      {
        edit_type: 52,
        format_id: 2,
        hash: "7e795b9d8b514ec0549c667c8da7a844d9d00835",
        name: "bar!",
        to_edit: 456,
      },
      {
        edit_type: 52,
        format_id: 1,
        hash: "bee90ecf182e5b8f1a80b4393f2ded17c2d0109c",
        name: "foo!",
        to_edit: 123,
      },
    ]);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        edit_type: 313,
        hash: "fe6d272bd48a354f1f42e1ca0816397d7754d0ff",
        medium_positions: [
          {
            medium_id: 456,
            new: 1,
            old: 2,
          },
          {
            medium_id: 123,
            new: 2,
            old: 1,
          },
        ],
        release: "f4c552ab-515e-42df-a9ee-a370867d29d1",
      },
    ]);
});

test("mediumCreate edits are not given conflicting positions", function (t) {
    t.plan(2);

    var release = new fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [
            {id: 123, position: 1},
            {id: 456, position: 3},
        ],
    });

    releaseEditor.rootField.release(release);

    var mediums = release.mediums;
    var medium1 = mediums()[0];
    var medium3 = mediums()[1];

    medium1.position(4);

    var newMedium1 = new fields.Medium({
        name: "foo",
        position: 1,
    });

    newMedium1.tracks.push(new fields.Track({}, newMedium1));

    var newMedium2 = new fields.Medium({
        name: "bar",
        position: 2,
    });

    newMedium2.tracks.push(new fields.Track({}, newMedium2));
    mediums.push(newMedium1, newMedium2);

    var mediumCreateEdits = _.map(
        releaseEditor.edits.medium(release),
        function (edit) {
            // Don't care about this.
            return _.omit(edit, "tracklist");
        },
    );

    t.deepEqual(mediumCreateEdits, [
      {
        edit_type: MB.edit.TYPES.EDIT_MEDIUM_CREATE,
        position: 4,
        name: "foo",
        release: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        hash: "aca331e8e3448781852995b146feae853acbaa0e",
      },
      {
        edit_type: MB.edit.TYPES.EDIT_MEDIUM_CREATE,
        position: 2,
        name: "bar",
        release: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        hash: "d0f3777cede43eef81db632b671ca8da45085760",
      },
    ]);

    common.createMediums(release);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        edit_type: MB.edit.TYPES.EDIT_RELEASE_REORDER_MEDIUMS,
        hash: "175c1aabc49c94c5edb79fd11cca04a31f0f85ad",
        medium_positions: [
          {
            medium_id: 123,
            new: 4,
            old: 1,
          },
          {
            medium_id: 666,
            new: 1,
            old: 4,
          },
        ],
        release: "f4c552ab-515e-42df-a9ee-a370867d29d1",
      },
    ]);
});

test("mediumCreate positions don't conflict with removed mediums (MBS-7952)", function (t) {
    t.plan(1);

    var release = new fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [{id: 123, position: 1}],
    });

    releaseEditor.rootField.release(release);

    var mediums = release.mediums;
    var newMedium = new fields.Medium({position: 2});

    newMedium.tracks.push(new fields.Track({}, newMedium));
    mediums.push(newMedium);
    releaseEditor.removeMedium(mediums()[0]);
    common.createMediums(release);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        edit_type: MB.edit.TYPES.EDIT_RELEASE_REORDER_MEDIUMS,
        hash: "6a2634d88b570aef5d0dd8521c7166b4a40ec042",
        medium_positions: [
          {
            medium_id: 123,
            new: 2,
            old: 1,
          },
          {
            medium_id: 666,
            new: 1,
            old: 2,
          },
        ],
        release: "f4c552ab-515e-42df-a9ee-a370867d29d1",
      },
    ]);
});

test("releaseDeleteReleaseLabel edits are not generated for non-existent release labels (MBS-7455)", function (t) {
    t.plan(1);

    var release = new fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        labels: [
            {id: 123, label: null, catalogNumber: "foo123"},
        ],
    });

    releaseEditor.rootField.release(release);
    releaseEditor.removeReleaseLabel(release.labels()[0]);
    releaseEditor.addReleaseLabel(release);
    release.labels()[0].catalogNumber("foo456");
    releaseEditor.addReleaseLabel(release);

    var submission = _.find(releaseEditor.orderedEditSubmissions, {
        edits: releaseEditor.edits.releaseLabel,
    });

    // Simulate edit submission.
    var edits = submission.edits(release);

    submission.callback(release, [
        {message: "OK"},
        {message: "OK", entity: {id: 456, labelID: null, catalogNumber: "foo456"}},
    ]);

    edits = submission.edits(release);

    t.deepEqual(edits, []);
});
