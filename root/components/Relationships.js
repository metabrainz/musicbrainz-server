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
import groupRelationships, {type RelationshipTargetTypeGroupT}
  from '../utility/groupRelationships';

import RelatedSeries from './RelatedSeries';
import RelatedWorks from './RelatedWorks';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay';

type DisplayTargets = {
  +[coreEntityType: CoreEntityTypeT]: ?$ReadOnlyArray<CoreEntityTypeT>,
  ...
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

export function isNotSeriesPart(r: RelationshipT): boolean {
  return !seriesPartLinkTypes.has(linkedEntities.link_type[r.linkTypeID].gid);
}

type PropsT = {
  +noRelationshipsHeading?: boolean,
  +relationships?: $ReadOnlyArray<RelationshipTargetTypeGroupT>,
  +source: CoreEntityT,
};

const Relationships = (React.memo<PropsT>(({
  noRelationshipsHeading = false,
  relationships,
  source,
}: PropsT): React.Element<typeof React.Fragment> => {
  if (!relationships) {
    let srcRels = source.relationships;
    if (srcRels && source.entityType === 'series') {
      srcRels = srcRels.filter(isNotSeriesPart);
    }
    relationships = groupRelationships(
      srcRels,
      {types: displayTargets[source.entityType]},
    );
  }

  const hiddenArtistCredit: ?ArtistCreditT = source.entityType === 'artist'
    ? {names: [{artist: source, joinPhrase: '', name: source.name}]}
    : (source.artistCredit || null);

  return (
    <>
      {relationships.length ? (
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
}): React.AbstractComponent<PropsT>);

export default Relationships;
