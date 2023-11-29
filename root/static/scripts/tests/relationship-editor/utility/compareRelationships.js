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
} from '../../../common/constants.js';
import {
  createArtistObject,
  createRecordingObject,
  createSeriesObject,
} from '../../../common/entity2.js';
import {emptyRelationship} from '../constants.js';
import compareRelationships
  from '../../../relationship-editor/utility/compareRelationships.js';
import {
  exportLinkAttributeTypeInfo,
  exportLinkTypeInfo,
} from '../../../relationship-editor/utility/exportTypeInfo.js';
import {linkAttributeTypes, linkTypes} from '../../typeInfo.js';

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
  }

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

test('compareRelationships: Series comparisons', function (t) {
  t.plan(4);

  const recording = createArtistObject({
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

  const recordingSeriesPartOfRelOrder1 = {
    ...emptyRelationship,
    attributes: attributesWithOrdering1,
    entity0: recording,
    entity1: series,
    id: -1,
    linkTypeID: 740, // Part of series
  };

  const recordingSeriesPartOfRelOrder2 = {
    ...recordingSeriesPartOfRelOrder1,
    attributes: attributesWithOrdering2,
  };

  t.ok(
    compareRelationships(
      recordingSeriesPartOfRelOrder1,
      recordingSeriesPartOfRelOrder1,
      false,
    ) === 0,
    'The exact same "part of series" relationship is seen as equal',
  );

  t.ok(
    compareRelationships(
      recordingSeriesPartOfRelOrder1,
      recordingSeriesPartOfRelOrder2,
      false,
    ) === -1,
    'The same "part of series" relationship with different order attributes is not seen as equal, and smaller order sorts first',
  );
});
