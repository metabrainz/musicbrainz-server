/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import '../../release-editor/edits.js';
import '../../release-editor/seeding.js';

import fields from '../../release-editor/fields.js';
import trackParser from '../../release-editor/trackParser.js';
import releaseEditor from '../../release-editor/viewModel.js';

export function setupReleaseAdd(data) {
  releaseEditor.action = 'add';
  // seed() sets rootField.release() for us when action === 'add'
  releaseEditor.seed({seed: data || {}});
  return releaseEditor.rootField.release();
}

export function setupReleaseEdit() {
  releaseEditor.action = 'edit';
  const release = new fields.Release(testRelease);
  releaseEditor.rootField.release(release);
  return release;
}

export function trackParserTest(t, input, expected) {
  const release = releaseEditor.rootField.release();
  const medium = release.mediums()[0];
  const result = trackParser.parse(input, medium);

  function getProps(track) {
    const props = {};
    for (const key of Object.keys(expected[0])) {
      props[key] = track[key];
    }
    return props;
  }

  t.deepEqual(ko.toJS(result.map(getProps)), expected);
}

export function createMediums(release) {
  const submission = releaseEditor.orderedEditSubmissions.find(
    function (sub) {
      return sub.edits === releaseEditor.edits.medium;
    },
  );

  // Simulate edit submission.
  const createEdits = submission.edits(release);

  let nextID = 666;

  submission.callback(release, createEdits.map(function (data) {
    return {entity: {id: nextID++, position: data.position}};
  }));
}

export const testArtistCredit = {
  names: [
    {
      artist: {
        comment: '',
        gid: '0798d15b-64e2-499f-9969-70167b1d8617',
        id: 39282,
        name: 'Boredoms',
        sort_name: 'Boredoms',
      },
      joinPhrase: '',
      name: 'Boredoms',
    },
  ],
};

export const testRelease = {
  annotation: 'foobar123',
  artistCredit: testArtistCredit,
  barcode: '4943674011582',
  comment: 'limited edition',
  entityType: 'release',
  formats: '2\u00d7CD',
  gid: '868cc741-e3bc-31bc-9dac-756e35c8f152',
  id: 249113,
  labels: [
    {
      catalogNumber: 'WPC6-10044',
      id: 27903,
      label: {
        comment: '',
        gid: '42b63b4e-a96d-4197-b584-165fa60357e8',
        id: 30265,
        name: 'WEA Japan',
      },
    },
    {
      catalogNumber: 'WPC6-10045',
      id: 64842,
      label: {
        comment: '',
        gid: '42b63b4e-a96d-4197-b584-165fa60357e8',
        id: 30265,
        name: 'WEA Japan',
      },
    },
  ],
  languageID: 486,
  mediums: [
    {
      cdtocs: [
        '1 9 304912 150 61807 86027 116895 146370 174812 207905 236857 271077',
        '1 9 304974 153 61810 86030 116898 146373 174815 207908 236860 271079',
      ],
      format: {
        name: 'CD',
      },
      format_id: 1,
      id: 249113,
      name: null,
      position: 1,
      tracks: [
        {
          artistCredit: testArtistCredit,
          gid: 'aaed3498-cb14-3c2b-8c08-ad03bf46ab61',
          id: 564394,
          length: 822093,
          name: '\u25cb',
          number: '1',
          position: 1,
          recording: {
            comment: '',
            gid: 'f66857fb-bb59-444e-97dc-62c73e5eddae',
            id: 636551,
            isrcs: [],
            length: 822093,
            name: '\u25cb',
            video: 0,
          },
        },
        {
          artistCredit: testArtistCredit,
          gid: 'cce78f39-a1a0-32d5-b921-091757f28586',
          id: 564395,
          length: 322933,
          name: '\u2606',
          number: '2',
          position: 2,
          recording: {
            comment: '',
            gid: '6c97b1d7-aa12-480e-8376-fa435235f164',
            id: 636552,
            isrcs: [],
            length: 322933,
            name: '\u2606',
            video: 0,
          },
        },
      ],
    },
  ],
  name: 'Vision Creation Newsun',
  packagingID: null,
  releaseGroup: {
    artist: 'Boredoms',
    artistCredit: testArtistCredit,
    comment: '',
    firstReleaseDate: '1999-10-27',
    gid: '1c205925-2cfe-35c0-81de-d7ef17df9658',
    id: 83146,
    name: 'Vision Creation Newsun',
    secondaryTypeIDs: [],
    typeID: 1,
    typeName: null,
  },
  scriptID: 112,
  statusID: 1,
};

export const testMedium = {
  cdtocs: ['1 3 192512 150 7100 167475'],
  format: {
    name: 'CD',
  },
  format_id: 1,
  id: 249114,
  name: null,
  position: 2,
  tracks: [
    {
      artistCredit: testArtistCredit,
      gid: '2e8e2c89-d2ac-3e78-b8b9-b09f3fcf8c98',
      id: 892996,
      length: 92666,
      name: '\u2609',
      number: '1',
      position: 1,
      recording: {
        comment: '',
        gid: '19506825-c404-43eb-9b09-86fc152c6780',
        id: 1040491,
        isrcs: [],
        length: 92666,
        name: '\u2609',
        video: 0,
      },
    },
  ],
};
