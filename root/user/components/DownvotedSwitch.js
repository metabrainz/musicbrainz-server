/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {AccountLayoutUserT} from '../../components/UserAccountLayout';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import uriWith from '../../utility/uriWith';

type AllDownvotedSwitchProps = {
  +$c: CatalystContextT,
  +showDownvoted?: boolean,
  +user: AccountLayoutUserT,
};

type DownvotedSwitchProps = {
  +$c: CatalystContextT,
  +entityType?: string,
  +showDownvoted: boolean,
  +tag: TagT,
  +user: AccountLayoutUserT,
};

const downvotesText = {
  area: N_l(
    `Showing areas where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|areas {user}
     has tagged with “{tag}”} instead).`,
  ),
  artist: N_l(
    `Showing artists where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|artists {user}
     has tagged with “{tag}”} instead).`,
  ),
  event: N_l(
    `Showing events where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|events {user}
     has tagged with “{tag}”} instead).`,
  ),
  instrument: N_l(
    `Showing instruments where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|instruments {user}
     has tagged with “{tag}”} instead).`,
  ),
  label: N_l(
    `Showing labels where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|labels {user}
     has tagged with “{tag}”} instead).`,
  ),
  place: N_l(
    `Showing places where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|places {user}
     has tagged with “{tag}”} instead).`,
  ),
  recording: N_l(
    `Showing recordings where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|recordings {user}
     has tagged with “{tag}”} instead).`,
  ),
  release: N_l(
    `Showing releases where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|releases {user}
     has tagged with “{tag}”} instead).`,
  ),
  release_group: N_l(
    `Showing release groups where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|release groups {user}
     has tagged with “{tag}”} instead).`,
  ),
  series: N_l(
    `Showing series where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|series {user}
     has tagged with “{tag}”} instead).`,
  ),
  work: N_l(
    `Showing works where {user} <strong>has voted against</strong>
     “{tag}” (or see {upvotes_link|works {user}
     has tagged with “{tag}”} instead).`,
  ),
};

const upvotesText = {
  area: N_l(
    `Showing areas {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|areas where {user}
     has voted against “{tag}”} instead).`,
  ),
  artist: N_l(
    `Showing artists {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|artists where {user}
     has voted against “{tag}”} instead).`,
  ),
  event: N_l(
    `Showing events {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|events where {user}
     has voted against “{tag}”} instead).`,
  ),
  instrument: N_l(
    `Showing instruments {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|instruments where {user}
     has voted against “{tag}”} instead).`,
  ),
  label: N_l(
    `Showing labels {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|labels where {user}
     has voted against “{tag}”} instead).`,
  ),
  place: N_l(
    `Showing places {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|places where {user}
     has voted against “{tag}”} instead).`,
  ),
  recording: N_l(
    `Showing recordings {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|recordings where {user}
     has voted against “{tag}”} instead).`,
  ),
  release: N_l(
    `Showing releases {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|releases where {user}
     has voted against “{tag}”} instead).`,
  ),
  release_group: N_l(
    `Showing release groups {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|release groups where {user}
     has voted against “{tag}”} instead).`,
  ),
  series: N_l(
    `Showing series {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|series where {user}
     has voted against “{tag}”} instead).`,
  ),
  work: N_l(
    `Showing works {user} <strong>has tagged</strong> with “{tag}”
     (or show {downvotes_link|works where {user}
     has voted against “{tag}”} instead).`,
  ),
};

export const AllDownvotedSwitch = ({
  $c,
  showDownvoted = false,
  user,
}: AllDownvotedSwitchProps): React.Element<'p'> => (
  <p>
    {showDownvoted ? (
      exp.l(
        `Showing tags {user} <strong>has voted against</strong>.
         Show {upvotes_link|tags {user} has used} instead.`,
        {
          upvotes_link: uriWith($c.req.uri, {show_downvoted: 0}),
          user: user.name,
        },
      )
    ) : (
      exp.l(
        `Showing tags {user} <strong>has used</strong>.
         Show {downvotes_link|tags {user} has voted against} instead.`,
        {
          downvotes_link: uriWith($c.req.uri, {show_downvoted: 1}),
          user: user.name,
        },
      )
    )}
  </p>
);

const DownvotedSwitch = ({
  $c,
  entityType,
  showDownvoted,
  tag,
  user,
}: DownvotedSwitchProps): React.Element<'p'> => (
  <p>
    {showDownvoted ? (
      expand2react(
        nonEmpty(entityType) ? downvotesText[entityType]() : (
          `Showing entities where {user} <strong>has voted against</strong>
           “{tag}” (or see {upvotes_link|entities {user}
           has tagged with “{tag}”} instead).`
        ),
        {
          tag: tag.name,
          upvotes_link: uriWith($c.req.uri, {show_downvoted: 0}),
          user: user.name,
        },
      )
    ) : (
      expand2react(
        nonEmpty(entityType) ? upvotesText[entityType]() : (
          `Showing entities {user} <strong>has tagged</strong> with “{tag}”
           (or show {downvotes_link|entities where {user}
           has voted against “{tag}”} instead).`
        ),
        {
          downvotes_link: uriWith($c.req.uri, {show_downvoted: 1}),
          tag: tag.name,
          user: user.name,
        },
      )
    )}
  </p>
);

export default DownvotedSwitch;
