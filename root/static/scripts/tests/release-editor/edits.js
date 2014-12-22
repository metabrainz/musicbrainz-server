// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');
var common = require('./common.js');

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
        releaseEditor.validation.errorFields([]);
    });
}

addReleaseTest("releaseCreate edit is generated for new release", function (t, release) {
    t.plan(1);

    t.deepEqual(releaseEditor.edits.release(release), [
        {
          artist_credit: {
            names: [
              {
                artist: {
                  gid: "0798d15b-64e2-499f-9969-70167b1d8617",
                  id: 39282,
                  name: "Boredoms"
                },
                join_phrase: null,
                name: "Boredoms"
              }
            ]
          },
          barcode: "4943674011582",
          comment: "limited edition",
          edit_type: 31,
          hash: "a2ef296036703358fa990f467d173a006ad8bd94",
          language_id: 486,
          name: "Vision Creation Newsun",
          packaging_id: null,
          release_group_id: 83146,
          script_id: 112,
          status_id: 1
        }
    ]);
});

addReleaseTest("releaseAddAnnotation edit is generated for new release", function (t, release) {
    t.plan(1);

    t.deepEqual(releaseEditor.edits.annotation(release), [
        {
            edit_type: 35,
            entity: null,
            hash: "64597d0deb9fd1facd110648bc5774aa5a1c35ec",
            text: "foobar123"
        }
    ]);
});

addReleaseTest("releaseAddReleaseLabel edits are generated for new release", function (t, release) {
    t.plan(1);

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
        {
            catalog_number: "WPC6-10044",
            edit_type: 34,
            hash: "7d07899fe1c191192f8d5793e34893dfd5d19fe9",
            label: 30265,
            release: null
        },
        {
            catalog_number: "WPC6-10045",
            edit_type: 34,
            hash: "3b9019a14baebc0f1f9e4b54a25bd418a2332cdf",
            label: 30265,
            release: null
        }
    ]);
});

addReleaseTest("recordingEdit edits are generated for new release", function (t, release) {
    t.plan(1);

    releaseEditor.copyTrackTitlesToRecordings(true);

    var track = release.mediums()[0].tracks()[0];

    track.name("[unicode suckz!]");
    track.length(722093);

    var edits = _.filter(releaseEditor.edits.medium(release),
        function (edit) {
            return edit.edit_type === MB.edit.TYPES.EDIT_RECORDING_EDIT;
        });

    t.deepEqual(edits, [
      {
        to_edit: "f66857fb-bb59-444e-97dc-62c73e5eddae",
        name: "[unicode suckz!]",
        artist_credit: {
          names:[
            {
              artist: {
                name: "Boredoms",
                id: 39282,
                gid: "0798d15b-64e2-499f-9969-70167b1d8617"
              },
              name: "Boredoms",
              join_phrase: null
            }
          ]
        },
        length: 822093,
        comment: "",
        video: false,
        edit_type: 72,
        hash: "e14c68fb875cf1169b1c1a6ffd2a31de09ee8534"
      }
    ]);

    releaseEditor.copyTrackTitlesToRecordings(false);
});

addReleaseTest("recordingEdit edits are generated for new mediums (MBS-7271)", function (t, release) {
    t.plan(1);

    releaseEditor.copyTrackTitlesToRecordings(true);
    releaseEditor.copyTrackArtistsToRecordings(true);

    var trackData = {
        name: "foo",
        artistCredit: common.testArtistCredit
    };

    release.mediums.push(
        releaseEditor.fields.Medium({ tracks: [ trackData ] })
    );

    var track = release.mediums()[1].tracks()[0];
    var recordingData = _.extend({ gid: "80f797aa-2077-435d-85e2-c22e31a654f4" }, trackData);

    track.recording(MB.entity.Recording(recordingData));
    track.name("foobar");

    var edits = _.filter(releaseEditor.edits.medium(release),
        function (edit) {
            return edit.edit_type === MB.edit.TYPES.EDIT_RECORDING_EDIT;
        });

    t.deepEqual(edits, [
      {
        "artist_credit": {
          "names": [
            {
              "artist": {
                "gid": "0798d15b-64e2-499f-9969-70167b1d8617",
                "id": 39282,
                "name": "Boredoms"
              },
              "join_phrase": null,
              "name": "Boredoms"
            }
          ]
        },
        "comment": "",
        "edit_type": 72,
        "hash": "bd8f7990396214d3dede21b6064ded7d35f90930",
        "length": null,
        "name": "foobar",
        "to_edit": "80f797aa-2077-435d-85e2-c22e31a654f4",
        "video": false
      }
    ]);

    releaseEditor.copyTrackTitlesToRecordings(false);
    releaseEditor.copyTrackArtistsToRecordings(false);
});

