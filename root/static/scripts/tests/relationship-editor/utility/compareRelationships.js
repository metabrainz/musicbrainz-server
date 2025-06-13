/*
 * @flow strict-local
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';
import * as tree from 'weight-balanced-tree';

import {
  SERIES_ORDERING_ATTRIBUTE,
  SERIES_ORDERING_TYPE_AUTOMATIC,
  TIME_ATTRIBUTE,
} from '../../../common/constants.js';
import {
  createArtistObject,
  createEventObject,
  createRecordingObject,
  createSeriesObject,
} from '../../../common/entity2.js';
import {
  REL_STATUS_ADD,
  REL_STATUS_EDIT,
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
} from '../../../relationship-editor/constants.js';
import compareRelationships
  from '../../../relationship-editor/utility/compareRelationships.js';
import {
  exportLinkAttributeTypeInfo,
  exportLinkTypeInfo,
} from '../../../relationship-editor/utility/exportTypeInfo.js';
import {
  getStatusName,
} from '../../../relationship-editor/utility/getRelationshipStatusName.js';
import {linkAttributeTypes, linkTypes} from '../../typeInfo.js';
import {emptyRelationship} from '../constants.js';

exportLinkTypeInfo(linkTypes);
exportLinkAttributeTypeInfo(linkAttributeTypes);

test('compareRelationships: Basic comparisons', function (t) {
  t.plan(8);

  const artist = createArtistObject({
    id: 1,
    name: 'Artist',
  });

  const recording = createArtistObject({
    id: 1,
    name: 'Recording',
  });

  const artistRecordingRel = {
    ...emptyRelationship,
    entity0: artist,
    entity1: recording,
    id: -1,
    linkTypeID: 154,
  };

  t.ok(
    compareRelationships(
      artistRecordingRel,
      artistRecordingRel,
      false,
    ) === 0,
    'The exact same relationship is seen as equal',
  );

  t.ok(
    compareRelationships(
      artistRecordingRel,
      artistRecordingRel,
      true,
    ) === 0,
    'The exact same relationship is seen as equal when backward',
  );

  const differentArtist = createArtistObject({
    id: 2,
    name: 'Some Other Artist',
  });

  const changedArtistRecordingRel = {
    ...artistRecordingRel,
    entity0: differentArtist,
  };

  t.ok(
    compareRelationships(
      artistRecordingRel,
      changedArtistRecordingRel,
      true,
    ) === -1,
    'The same relationship with a different entity0 target is not seen as equal, and sort alphabetically by target name',
  );

  const differentRecording = createRecordingObject({
    id: 2,
    name: 'Some Other Recording',
  });

  const artistChangedRecordingRel = {
    ...artistRecordingRel,
    entity1: differentRecording,
  };

  t.ok(
    compareRelationships(
      artistRecordingRel,
      artistChangedRecordingRel,
      false,
    ) === -1,
    'The same relationship with a different entity1 target is not seen as equal, and sort alphabetically by target name',
  );

  const artistRecordingRelDated = {
    ...artistRecordingRel,
    begin_date: {day: 1, month: 1, year: 2000},
  };

  t.ok(
    compareRelationships(
      artistRecordingRelDated,
      artistRecordingRelDated,
      false,
    ) === 0,
    'The same relationship with the same dates is seen as equal',
  );

  t.ok(
    compareRelationships(
      artistRecordingRel,
      artistRecordingRelDated,
      false,
    ) === -1,
    'The same relationship with and without dates is not seen as equal, and undated sorts first',
  );

  const artistRecordingRelDatedAndEnded = {
    ...artistRecordingRelDated,
    ended: true,
  };

  t.ok(
    compareRelationships(
      artistRecordingRelDated,
      artistRecordingRelDatedAndEnded,
      false,
    ) === 1,
    'The same dated relationship with and without "ended" is not seen as equal, and ended sorts first',
  );

  // Insert test for entity credits here
  const artistRecordingRelCredited = {
    ...artistRecordingRel,
    entity0_credit: 'Some Fancy a.k.a.',
  };

  t.ok(
    compareRelationships(
      artistRecordingRel,
      artistRecordingRelCredited,
      true,
    ) === 0,
    'The exact same relationship is seen as equal with an entity credit',
  );
});

test('compareRelationships: Time comparisons', function (t) {
  t.plan(3);

  const artist = createArtistObject({
    id: 1,
    name: 'Artist',
  });

  const event = createEventObject({
    id: 1,
    name: 'Event',
  });

  const attributesWithTime1 = tree.fromDistinctAscArray([{
    text_value: '10:10',
    type: {
      gid: TIME_ATTRIBUTE,
    },
    typeID: 830,
    typeName: 'time',
  }]);

  const attributesWithTime2 = tree.fromDistinctAscArray([{
    text_value: '11:10',
    type: {
      gid: TIME_ATTRIBUTE,
    },
    typeID: 830,
    typeName: 'time',
  }]);

  const artistEventRelTime1 = {
    ...emptyRelationship,
    attributes: attributesWithTime1,
    entity0: artist,
    entity1: event,
    id: -1,
    linkTypeID: 798, // Main performer
  };

  const artistEventRelTime2 = {
    ...artistEventRelTime1,
    attributes: attributesWithTime2,
  };

  const artistEventRelNoTime = {
    ...artistEventRelTime1,
    attributes: null,
  };

  t.ok(
    compareRelationships(
      artistEventRelTime1,
      artistEventRelTime1,
      false,
    ) === 0,
    'The same relationship with the same time is seen as equal',
  );


  t.ok(
    compareRelationships(
      artistEventRelTime1,
      artistEventRelTime2,
      false,
    ) === -1,
    'The same relationship with different times is not seen as equal, and earlier time sorts first',
  );

  t.ok(
    compareRelationships(
      artistEventRelTime1,
      artistEventRelNoTime,
      false,
    ) === 1,
    'The same relationship with and without time is not seen as equal, and time sorts last',
  );
});

test('compareRelationships: Series comparisons', function (t) {
  t.plan(21);

  const recording = createRecordingObject({
    id: 1,
    name: 'Recording',
  });

  const series = createSeriesObject({
    id: 1,
    name: 'Series',
    orderingTypeID: SERIES_ORDERING_TYPE_AUTOMATIC,
  });

  const attributesWithOrdering1 = tree.fromDistinctAscArray([{
    text_value: '1',
    type: {
      gid: SERIES_ORDERING_ATTRIBUTE,
    },
    typeID: 788,
    typeName: 'number',
  }]);

  const attributesWithOrdering2 = tree.fromDistinctAscArray([{
    text_value: '2',
    type: {
      gid: SERIES_ORDERING_ATTRIBUTE,
    },
    typeID: 788,
    typeName: 'number',
  }]);

  const recordingSeriesRelOrder1 = {
    ...emptyRelationship,
    attributes: attributesWithOrdering1,
    entity0: recording,
    entity1: series,
    id: -1,
    linkTypeID: 154, // Not part of series
  };

  const recordingSeriesRelOrder2 = {
    ...recordingSeriesRelOrder1,
    attributes: attributesWithOrdering2,
  };

  t.ok(
    compareRelationships(
      recordingSeriesRelOrder1,
      recordingSeriesRelOrder1,
      false,
    ) === 0,
    'The same non-"part of series" relationship is seen as equal',
  );


  t.ok(
    compareRelationships(
      recordingSeriesRelOrder1,
      recordingSeriesRelOrder2,
      false,
    ) === 0,
    'The same non-"part of series" relationship with different order attributes is seen as equal',
  );

  const recordingSeriesPartOfRelWithLinkOrder1 = {
    ...emptyRelationship,
    entity0: recording,
    entity1: series,
    id: -1,
    linkOrder: 1,
    linkTypeID: 740, // Part of series
  };

  const recordingSeriesPartOfRelWithLinkOrder2 = {
    ...recordingSeriesPartOfRelWithLinkOrder1,
    linkOrder: 2,
  };

  t.ok(
    compareRelationships(
      recordingSeriesPartOfRelWithLinkOrder1,
      recordingSeriesPartOfRelWithLinkOrder1,
      false,
    ) === 0,
    'The exact same "part of series" relationship with the same link order is seen as equal',
  );

  const sameRelDifferentLinkOrderTests = [
    [REL_STATUS_NOOP, REL_STATUS_NOOP, false],
    [REL_STATUS_NOOP, REL_STATUS_ADD, true],
    [REL_STATUS_NOOP, REL_STATUS_EDIT, true],
    [REL_STATUS_NOOP, REL_STATUS_REMOVE, false],
    [REL_STATUS_ADD, REL_STATUS_ADD, true],
    [REL_STATUS_ADD, REL_STATUS_EDIT, true],
    [REL_STATUS_ADD, REL_STATUS_REMOVE, true],
    [REL_STATUS_EDIT, REL_STATUS_EDIT, true],
    [REL_STATUS_EDIT, REL_STATUS_REMOVE, true],
    [REL_STATUS_REMOVE, REL_STATUS_REMOVE, false],
  ];

  for (const [status1, status2, isEqual] of sameRelDifferentLinkOrderTests) {
    const statusOrderings = [[status1, status2]];
    if (status1 !== status2) {
      statusOrderings.push([status2, status1]);
    }
    for (const [statusA, statusB] of statusOrderings) {
      t.ok(
        compareRelationships(
          {...recordingSeriesPartOfRelWithLinkOrder1, _status: statusA},
          {...recordingSeriesPartOfRelWithLinkOrder2, _status: statusB},
          false,
        ) === (isEqual ? 0 : -1),
        'The exact same "part of series" relationship with a different ' +
        'link order is' + (isEqual ? ' ' : ' not ') + 'seen as equal for ' +
        '(' + getStatusName(statusA) + ', ' + getStatusName(statusB) + ')',
      );
    }
  }

  const recordingSeriesPartOfRelWithNumber1 = {
    ...emptyRelationship,
    attributes: attributesWithOrdering1,
    entity0: recording,
    entity1: series,
    id: -1,
    linkTypeID: 740, // Part of series
  };

  const recordingSeriesPartOfRelWithNumber2 = {
    ...recordingSeriesPartOfRelWithNumber1,
    attributes: attributesWithOrdering2,
  };

  t.ok(
    compareRelationships(
      recordingSeriesPartOfRelWithNumber1,
      recordingSeriesPartOfRelWithNumber1,
      false,
    ) === 0,
    'The exact same "part of series" relationship with the same number is seen as equal',
  );

  t.ok(
    compareRelationships(
      recordingSeriesPartOfRelWithNumber1,
      recordingSeriesPartOfRelWithNumber2,
      false,
    ) === -1,
    'The same "part of series" relationship with a different number attribute is not seen as equal, and smaller order sorts first',
  );
});
