/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import EventList from '../components/list/EventList';
import RecordingList from '../components/list/RecordingList';
import ReleaseGroupList from '../components/list/ReleaseGroupList';
import ReleaseList from '../components/list/ReleaseList';
import WorkList from '../components/list/WorkList';
import PaginatedResults from '../components/PaginatedResults';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName';
import CleanupBanner from '../components/CleanupBanner';
import Relationships from '../components/Relationships';
import * as manifest from '../static/manifest';

import SeriesLayout from './SeriesLayout';

type ListPickerProps = {
  ...SeriesItemNumbersRoleT,
  +entities: ?$ReadOnlyArray<CoreEntityT>,
  +seriesEntityType: CoreEntityTypeT,
};

const listPicker = ({
  entities,
  seriesEntityType,
  seriesItemNumbers,
}: ListPickerProps) => {
  const sharedProps = {
    seriesItemNumbers: seriesItemNumbers,
  };
  switch (seriesEntityType) {
    case 'event':
      return (
        <EventList
          events={entities}
          showArtists
          showLocation
          showRatings
          {...sharedProps}
        />
      );
    case 'recording':
      return (
        <RecordingList
          recordings={entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'release':
      return (
        <ReleaseList
          releases={entities}
          {...sharedProps}
        />
      );
    case 'release_group':
      return (
        // TODO: Change to {ReleaseGroupsListTable} as part of MBS-10155
        <ReleaseGroupList
          releaseGroups={entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'work':
      return (
        <WorkList
          showRatings
          works={entities}
          {...sharedProps}
        />
      );
    default:
      throw `Unsupported entity type value: ${seriesEntityType}`;
  }
};

type SeriesIndexProps = {
  ...SeriesItemNumbersRoleT,
  +eligibleForCleanup: boolean,
  +entities: ?$ReadOnlyArray<CoreEntityT>,
  +numberOfRevisions: number,
  +pager: PagerT,
  +series: $ReadOnly<{...SeriesT, +type: SeriesTypeT}>,
  +wikipediaExtract: WikipediaExtractT | null,
};

const SeriesIndex = ({
  eligibleForCleanup,
  entities,
  numberOfRevisions,
  pager,
  series,
  seriesItemNumbers,
  wikipediaExtract,
}: SeriesIndexProps) => {
  const seriesEntityType = series.type.item_entity_type;
  return (
    <SeriesLayout entity={series} page="index">
      {eligibleForCleanup ? (
        <CleanupBanner entityType="series" />
      ) : null}
      <Annotation
        annotation={series.latest_annotation}
        collapse
        entity={series}
        numberOfRevisions={numberOfRevisions}
      />
      <WikipediaExtract
        cachedWikipediaExtract={wikipediaExtract}
        entity={series}
      />

      <h2>{formatPluralEntityTypeName(seriesEntityType)}</h2>

      {entities?.length ? (
        <PaginatedResults pager={pager}>
          {listPicker({entities, seriesEntityType, seriesItemNumbers})}
        </PaginatedResults>
      ) : (
        <p>
          {l('This series is currently empty.')}
        </p>
      )}

      <Relationships source={series} />
      {manifest.js('series/index.js', {async: 'async'})}
    </SeriesLayout>
  );
};

export default SeriesIndex;
