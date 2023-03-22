/*
 * @flow
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
import * as manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';
import {formatPluralEntityTypeName}
  from '../static/scripts/common/utility/formatEntityTypeName.js';

import SeriesLayout from './SeriesLayout.js';

type ListPickerProps = {
  ...SeriesItemNumbersRoleT,
  +entities: $ReadOnlyArray<EntityWithSeriesT>,
  +seriesEntityType: EntityWithSeriesTypeT,
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
    case 'artist':
      return (
        <ArtistList
          artists={((entities: any): $ReadOnlyArray<ArtistT>)}
          showBeginEnd
          showRatings
          {...sharedProps}
        />
      );
    case 'event':
      return (
        <EventList
          events={((entities: any): $ReadOnlyArray<EventT>)}
          showArtists
          showLocation
          showRatings
          {...sharedProps}
        />
      );
    case 'recording':
      return (
        <RecordingList
          recordings={
            ((entities: any): $ReadOnlyArray<RecordingWithArtistCreditT>)
          }
          showRatings
          {...sharedProps}
        />
      );
    case 'release':
      return (
        <ReleaseList
          releases={((entities: any): $ReadOnlyArray<ReleaseT>)}
          {...sharedProps}
        />
      );
    case 'release_group':
      return (
        <ReleaseGroupListTable
          releaseGroups={((entities: any): $ReadOnlyArray<ReleaseGroupT>)}
          showRatings
          {...sharedProps}
        />
      );
    case 'work':
      return (
        <WorkList
          showRatings
          works={((entities: any): $ReadOnlyArray<WorkT>)}
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
  +entities: ?$ReadOnlyArray<EntityWithSeriesT>,
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
}: SeriesIndexProps): React$Element<typeof SeriesLayout> => {
  const seriesEntityType = series.type.item_entity_type;
  const existingEntities = entities?.length ? entities : null;
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

      {existingEntities ? (
        <PaginatedResults pager={pager}>
          {listPicker({
            entities: existingEntities,
            seriesEntityType,
            seriesItemNumbers,
          })}
        </PaginatedResults>
      ) : (
        <p>
          {l('This series is currently empty.')}
        </p>
      )}

      <Relationships source={series} />
      {manifest.js('series/index', {async: 'async'})}
    </SeriesLayout>
  );
};

export default SeriesIndex;
