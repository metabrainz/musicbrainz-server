/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import type {AccountLayoutUserT} from '../components/UserAccountLayout.js';
import {CatalystContext} from '../context.mjs';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import TagLink from '../static/scripts/common/components/TagLink.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import expand2text from '../static/scripts/common/i18n/expand2text.js';
import {formatCount} from '../statistics/utilities.js';
import UserTagFilters from '../user/components/UserTagFilters.js';

import TagLayout from './TagLayout.js';

const upvotedHeadingText: {+[entity: string]: () => string} = {
  area: N_l('Areas tagged as “{tag}”'),
  artist: N_l('Artists tagged as “{tag}”'),
  event: N_l('Events tagged as “{tag}”'),
  instrument: N_l('Instruments tagged as “{tag}”'),
  label: N_l('Labels tagged as “{tag}”'),
  place: N_l('Places tagged as “{tag}”'),
  recording: N_l('Recordings tagged as “{tag}”'),
  release: N_l('Releases tagged as “{tag}”'),
  release_group: N_l('Release groups tagged as “{tag}”'),
  series: N_lp('Series tagged as “{tag}”', 'plural series'),
  work: N_l('Works tagged as “{tag}”'),
};

const userUpvotedHeadingText: {+[entity: string]: () => string} = {
  area: N_l('Areas {user} tagged as “{tag}”'),
  artist: N_l('Artists {user} tagged as “{tag}”'),
  event: N_l('Events {user} tagged as “{tag}”'),
  instrument: N_l('Instruments {user} tagged as “{tag}”'),
  label: N_l('Labels {user} tagged as “{tag}”'),
  place: N_l('Places {user} tagged as “{tag}”'),
  recording: N_l('Recordings {user} tagged as “{tag}”'),
  release: N_l('Releases {user} tagged as “{tag}”'),
  release_group: N_l('Release groups {user} tagged as “{tag}”'),
  series: N_lp('Series {user} tagged as “{tag}”', 'plural series'),
  work: N_l('Works {user} tagged as “{tag}”'),
};

const downvotedHeadingText: {+[entity: string]: () => string} = {
  area: N_l('Areas where {user} downvoted “{tag}”'),
  artist: N_l('Artists where {user} downvoted “{tag}”'),
  event: N_l('Events where {user} downvoted “{tag}”'),
  instrument: N_l('Instruments where {user} downvoted “{tag}”'),
  label: N_l('Labels where {user} downvoted “{tag}”'),
  place: N_l('Places where {user} downvoted “{tag}”'),
  recording: N_l('Recordings where {user} downvoted “{tag}”'),
  release: N_l('Releases where {user} downvoted “{tag}”'),
  release_group: N_l('Release groups where {user} downvoted “{tag}”'),
  series: N_l('Series where {user} downvoted “{tag}”'),
  work: N_l('Works where {user} downvoted “{tag}”'),
};

const resultCountText: {
  +[entityType: string]: (val: number) => string, ...
} = {
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

function getTagEntityListHeading(
  user: ?string,
  tag: string,
  showDownvoted: boolean,
  entityType: string,
): Expand2ReactOutput {
  return expand2react(
    (user == null ? (
      upvotedHeadingText
    ) : showDownvoted ? (
      downvotedHeadingText
    ) : (
      userUpvotedHeadingText
    )
    )[entityType](),
    {tag: <TagLink tag={tag} />, user: user ?? ''},
  );
}

type EntityListContentProps = {
  +entityTags: $ReadOnlyArray<{
    +count?: number,
    +entity: CentralEntityT,
    +entity_id: number,
  }>,
  +entityType: string,
  +pager: PagerT,
  +showDownvoted?: boolean,
  +showVotesSelect?: boolean,
  +tag: string,
  +user?: AccountLayoutUserT,
};

type EntityListProps = {
  +entityTags: $ReadOnlyArray<{
    +count: number,
    +entity: CentralEntityT,
    +entity_id: number,
  }>,
  +entityType: string,
  +page: string,
  +pager: PagerT,
  +tag: TagT,
};

export const EntityListContent = ({
  entityTags,
  entityType,
  pager,
  showDownvoted = false,
  showVotesSelect = false,
  tag,
  user,
}: EntityListContentProps): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <h2>
        {getTagEntityListHeading(user?.name, tag, showDownvoted, entityType)}
      </h2>
      {showVotesSelect ? (
        <UserTagFilters
          showDownvoted={showDownvoted}
          showVotesSelect
        />
      ) : null}
      <p>
        {expand2text(
          resultCountText[entityType](pager.total_entries),
          {num: formatCount($c, pager.total_entries)},
        )}
      </p>
      <PaginatedResults pager={pager}>
        <ul>
          {entityTags.map(tag => (
            <li key={tag.entity_id}>
              {tag.count == null
                ? null
                : String(tag.count) + ' - '}
              <DescriptiveLink entity={tag.entity} />
            </li>
          ))}
        </ul>
      </PaginatedResults>
    </>
  );
};

const EntityList = ({
  entityTags,
  entityType,
  page,
  pager,
  tag,
}: EntityListProps): React.Element<typeof TagLayout> => (
  <TagLayout page={page} tag={tag}>
    <EntityListContent
      entityTags={entityTags}
      entityType={entityType}
      pager={pager}
      tag={tag.name}
    />
  </TagLayout>
);

export default EntityList;
