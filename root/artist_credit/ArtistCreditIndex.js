/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../entities.json';
import ArtistCreditUsageLink
  from '../static/scripts/common/components/ArtistCreditUsageLink.js';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import expand2text from '../static/scripts/common/i18n/expand2text.js';
import {formatCount} from '../statistics/utilities.js';

import ArtistCreditLayout from './ArtistCreditLayout.js';

type Props = {
  +$c: CatalystContextT,
  +artistCredit: $ReadOnly<{...ArtistCreditT, +id: number}>,
  +creditedEntities: {
    +[entityType: string]: {
      +count: number,
      +entities: $ReadOnlyArray<CoreEntityT | TrackT>,
    },
  },
};

function buildSection(
  props: Props,
  entityType: string,
  title: string,
  seeAllMessage: $Call<typeof N_ln, string, string>,
  listId: string,
) {
  const entities = props.creditedEntities[entityType];

  if (!entities.count) {
    return null;
  }

  const entityUrlFragment = ENTITIES[entityType].url;

  return (
    <React.Fragment key={entityType}>
      <h3>{title}</h3>
      <ul id={listId}>
        {entities.entities.map(entity => (
          <li key={entity.id}>
            {entity.entityType === 'track' ? (
              <a href={`/track/${entity.gid}`}>
                {entity.name}
              </a>
            ) : <EntityLink entity={entity} />}
          </li>
        ))}
        {entities.count > entities.entities.length ? (
          <li key="see-all">
            <em>
              <ArtistCreditUsageLink
                artistCredit={props.artistCredit}
                content={expand2text(
                  seeAllMessage(entities.count),
                  {num: formatCount(props.$c, entities.count)},
                )}
                subPath={entityUrlFragment}
              />
            </em>
          </li>
        ) : null}
      </ul>
    </React.Fragment>
  );
}

const ArtistCreditIndex = (
  props: Props,
): React.Element<typeof ArtistCreditLayout> => (
  <ArtistCreditLayout
    artistCredit={props.artistCredit}
    page=""
  >
    <p>
      {l('This artist credit is composed of the following artists:')}
    </p>
    <ul id="artist-credit-artists">
      {props.artistCredit.names.map((name, index) => (
        <li key={'name-' + index}>
          <DescriptiveLink entity={name.artist} />
          {name.artist.name === name.name ? null : (
            <>
              {' '}
              {texp.l(
                'credited as “{credit}”',
                {credit: name.name},
              )}
            </>
          )}
        </li>
      ))}
    </ul>
    <h2>{l('Uses')}</h2>
    {/*
      * The below use N_ln so languages with non-Germanic pluralization
      * rules (i.e., any that make number distinctions above the
      * threshold where we'll actually show the string) can translate
      * properly. However, the strings are the same in English because
      * we do not make a distinction other than for 1, which will never
      * show in this case.
      */}
    {buildSection(
      props,
      'release_group',
      l('Release Groups'),
      N_ln(
        'See all {num} release groups',
        'See all {num} release groups',
      ),
      'artist-credit-release-groups',
    )}
    {buildSection(
      props,
      'release',
      l('Releases'), N_ln(
        'See all {num} releases',
        'See all {num} releases',
      ),
      'artist-credit-releases',
    )}
    {buildSection(
      props,
      'recording',
      l('Recordings'),
      N_ln(
        'See all {num} recordings',
        'See all {num} recordings',
      ),
      'artist-credit-recordings',
    )}
    {buildSection(
      props,
      'track',
      l('Tracks'),
      N_ln(
        'See all {num} tracks',
        'See all {num} tracks',
      ),
      'artist-credit-tracks',
    )}
  </ArtistCreditLayout>
);

export default ArtistCreditIndex;
