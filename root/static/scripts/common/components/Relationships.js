/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import groupRelationships, {
  type RelationshipTargetTypeGroupT,
} from '../utility/groupRelationships.js';

import EntityLink from './EntityLink.js';
import RelatedSeries, {isNotSeriesPart} from './RelatedSeries.js';
import RelatedWorks from './RelatedWorks.js';
import StaticRelationshipsDisplay from './StaticRelationshipsDisplay.js';

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

type PropsT = {
  +noRelationshipsHeading?: boolean,
  +relationships?: $ReadOnlyArray<RelationshipTargetTypeGroupT>,
  +showIfEmpty?: boolean,
  +source: CoreEntityT,
};

const Relationships = (React.memo<PropsT>(({
  noRelationshipsHeading = false,
  relationships: passedRelationships,
  showIfEmpty = false,
  source,
}: PropsT): React.Element<typeof React.Fragment> => {
  let srcRels = source.relationships;
  let relationships = passedRelationships;
  if (!relationships) {
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

  const heading = noRelationshipsHeading
    ? null
    : <h2 className="relationships">{l('Relationships')}</h2>;

  return (
    <>
      {relationships.length ? (
        <>
          {heading}
          <StaticRelationshipsDisplay
            hiddenArtistCredit={hiddenArtistCredit}
            relationships={relationships}
          />
        </>
      ) : source.entityType === 'artist' && srcRels?.length ? (
        <>
          {heading}
          <p>
            {exp.l(
              `{link} only has event relationships,
               which are displayed in the Events tab.`,
              {link: <EntityLink entity={source} />},
            )}
          </p>
        </>
      ) : showIfEmpty ? (
        <>
          {heading}
          <p>
            {exp.l(
              '{link} has no relationships.',
              {link: <EntityLink entity={source} />},
            )}
          </p>
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
