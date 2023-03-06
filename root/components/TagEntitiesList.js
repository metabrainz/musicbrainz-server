/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {type AccountLayoutUserT} from '../components/UserAccountLayout.js';
import {CatalystContext} from '../context.mjs';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import TagLink, {UserTagLink}
  from '../static/scripts/common/components/TagLink.js';
import {ENTITIES} from '../static/scripts/common/constants.js';
import expand2text from '../static/scripts/common/i18n/expand2text.js';
import {formatCount} from '../statistics/utilities.js';
import UserTagFilters from '../user/components/UserTagFilters.js';

type Props = {
  +showDownvoted?: boolean,
  +showLink?: boolean,
  +showVotesSelect?: boolean,
  +tag: TagT,
  +taggedEntities: {
    +[entityType: string]: {
      +count: number,
      +tags: $ReadOnlyArray<{
        +count: number,
        +entity: CoreEntityT,
        +entity_id: number,
      }>,
    },
  },
  +user?: AccountLayoutUserT | EditorT,
};

const TagEntitiesList = ({
  showDownvoted = false,
  showLink = false,
  showVotesSelect = false,
  tag,
  taggedEntities,
  user,
}: Props): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);

  const totalCount = Object.values(taggedEntities)
    .reduce((count, info) => count + info.count, 0);

  const tagContent = showLink
    ? <TagLink tag={tag.name} />
    : tag.name;

  if (showDownvoted && !user) {
    throw new Error('A user must be specified to show downvoted tags');
  }

  const buildTagEntitiesListSection = (
    entityType: string,
    title: string,
    seeAllMessage: $Call<typeof N_ln, string, string>,
    showDownvoted: boolean,
  ) => {
    const tags = taggedEntities[entityType];

    if (!tags || !tags.count) {
      return null;
    }

    const url = showDownvoted
      ? ENTITIES[entityType].url + '?show_downvoted=1'
      : ENTITIES[entityType].url;


    return (
      <React.Fragment key={entityType}>
        <h3>{title}</h3>
        <ul>
          {tags.tags.map(tag => (
            <li key={tag.entity_id}>
              <DescriptiveLink entity={tag.entity} />
            </li>
          ))}
          {tags.count > tags.tags.length ? (
            <li key="see-all">
              <em>
                {user ? (
                  <UserTagLink
                    content={expand2text(
                      seeAllMessage(tags.count),
                      {num: formatCount($c, tags.count)},
                    )}
                    subPath={url}
                    tag={tag.name}
                    username={user.name}
                  />
                ) : (
                  <TagLink
                    content={expand2text(
                      seeAllMessage(tags.count),
                      {num: formatCount($c, tags.count)},
                    )}
                    subPath={url}
                    tag={tag.name}
                  />
                )}
              </em>
            </li>
          ) : null}
        </ul>
      </React.Fragment>
    );
  };

  return (
    <>
      <h2>
        {user ? (
          showDownvoted
            ? exp.l(
              'Entities where {user} downvoted “{tag}”',
              {tag: tagContent, user: user.name},
            )
            : exp.l(
              'Entities {user} tagged as “{tag}”',
              {tag: tagContent, user: user.name},
            )
        ) : (
          exp.l('Entities tagged as “{tag}”', {tag: tagContent})
        )}
      </h2>
      {showVotesSelect ? (
        <UserTagFilters
          showDownvoted={showDownvoted}
          showVotesSelect
        />
      ) : null}
      <p>
        {texp.ln(
          '{num} entity found',
          '{num} entities found',
          totalCount,
          {num: formatCount($c, totalCount)},
        )}
      </p>
      {/*
        * The below use N_ln so languages with non-Germanic pluralization
        * rules (i.e., any that make number distinctions above the
        * threshold where we'll actually show the string) can translate
        * properly. However, the strings are the same in English because
        * we do not make a distinction other than for 1, which will never
        * show in this case.
      */}
      {buildTagEntitiesListSection('area', l('Areas'), N_ln(
        'See all {num} areas',
        'See all {num} areas',
      ), showDownvoted)}
      {buildTagEntitiesListSection('artist', l('Artists'), N_ln(
        'See all {num} artists',
        'See all {num} artists',
      ), showDownvoted)}
      {buildTagEntitiesListSection('event', l('Events'), N_ln(
        'See all {num} events',
        'See all {num} events',
      ), showDownvoted)}
      {buildTagEntitiesListSection('instrument', l('Instruments'), N_ln(
        'See all {num} instruments',
        'See all {num} instruments',
      ), showDownvoted)}
      {buildTagEntitiesListSection('label', l('Labels'), N_ln(
        'See all {num} labels',
        'See all {num} labels',
      ), showDownvoted)}
      {buildTagEntitiesListSection('place', l('Places'), N_ln(
        'See all {num} places',
        'See all {num} places',
      ), showDownvoted)}
      {buildTagEntitiesListSection('release_group', l('Release Groups'), N_ln(
        'See all {num} release groups',
        'See all {num} release groups',
      ), showDownvoted)}
      {buildTagEntitiesListSection('release', l('Releases'), N_ln(
        'See all {num} releases',
        'See all {num} releases',
      ), showDownvoted)}
      {buildTagEntitiesListSection('recording', l('Recordings'), N_ln(
        'See all {num} recordings',
        'See all {num} recordings',
      ), showDownvoted)}
      {buildTagEntitiesListSection('series', l('Series'), N_ln(
        'See all {num} series',
        'See all {num} series',
      ), showDownvoted)}
      {buildTagEntitiesListSection('work', l('Works'), N_ln(
        'See all {num} works',
        'See all {num} works',
      ), showDownvoted)}
    </>
  );
};

export default TagEntitiesList;