addReleaseTest("mediumCreate edits are generated for new release", function (t, release) {
    t.plan(1);

    release.mediums.push(
      releaseEditor.fields.Medium(_.omit(common.testMedium, "id"))
    );

    t.deepEqual(releaseEditor.edits.medium(release), [
      {
        "edit_type": 51,
        "format_id": 1,
        "hash": "5f0c29deb70e582765ec7f89c69578d564296b9d",
        "position": 1,
        "release": undefined,
        "tracklist": [
          {
            "artist_credit": {
              "names": [
                {
                  "artist": {
                    "gid": "0798d15b-64e2-499f-9969-70167b1d8617",
                    "id": 39282,
                    "name": "Boredoms"
                  },
                  "join_phrase": null,
                  "name": "Boredoms"
                }
              ]
            },
            "id": 564394,
            "length": 822093,
            "name": "○",
            "number": "1",
            "position": 1,
            "recording_gid": "f66857fb-bb59-444e-97dc-62c73e5eddae",
            "is_data_track": false
          },
          {
            "artist_credit": {
              "names": [
                {
                  "artist": {
                    "gid": "0798d15b-64e2-499f-9969-70167b1d8617",
                    "id": 39282,
                    "name": "Boredoms"
                  },
                  "join_phrase": null,
                  "name": "Boredoms"
                }
              ]
            },
            "id": 564395,
            "length": 322933,
            "name": "☆",
            "number": "2",
            "position": 2,
            "recording_gid": "6c97b1d7-aa12-480e-8376-fa435235f164",
            "is_data_track": false
          }
        ]
      },
      {
        "edit_type": 51,
        "format_id": 1,
        "hash": "b3af2f50a1e9001b96105abf3d7a8a78b4ce7cbf",
        "position": 2,
        "release": undefined,
        "tracklist": [
          {
            "artist_credit": {
              "names": [
                {
                  "artist": {
                    "gid": "0798d15b-64e2-499f-9969-70167b1d8617",
                    "id": 39282,
                    "name": "Boredoms"
                  },
                  "join_phrase": null,
                  "name": "Boredoms"
                }
              ]
            },
            "id": 892996,
            "length": 92666,
            "name": "☉",
            "number": "1",
            "position": 1,
            "recording_gid": "19506825-c404-43eb-9b09-86fc152c6780",
            "is_data_track": false
          }
        ]
      }
    ]);
});

addReleaseTest("mediumAddDiscID edits are generated for new release", function (t, release) {
    t.plan(1);

    var mediums = release.mediums,
        medium = mediums()[0];

    medium.toc("1 5 146225 150 16102 49660 76357 111535");

    mediums.notifySubscribers(mediums());

    t.deepEqual(releaseEditor.edits.discID(release), [
      {
        medium_id: undefined,
        cdtoc: "1 5 146225 150 16102 49660 76357 111535",
        edit_type: 55,
        medium_position: 1,
        release_name: "Vision Creation Newsun",
        hash: "fb7101806c72ae80b63687b5aff2df0935f40046",
        release: undefined
      }
    ]);
});

test("releaseReorderMediums edits are not generated for new releases", function (t) {
    t.plan(1);

    var release = releaseEditor.fields.Release({
        mediums: [
            { position: 1, tracks: [ { name: "foo" } ] },
            { position: 2, tracks: [ { name: "bar" } ] },
        ]
    });

    releaseEditor.rootField.release(release);

    common.createMediums(release);

    t.equal(releaseEditor.edits.mediumReorder(release).length, 0);
});

test("MBS-7453: release group edits strip whitespace from name", function (t) {
    t.plan(1);

    var release = releaseEditor.fields.Release({ name: "  Foo  oo " });

    t.equal(releaseEditor.edits.releaseGroup(release)[0].name, "Foo oo");
});

function editReleaseTest(name, callback) {
    test(name, function (t) {
        callback(t, common.setupReleaseEdit());
        releaseEditor.validation.errorFields([]);
    });
}

