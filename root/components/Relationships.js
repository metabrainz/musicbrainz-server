/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {PART_OF_SERIES_LINK_TYPES} from '../static/scripts/common/constants';
import linkedEntities from '../static/scripts/common/linkedEntities';
import groupRelationships, {type GroupedRelationshipsT}
  from '../utility/groupRelationships';

import RelatedSeries from './RelatedSeries';
import RelatedWorks from './RelatedWorks';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay';

type DisplayTargets = {
  +[CoreEntityTypeT]: ?$ReadOnlyArray<CoreEntityTypeT>,
  ...,
};

const displayTargets: DisplayTargets = {
  artist: [
    'artist',
    'url',
    'label',
    'place',
    'area',
    'series',
    'instrument',
  ],
  label: [
    'artist',
    'url',
    'label',
    'place',
    'area',
    'series',
    'instrument',
  ],
  work: [
    'artist',
    'release_group',
    'release',
    'work',
    'url',
    'label',
    'place',
    'area',
    'series',
    'instrument',
    'event',
  ],
};

const seriesPartLinkTypes = new Set(
  Object.values(PART_OF_SERIES_LINK_TYPES),
);

function isNotSeriesPart(r: RelationshipT) {
  return !seriesPartLinkTypes.has(linkedEntities.link_type[r.linkTypeID].gid);
}

type Props = {
  +noRelationshipsHeading?: boolean,
  +relationships?: GroupedRelationshipsT,
  +source: CoreEntityT,
};

const Relationships = ({
  noRelationshipsHeading = false,
  relationships,
  source,
}: Props) => {
  if (!relationships) {
    let srcRels = source.relationships;
    if (srcRels && source.entityType === 'series') {
      srcRels = srcRels.filter(isNotSeriesPart);
    }
    relationships = groupRelationships(
      srcRels,
      displayTargets[source.entityType],
    );
  }

  const hiddenArtistCredit: ?ArtistCreditT = source.entityType === 'artist'
    ? {names: [{artist: source, joinPhrase: '', name: source.name}]}
    : (source.artistCredit || null);

  return (
    <>
      {source.relationships && source.relationships.length ? (
        <>
          {noRelationshipsHeading ? null : (
            <h2 className="relationships">{l('Relationships')}</h2>
          )}
          <StaticRelationshipsDisplay
            hiddenArtistCredit={hiddenArtistCredit}
            relationships={relationships}
          />
        </>
      ) : null}
      {source.entityType === 'recording' && source.related_works.length ? (
        <RelatedWorks workIds={source.related_works} />
      ) : null}
      {source.entityType === 'event' && source.related_series.length ? (
        <RelatedSeries seriesIds={source.related_series} />
      ) : null}
    </>
  );
};

export default Relationships;
