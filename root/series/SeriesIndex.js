/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CleanupBanner from '../components/CleanupBanner.js';
import ArtistList from '../components/list/ArtistList.js';
import EventList from '../components/list/EventList.js';
import RecordingList from '../components/list/RecordingList.js';
import {ReleaseGroupListTable} from '../components/list/ReleaseGroupList.js';
import ReleaseList from '../components/list/ReleaseList.js';
import WorkList from '../components/list/WorkList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';

import SeriesLayout from './SeriesLayout.js';

type ListPickerProps = $Values<{
  +[EntityType in keyof EntityWithSeriesMapT]: {
    ...SeriesItemNumbersRoleT,
    +entities: $ReadOnlyArray<EntityWithSeriesMapT[EntityType]>,
    +seriesEntityType: EntityType,
  },
}>;

const listPicker = (
  props: ListPickerProps,
): React.MixedElement => {
  const sharedProps = {
    seriesItemNumbers: props.seriesItemNumbers,
  };
  switch (props.seriesEntityType) {
    case 'artist':
      return (
        <ArtistList
          artists={props.entities}
          showBeginEnd
          showRatings
          {...sharedProps}
        />
      );
    case 'event':
      return (
        <EventList
          events={props.entities}
          showArtists
          showLocation
          showRatings
          {...sharedProps}
        />
      );
    case 'recording':
      return (
        <RecordingList
          recordings={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'release':
      return (
        <ReleaseList
          releases={props.entities}
          {...sharedProps}
        />
      );
    case 'release_group':
      return (
        <ReleaseGroupListTable
          releaseGroups={props.entities}
          showRatings
          {...sharedProps}
        />
      );
    case 'work':
      return (
        <WorkList
          showRatings
          works={props.entities}
          {...sharedProps}
        />
      );
    default:
      throw `Unsupported entity type value: ${props.seriesEntityType}`;
  }
};

component SeriesIndex(
  eligibleForCleanup: boolean,
  listProps: ListPickerProps,
  numberOfRevisions: number,
  pager: PagerT,
  series: $ReadOnly<{...SeriesT, +type: SeriesTypeT}>,
  wikipediaExtract: WikipediaExtractT | null,
) {
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

      {listProps.entities?.length ? (
        <PaginatedResults pager={pager}>
          {listPicker(listProps)}
        </PaginatedResults>
      ) : (
        <p>
          {l('This series is currently empty.')}
        </p>
      )}

      <Relationships source={series} />
      {manifest('series/index', {async: true})}
    </SeriesLayout>
  );
}

export default SeriesIndex;