editReleaseTest("releaseEdit edit is generated for existing release", function (t, release) {
    t.plan(1);

    release.name("blah bluh bleh");
    release.barcode.value("3832563900471");
    release.languageID(123);
    release.packagingID(456);
    release.scriptID(789);
    release.statusID(123);

    t.deepEqual(releaseEditor.edits.release(release), [
      {
        name: "blah bluh bleh",
        barcode: "3832563900471",
        language_id: 123,
        packaging_id: 456,
        script_id: 789,
        status_id: 123,
        to_edit: "868cc741-e3bc-31bc-9dac-756e35c8f152",
        edit_type: 32,
        hash: "34f636d1332189bb8ed69ab63cba305843bdc12a"
      }
    ]);
});

editReleaseTest("releaseAddAnnotation edit is generated for existing release", function (t, release) {
    t.plan(1);

    release.annotation("foooooo");

    t.deepEqual(releaseEditor.edits.annotation(release), [
      {
        entity: "868cc741-e3bc-31bc-9dac-756e35c8f152",
        text: "foooooo",
        edit_type: 35,
        hash: "aaef07d691a28785980903fe976cc4827e8731fa"
      }
    ]);
});

editReleaseTest("releaseDeleteReleaseLabel edit is generated for existing release", function (t, release) {
    t.plan(1);

    release.labels.remove(release.labels()[0]);

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
      {
        "edit_type": 36,
        "hash": "b6cf0e5b82d3ab32124df85bc5e824e612d1237a",
        "release_label": 27903
      }
    ]);
});

editReleaseTest("releaseDeleteReleaseLabel edit is generated when label/catalog number fields are cleared (MBS-7287)", function (t, release) {
    t.plan(1);

    var releaseLabel = release.labels()[0];
    releaseLabel.label(MB.entity.Label({}));
    releaseLabel.catalogNumber("");

    t.deepEqual(releaseEditor.edits.releaseLabel(release), [
      {
        "edit_type": 36,
        "hash": "b6cf0e5b82d3ab32124df85bc5e824e612d1237a",
        "release_label": 27903
      }
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
        hash: "20e2df134a7e1d477950b85d16c9cdf7f2d2778a"
      },
      {
        release_label: 64842,
        label: null,
        catalog_number: "WPC6-10045",
        edit_type: 37,
        hash: "348a0d63ef950babd4ef636d1162dae67c8503a5"
      }
    ]);
});

editReleaseTest("mediumEdit edit is generated for existing release", function (t, release) {
    t.plan(1);

    var medium = release.mediums()[0];
    medium.name("foooooooo");
    medium.formatID(1234);

    t.deepEqual(releaseEditor.edits.medium(release), [
      {
        edit_type: 52,
        name: "foooooooo",
        format_id: 1234,
        to_edit: 249113,
        hash: "3e107278199a8300c36b8271ec56bd7f17a00642"
      }
    ]);
});

editReleaseTest("mediumDelete edit is generated for existing release", function (t, release) {
    t.plan(1);

    releaseEditor.removeMedium(release.mediums()[0]);

    t.deepEqual(releaseEditor.edits.medium(release), [
      {
        edit_type: 53,
        medium: 249113,
        hash: "e1ae70a7a8cbf0dc0f838672d8041489cd023847"
      }
    ]);
});

var testURLRelationship = {
    target: {
        entityType: "url",
        name: "http://www.discogs.com/release/1369894"
    },
    linkTypeID: 76,
    id: 123
};

editReleaseTest("relationshipCreate edit for external link is generated for existing release", function (t, release) {
    t.plan(1);

    var newRelationshipData = _.omit(testURLRelationship, "id");

    release.relationships.push(
        release.externalLinks.getRelationship(newRelationshipData, release)
    );

    t.deepEqual(releaseEditor.edits.externalLinks(release), [
      {
        "attributes": [],
        "edit_type": 90,
        "entities": [
          {
            "entityType": "release",
            "gid": "868cc741-e3bc-31bc-9dac-756e35c8f152",
            "name": "Vision Creation Newsun"
          },
          {
            "entityType": "url",
            "name": "http://www.discogs.com/release/1369894"
          }
        ],
        "hash": "05d4c2a59527d50caf84db74df7814f125f41728",
        "linkTypeID": 76
      }
    ]);
});

