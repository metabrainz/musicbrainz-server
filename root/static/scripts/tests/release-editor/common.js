// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import fields from '../../release-editor/fields';
import trackParser from '../../release-editor/trackParser';
import releaseEditor from '../../release-editor/viewModel';

import '../../release-editor/edits';
import '../../release-editor/seeding';

export function setupReleaseAdd(data) {
  releaseEditor.action = "add";
  // seed() sets rootField.release() for us when action === 'add'
  releaseEditor.seed({seed: data || {}});
  return releaseEditor.rootField.release();
}

export function setupReleaseEdit() {
  releaseEditor.action = "edit";
  var release = new fields.Release(testRelease);
  releaseEditor.rootField.release(release);
  return release;
}

export function trackParserTest(t, input, expected) {
  var result = trackParser.parse(input);

  function getProps(track) {
    return _.pick.apply(_, [track].concat(_.keys(expected[0])));
  }

  t.deepEqual(ko.toJS(_.map(result, getProps)), expected);
}

export function createMediums(release) {
  var submission = _.find(releaseEditor.orderedEditSubmissions, function (sub) {
    return sub.edits === releaseEditor.edits.medium;
  });

  // Simulate edit submission.
  var createEdits = submission.edits(release);

  var nextID = 666;

  submission.callback(release, _.map(createEdits, function (data) {
    return {entity: {id: nextID++, position: data.position}};
  }));
}

export const testArtistCredit = {
  names: [
    {
      artist: {
        sort_name: "Boredoms",
        comment: "",
        name: "Boredoms",
        id: 39282,
        gid: "0798d15b-64e2-499f-9969-70167b1d8617",
      },
      joinPhrase: "",
      name: "Boredoms",
    },
  ],
};

export const testRelease = {
  entityType: "release",
  releaseGroup: {
    typeName: null,
    name: "Vision Creation Newsun",
    artist: "Boredoms",
    typeID: 1,
    comment: "",
    artistCredit: testArtistCredit,
    id: 83146,
    secondaryTypeIDs: [],
    firstReleaseDate: "1999-10-27",
    gid: "1c205925-2cfe-35c0-81de-d7ef17df9658",
  },
  scriptID: 112,
  statusID: 1,
  name: "Vision Creation Newsun",
  barcode: "4943674011582",
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
            gid: "f66857fb-bb59-444e-97dc-62c73e5eddae",
          },
          position: 1,
          name: "\u25cb",
          length: 822093,
          id: 564394,
          artistCredit: testArtistCredit,
          gid: "aaed3498-cb14-3c2b-8c08-ad03bf46ab61",
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
            gid: "6c97b1d7-aa12-480e-8376-fa435235f164",
          },
          position: 2,
          name: "\u2606",
          length: 322933,
          id: 564395,
          artistCredit: testArtistCredit,
          gid: "cce78f39-a1a0-32d5-b921-091757f28586",
        },
      ],
      format: "CD",
      name: null,
      position: 1,
      cdtocs: [
        "1 9 304912 150 61807 86027 116895 146370 174812 207905 236857 271077",
        "1 9 304974 153 61810 86030 116898 146373 174815 207908 236860 271079",
      ],
      formatID: 1,
      id: 249113,
    },
  ],
  formats: "2\u00d7CD",
  packagingID: null,
  comment: "limited edition",
  artistCredit: testArtistCredit,
  id: 249113,
  labels: [
    {
      catalogNumber: "WPC6-10044",
      label: {
        comment: "",
        name: "WEA Japan",
        id: 30265,
        gid: "42b63b4e-a96d-4197-b584-165fa60357e8",
      },
      id: 27903,
    },
    {
      catalogNumber: "WPC6-10045",
      label: {
        comment: "",
        name: "WEA Japan",
        id: 30265,
        gid: "42b63b4e-a96d-4197-b584-165fa60357e8",
      },
      id: 64842,
    },
  ],
  gid: "868cc741-e3bc-31bc-9dac-756e35c8f152",
  languageID: 486,
  annotation: "foobar123",
};

export const testMedium = {
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
        gid: "19506825-c404-43eb-9b09-86fc152c6780",
      },
      position: 1,
      name: "\u2609",
      length: 92666,
      id: 892996,
      artistCredit: testArtistCredit,
      gid: "2e8e2c89-d2ac-3e78-b8b9-b09f3fcf8c98",
    },
  ],
  format: "CD",
  name: null,
  position: 2,
  cdtocs: ["1 3 192512 150 7100 167475"],
  formatID: 1,
  id: 249114,
};
