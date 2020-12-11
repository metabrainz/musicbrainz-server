/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import expand2text from '../static/scripts/common/i18n/expand2text';
import {formatCount} from '../statistics/utilities';

import TagLayout from './TagLayout';

const headingsText = {
  area: N_ln('{num} area found', '{num} areas found'),
  artist: N_ln('{num} artist found', '{num} artists found'),
  event: N_ln('{num} event found', '{num} events found'),
  instrument: N_ln('{num} instrument found', '{num} instruments found'),
  label: N_ln('{num} label found', '{num} labels found'),
  place: N_ln('{num} place found', '{num} places found'),
  recording: N_ln('{num} recording found', '{num} recordings found'),
  release: N_ln('{num} release found', '{num} releases found'),
  release_group: N_ln(
    '{num} release group found',
    '{num} release groups found',
  ),
  series: N_ln('{num} series found', '{num} series found'),
  work: N_ln('{num} work found', '{num} works found'),
};

const noEntitiesText = {
  area: N_l('No areas with this tag were found.'),
  artist: N_l('No artists with this tag were found.'),
  event: N_l('No events with this tag were found.'),
  instrument: N_l('No instruments with this tag were found.'),
  label: N_l('No labels with this tag were found.'),
  place: N_l('No places with this tag were found.'),
  recording: N_l('No recordings with this tag were found.'),
  release: N_l('No releases with this tag were found.'),
  release_group: N_l('No release groups with this tag were found.'),
  series: N_l('No series with this tag were found.'),
  work: N_l('No works with this tag were found.'),
};

type Props = {
  +$c: CatalystContextT,
  +entityTags: $ReadOnlyArray<{
    +count: number,
    +entity: CoreEntityT,
    +entity_id: number,
  }>,
  +entityType: string,
  +page: string,
  +pager: PagerT,
  +tag: TagT,
};

const EntityList = ({
  $c,
  entityTags,
  entityType,
  page,
  pager,
  tag,
}: Props): React.Element<typeof TagLayout> => (
  <TagLayout $c={$c} page={page} tag={tag}>
    <h2>
      {expand2text(
        headingsText[entityType](pager.total_entries),
        {num: formatCount($c, pager.total_entries)},
      )}
    </h2>

    {entityTags.length ? (
      <PaginatedResults pager={pager}>
        <ul>
          {entityTags.map(tag => (
            <li key={tag.entity_id}>
              {tag.count}
              {' - '}
              <DescriptiveLink entity={tag.entity} />
            </li>
          ))}
        </ul>
      </PaginatedResults>
    ) : <p>{noEntitiesText[entityType]()}</p>}
  </TagLayout>
);

export default EntityList;