editReleaseTest("relationshipEdit edit for external link is generated for existing release", function (t, release) {
    t.plan(1);

    MB.faviconClasses = {};

    var release = release;
    var vm = release.externalLinks;

    release.relationships([vm.getRelationship(testURLRelationship, release)]);

    var link = vm.links()[0];

    link.linkTypeID(77);
    link.url("http://www.amazon.co.jp/gp/product/B00003IQQD");

    t.deepEqual(releaseEditor.edits.externalLinks(release), [
      {
        "beginDate": null,
        "edit_type": 91,
        "endDate": null,
        "ended": false,
        "entities": [
          {
            "entityType": "release",
            "gid": "868cc741-e3bc-31bc-9dac-756e35c8f152",
            "name": "Vision Creation Newsun"
          },
          {
            "entityType": "url",
            "name": "http://www.amazon.co.jp/gp/product/B00003IQQD"
          }
        ],
        "hash": "1b778d8d4db3f01cef707c72c3ac247317af6309",
        "id": 123,
        "linkTypeID": 77
      }
    ]);
});

editReleaseTest("relationshipDelete edit for external link is generated for existing release", function (t, release) {
    t.plan(1);

    var vm = release.externalLinks;

    release.relationships([vm.getRelationship(testURLRelationship, release)]);
    vm.links()[0].remove();

    t.deepEqual(releaseEditor.edits.externalLinks(release), [
      {
        "attributes": [],
        "edit_type": 92,
        "entities": [
          {
            "entityType": "release",
            "gid": "868cc741-e3bc-31bc-9dac-756e35c8f152",
            "name": "Vision Creation Newsun"
          },
          {
            "entityType": "url",
            "name": "http://www.discogs.com/release/1369894"
          }
        ],
        "hash": "9d7f27c130d713ebe7ecfed7a58a1645f13bac42",
        "id": 123
      }
    ]);
});

editReleaseTest("edits are not generated for external links that duplicate existing removed ones", function (t, release) {
    t.plan(5);

    var newURL = { name: "http://www.discogs.com/release/13698944", entityType: "url" };
    var vm = release.externalLinks;

    var existingRelationship1 = vm.getRelationship(testURLRelationship, release);

    var existingRelationship2 = vm.getRelationship(
        _.assign(_.clone(testURLRelationship), { id: 456, target: newURL }), release
    );

    var addedDuplicate = vm.getRelationship(_.omit(testURLRelationship, "id"), release);

    release.relationships([existingRelationship1, existingRelationship2]);
    existingRelationship1.remove();
    release.relationships.push(addedDuplicate);

    t.equal(releaseEditor.edits.externalLinks(release).length, 1);
    t.equal(releaseEditor.validation.errorsExist(), true);

    addedDuplicate.remove();

    t.equal(releaseEditor.validation.errorsExist(), false);

    existingRelationship2.url(existingRelationship1.url());

    t.equal(releaseEditor.edits.externalLinks(release).length, 1);
    t.equal(releaseEditor.validation.errorsExist(), true);
});

test("mediumEdit and releaseReorderMediums edits are generated for non-loaded mediums", function (t) {
    t.plan(6);

    var release = releaseEditor.fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [
            { id: 123, name: "foo", position: 1 },
            { id: 456, name: "bar", position: 2 },
        ]
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
        "edit_type": 52,
        "format_id": 2,
        "hash": "7e795b9d8b514ec0549c667c8da7a844d9d00835",
        "name": "bar!",
        "to_edit": 456
      },
      {
        "edit_type": 52,
        "format_id": 1,
        "hash": "bee90ecf182e5b8f1a80b4393f2ded17c2d0109c",
        "name": "foo!",
        "to_edit": 123
      }
    ]);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        "edit_type": 313,
        "hash": "fe6d272bd48a354f1f42e1ca0816397d7754d0ff",
        "medium_positions": [
          {
            "medium_id": 456,
            "new": 1,
            "old": 2
          },
          {
            "medium_id": 123,
            "new": 2,
            "old": 1
          }
        ],
        "release": "f4c552ab-515e-42df-a9ee-a370867d29d1"
      }
    ]);
});

