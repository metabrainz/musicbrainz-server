/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {CatalystContext} from '../context.mjs';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import expand2text from '../static/scripts/common/i18n/expand2text.js';
import {formatCount} from '../statistics/utilities.js';

import ArtistCreditLayout from './ArtistCreditLayout.js';

const headingsText = {
  recording: N_ln('{num} recording found', '{num} recordings found'),
  release: N_ln('{num} release found', '{num} releases found'),
  release_group: N_ln(
    '{num} release group found',
    '{num} release groups found',
  ),
  track: N_ln('{num} track found', '{num} tracks found'),
};

const noEntitiesText = {
  recording: N_l('No recordings with this artist credit were found.'),
  release: N_l('No releases with this artist credit were found.'),
  release_group: N_l('No release groups with this artist credit were found.'),
  track: N_l('No tracks with this artist credit were found.'),
};

component EntityList(
  artistCredit: $ReadOnly<{...ArtistCreditT, +id: number}>,
  entities: $ReadOnlyArray<EntityWithArtistCreditsT>,
  entityType: EntityWithArtistCreditsTypeT,
  page: string,
  pager: PagerT,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <ArtistCreditLayout artistCredit={artistCredit} page={page}>
      <h2>
        {expand2text(
          headingsText[entityType](pager.total_entries),
          {num: formatCount($c, pager.total_entries)},
        )}
      </h2>

      {entities.length ? (
        <PaginatedResults pager={pager}>
          <ul>
            {entities.map(entity => (
              <li key={entity.id}>
                {entity.entityType === 'track' ? (
                  <a href={`/track/${entity.gid}`}>
                    {entity.name}
                  </a>
                ) : <EntityLink entity={entity} />}
              </li>
            ))}
          </ul>
        </PaginatedResults>
      ) : <p>{noEntitiesText[entityType]()}</p>}
    </ArtistCreditLayout>
  );
}

export default EntityList;
