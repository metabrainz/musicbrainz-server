// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt


MB.edit.preview = function () {
    return $.Deferred().resolve({ previews: [] });
};


MB.edit.create = function () {
    return $.Deferred().resolve({ edits: [] });
};


releaseEditor.test.module("add-release edits", function () {
    var data = $.extend(true, {}, releaseEditor.test.testRelease);
    var medium = data.mediums[0];

    medium.originalID = medium.id;

    delete medium.id;
    delete data.labels[0].id;
    delete data.labels[1].id;

    releaseEditor.test.setupReleaseAdd(data);
});


test("releaseCreate edit is generated for new release", function () {

    deepEqual(releaseEditor.edits.release(this.release), [
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


test("releaseAddAnnotation edit is generated for new release", function () {

    deepEqual(releaseEditor.edits.annotation(this.release), [
        {
            edit_type: 35,
            entity: null,
            hash: "64597d0deb9fd1facd110648bc5774aa5a1c35ec",
            text: "foobar123"
        }
    ]);
});


test("releaseAddReleaseLabel edits are generated for new release", function () {

    deepEqual(releaseEditor.edits.releaseLabel(this.release), [
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


test("recordingEdit edits are generated for new release", function () {
    releaseEditor.copyTrackChangesToRecordings(true);

    var track = this.release.mediums()[0].tracks()[0];

    track.name("[unicode suckz!]");
    track.length(722093);

    var edits = _.filter(releaseEditor.edits.medium(this.release),
        function (edit) {
            return edit.edit_type === MB.edit.TYPES.EDIT_RECORDING_EDIT;
        });

    deepEqual(edits, [
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
              join_phrase:
              null
            }
          ]
        },
        length: 722093,
        comment: null,
        video: false,
        edit_type: 72,
        hash: "50379153e2dc73753cdb154f53ada243936d8941"
      }
    ]);

    releaseEditor.copyTrackChangesToRecordings(false);
});


test("mediumCreate edits are generated for new release", function () {

    this.release.mediums.push(
      releaseEditor.fields.Medium(_.omit(releaseEditor.test.testMedium, "id"))
    );

    deepEqual(releaseEditor.edits.medium(this.release), [
      {
        "edit_type": 51,
        "format_id": 1,
        "hash": "81aa9f2f8a196eb5c458a5c030248fd040c5b613",
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
            "recording_gid": "f66857fb-bb59-444e-97dc-62c73e5eddae"
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
            "recording_gid": "6c97b1d7-aa12-480e-8376-fa435235f164"
          }
        ]
      },
      {
        "edit_type": 51,
        "format_id": 1,
        "hash": "544275b1da580ef7fda83ae98fa1b6e8288b4bdc",
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
            "recording_gid": "19506825-c404-43eb-9b09-86fc152c6780"
          }
        ]
      }
    ]);
});


test("mediumAddDiscID edits are generated for new release", function () {
    var mediums = this.release.mediums,
        medium = mediums()[0];

    medium.toc = "1+5+146225+150+16102+49660+76357+111535";

    mediums.notifySubscribers(mediums());

    deepEqual(releaseEditor.edits.discID(this.release), [
      {
        medium_id: undefined,
        cdtoc: "1+5+146225+150+16102+49660+76357+111535",
        edit_type: 55,
        hash: "8ffb378704a13a489814a47dbdd5837bce20a88c",
        release: undefined
      }
    ]);
});


releaseEditor.test.module("edit-release edits", releaseEditor.test.setupReleaseEdit);


test("releaseEdit edit is generated for existing release", function () {
    var release = this.release;

    release.name("blah bluh bleh");
    release.barcode.value("3832563900471");
    release.languageID(123);
    release.packagingID(456);
    release.scriptID(789);
    release.statusID(123);

    deepEqual(releaseEditor.edits.release(release), [
      {
        name: "blah bluh bleh",
        barcode: "3832563900471",
        language_id: 123,
        packaging_id: 456,
        script_id: 789,
        status_id: 123,
        to_edit: 249113,
        edit_type: 32,
        hash: "f603b861729d6fb5bc5714da9b5ffb2ea047cdc2"
      }
    ]);
});


test("releaseAddAnnotation edit is generated for existing release", function () {
    this.release.annotation("foooooo");

    deepEqual(releaseEditor.edits.annotation(this.release), [
      {
        entity: 249113,
        text: "foooooo",
        edit_type: 35,
        hash: "57216691ffd548bec221bec845d6c3e6f0fe16f7"
      }
    ]);
});


test("releaseDeleteReleaseLabel edit is generated for existing release", function () {
    this.release.labels.remove(this.release.labels()[0]);

    deepEqual(releaseEditor.edits.releaseLabel(this.release), [
      {
        "catalog_number": "WPC6-10044",
        "edit_type": 36,
        "hash": "cca8fc44a0d18c4d6050a29976978da7cf354741",
        "release_label": 27903
      }
    ]);
});


test("releaseEditReleaseLabel edits are generated for existing release", function () {
    this.release.labels()[0].catalogNumber("WPC6-10046");
    this.release.labels()[1].label(null);

    deepEqual(releaseEditor.edits.releaseLabel(this.release), [
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


test("mediumEdit edit is generated existing existing release", function () {
    var medium = this.release.mediums()[0];

    medium.name("foooooooo");
    medium.formatID(1234);

    deepEqual(releaseEditor.edits.medium(this.release), [
      {
        edit_type: 52,
        name: "foooooooo",
        format_id: 1234,
        to_edit: 249113,
        hash: "3e107278199a8300c36b8271ec56bd7f17a00642"
      }
    ]);
});


test("mediumDelete edit is generated for existing release", function () {
    releaseEditor.removeMedium(this.release.mediums()[0]);

    deepEqual(releaseEditor.edits.medium(this.release), [
      {
        edit_type: 53,
        medium: 249113,
        hash: "e1ae70a7a8cbf0dc0f838672d8041489cd023847"
      }
    ]);
});

test("mediumEdit and releaseReorderMediums edits are generated for non-loaded mediums", function () {
    this.release = releaseEditor.fields.Release({
        id: 123,
        mediums: [
            { id: 123, name: "foo", position: 1 },
            { id: 456, name: "bar", position: 2 },
        ]
    });

    releaseEditor.rootField.release(this.release);

    var medium1 = this.release.mediums()[0];
    var medium2 = this.release.mediums()[1];

    ok(!medium1.loaded(), "medium 1 is not loaded");
    ok(!medium2.loaded(), "medium 2 is not loaded");

    releaseEditor.moveMediumDown(medium1);

    equal(medium1.position(), 2, "medium 1 now has position 2");
    equal(medium2.position(), 1, "medium 2 now has position 1");

    medium1.name("foo!");
    medium1.formatID(1);

    medium2.name("bar!");
    medium2.formatID(2);

    deepEqual(releaseEditor.edits.medium(this.release), [
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
      },
      {
        "edit_type": 313,
        "hash": "5c1f4183faf7eb84312bb90c2680309df25d4dc0",
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
        "release": 123
      }
    ]);
});