test("mediumCreate edits are not given conflicting positions", function (t) {
    t.plan(2);

    var release = releaseEditor.fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [
            { id: 123, position: 1 },
            { id: 456, position: 3 },
        ]
    });

    releaseEditor.rootField.release(release);

    var mediums = release.mediums;
    var medium1 = mediums()[0];
    var medium3 = mediums()[1];

    medium1.position(4);

    var newMedium1 = releaseEditor.fields.Medium({
        name: "foo",
        position: 1
    });

    newMedium1.tracks.push(releaseEditor.fields.Track({}, newMedium1));

    var newMedium2 = releaseEditor.fields.Medium({
        name: "bar",
        position: 2
    });

    newMedium2.tracks.push(releaseEditor.fields.Track({}, newMedium2));
    mediums.push(newMedium1, newMedium2);

    var mediumCreateEdits = _.map(
        releaseEditor.edits.medium(release),
        function (edit) {
            // Don't care about this.
            return _.omit(edit, "tracklist");
        }
    );

    t.deepEqual(mediumCreateEdits, [
      {
        "edit_type": MB.edit.TYPES.EDIT_MEDIUM_CREATE,
        "position": 4,
        "name": "foo",
        "release": "f4c552ab-515e-42df-a9ee-a370867d29d1",
        "hash": "e886dc4907c701cf89e5e7b5fdebcb521fa04e44"
      },
      {
        "edit_type": MB.edit.TYPES.EDIT_MEDIUM_CREATE,
        "position": 2,
        "name": "bar",
        "release": "f4c552ab-515e-42df-a9ee-a370867d29d1",
        "hash": "d8eeecbb56e1e9543a2fc4045f8c1fe5d2135e02"
      }
    ]);

    common.createMediums(release);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        "edit_type": MB.edit.TYPES.EDIT_RELEASE_REORDER_MEDIUMS,
        "hash": "175c1aabc49c94c5edb79fd11cca04a31f0f85ad",
        "medium_positions": [
          {
            "medium_id": 123,
            "new": 4,
            "old": 1
          },
          {
            "medium_id": 666,
            "new": 1,
            "old": 4
          }
        ],
        "release": "f4c552ab-515e-42df-a9ee-a370867d29d1"
      }
    ]);
});

test("mediumCreate positions don't conflict with removed mediums (MBS-7952)", function (t) {
    t.plan(1);

    var release = releaseEditor.fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        mediums: [{ id: 123, position: 1 }]
    });

    releaseEditor.rootField.release(release);

    var mediums = release.mediums;
    var newMedium = releaseEditor.fields.Medium({ position: 2 });

    newMedium.tracks.push(releaseEditor.fields.Track({}, newMedium));
    mediums.push(newMedium);
    releaseEditor.removeMedium(mediums()[0]);
    common.createMediums(release);

    t.deepEqual(releaseEditor.edits.mediumReorder(release), [
      {
        "edit_type": MB.edit.TYPES.EDIT_RELEASE_REORDER_MEDIUMS,
        "hash": "6a2634d88b570aef5d0dd8521c7166b4a40ec042",
        "medium_positions": [
          {
            "medium_id": 123,
            "new": 2,
            "old": 1
          },
          {
            "medium_id": 666,
            "new": 1,
            "old": 2
          }
        ],
        "release": "f4c552ab-515e-42df-a9ee-a370867d29d1"
      }
    ]);
});

test("releaseDeleteReleaseLabel edits are not generated for non-existent release labels (MBS-7455)", function (t) {
    t.plan(1);

    var release = releaseEditor.fields.Release({
        gid: "f4c552ab-515e-42df-a9ee-a370867d29d1",
        labels: [
            { id: 123, label: null, catalogNumber: "foo123" },
        ]
    });

    releaseEditor.rootField.release(release);
    releaseEditor.removeReleaseLabel(release.labels()[0]);
    releaseEditor.addReleaseLabel(release);
    release.labels()[0].catalogNumber("foo456");
    releaseEditor.addReleaseLabel(release);

    var submission = _.find(releaseEditor.orderedEditSubmissions, {
        edits: releaseEditor.edits.releaseLabel
    });

    // Simulate edit submission.
    var edits = submission.edits(release);

    submission.callback(release, [
        { message: "OK" },
        { message: "OK", entity: { id: 456, labelID: null, catalogNumber: "foo456" } }
    ]);

    edits = submission.edits(release);

    t.deepEqual(edits, []);
});
