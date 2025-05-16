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
  +[coreEntityType: RelatableEntityTypeT]:
    ?$ReadOnlyArray<RelatableEntityTypeT>,
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
    'genre',
  ],
  label: [
    'artist',
    'url',
    'label',
    'place',
    'area',
    'series',
    'instrument',
    'genre',
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
    'genre',
  ],
};

component _Relationship(
  noRelationshipsHeading: boolean = false,
  relationships as passedRelationships?:
    $ReadOnlyArray<RelationshipTargetTypeGroupT>,
  showIfEmpty: boolean = false,
  source: RelatableEntityT,
) {
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
}

const Relationships: component(...React.PropsOf<_Relationship>) =
  React.memo(_Relationship);

export default Relationships;
