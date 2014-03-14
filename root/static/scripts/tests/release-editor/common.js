// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var releaseEditor = MB.releaseEditor;


$.ajax = function () {
    var mockXHR = $.Deferred();

    mockXHR.success = mockXHR.done;
    mockXHR.error = mockXHR.fail;
    mockXHR.complete = mockXHR.always;

    return mockXHR;
};


releaseEditor.test = {

    module: function (name, setup) {
        module(name, {
            setup: function () {
                $("#qunit-fixture").append($("<div>").attr("id", "release-editor"));

                if (setup) setup.call(this);

                if (releaseEditor.rootField) {
                    this.release = releaseEditor.rootField.release();
                }
            },

            teardown: function () {
                if (releaseEditor.rootField) {
                    releaseEditor.rootField.release(null);
                }
            }
        });
    },

    setupReleaseAdd: function (data) {
        releaseEditor.action = "add";
        releaseEditor.rootField = releaseEditor.fields.Root();
        releaseEditor.seed({ seed: data || {} });
    },

    setupReleaseEdit: function () {
        releaseEditor.action = "edit";
        releaseEditor.rootField = releaseEditor.fields.Root();
        releaseEditor.rootField.release(releaseEditor.fields.Release(releaseEditor.test.testRelease));
    },

    trackParser: function (input, expected) {
        var result = releaseEditor.trackParser.parse(input);

        function getProps(track) {
            return _.pick.apply(_, [track].concat(_.keys(expected[0])));
        }

        deepEqual(ko.toJS(_.map(result, getProps)), expected);
    }
};


releaseEditor.test.testArtistCredit = [
  {
    artist: {
      sortName: "Boredoms",
      comment: "",
      name: "Boredoms",
      id: 39282,
      gid: "0798d15b-64e2-499f-9969-70167b1d8617"
    },
    joinPhrase: ""
  }
];


releaseEditor.test.testRelease = {
  releaseGroup: {
    typeName: null,
    name: "Vision Creation Newsun",
    artist: "Boredoms",
    typeID: 1,
    comment: "",
    artistCredit: releaseEditor.test.testArtistCredit,
    id: 83146,
    secondaryTypeIDs: [],
    firstReleaseDate: "1999-10-27",
    gid: "1c205925-2cfe-35c0-81de-d7ef17df9658"
  },
  scriptID: 112,
  statusID: 1,
  name: "Vision Creation Newsun",
  barcode: "4943674011582",
  trackCounts: "9 + 3",
  mediums: [
    {
      tracks: [
        {
          number: "1",
          recording: {
            video: 0,
            name: "\u25cb",
            length: 822093,
            comment: "",
            id: 636551,
            isrcs: [],
            gid: "f66857fb-bb59-444e-97dc-62c73e5eddae"
          },
          position: 1,
          name: "\u25cb",
          length: 822093,
          id: 564394,
          artistCredit: releaseEditor.test.testArtistCredit,
          gid: "aaed3498-cb14-3c2b-8c08-ad03bf46ab61"
        },
        {
          number: "2",
          recording: {
            video: 0,
            name: "\u2606",
            length: 322933,
            comment: "",
            id: 636552,
            isrcs: [],
            gid: "6c97b1d7-aa12-480e-8376-fa435235f164"
          },
          position: 2,
          name: "\u2606",
          length: 322933,
          id: 564395,
          artistCredit: releaseEditor.test.testArtistCredit,
          gid: "cce78f39-a1a0-32d5-b921-091757f28586"
        }
      ],
      format: "CD",
      name: null,
      position: 1,
      cdtocs: 2,
      formatID: 1,
      id: 249113
    }
  ],
  formats: "2\u00d7CD",
  packagingID: null,
  comment: "limited edition",
  artistCredit: releaseEditor.test.testArtistCredit,
  id: 249113,
  labels: [
    {
      catalogNumber: "WPC6-10044",
      label: {
        comment: "",
        name: "WEA Japan",
        id: 30265,
        gid: "42b63b4e-a96d-4197-b584-165fa60357e8"
      },
      id: 27903
    },
    {
      catalogNumber: "WPC6-10045",
      label: {
        comment: "",
        name: "WEA Japan",
        id: 30265,
        gid: "42b63b4e-a96d-4197-b584-165fa60357e8"
      },
      id: 64842
    }
  ],
  gid: "868cc741-e3bc-31bc-9dac-756e35c8f152",
  languageID: 486,
  annotation: "foobar123"
};


releaseEditor.test.testMedium = {
  tracks: [
    {
      number: "1",
      recording: {
        video: 0,
        name: "\u2609",
        length: 92666,
        comment: "",
        id: 1040491,
        isrcs: [],
        gid: "19506825-c404-43eb-9b09-86fc152c6780"
      },
      position: 1,
      name: "\u2609",
      length: 92666,
      id: 892996,
      artistCredit: releaseEditor.test.testArtistCredit,
      gid: "2e8e2c89-d2ac-3e78-b8b9-b09f3fcf8c98"
    }
  ],
  format: "CD",
  name: null,
  position: 2,
  cdtocs: 1,
  formatID: 1,
  id: 249114
};
