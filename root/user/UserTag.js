/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout';
import TagEntitiesList from '../components/TagEntitiesList';

import {getTagListHeading, getTagListUrl} from './UserTagList';

type Props = {
  +$c: CatalystContextT,
  +showDownvoted?: boolean,
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
  +user: AccountLayoutUserT,
};

const UserTag = ({
  $c,
  showDownvoted = false,
  tag,
  taggedEntities,
  user,
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout entity={user} page="tags">
    <nav className="breadcrumb">
      <ol>
        <li>
          <a href={getTagListUrl(user.name, showDownvoted)}>
            {getTagListHeading(user.name, showDownvoted)}
          </a>
        </li>
        <li>
          {tag.name}
        </li>
      </ol>
    </nav>
    <TagEntitiesList
      $c={$c}
      showDownvoted={showDownvoted}
      showLink
      showVotesSelect
      tag={tag}
      taggedEntities={taggedEntities}
      user={user}
    />
  </UserAccountLayout>
);

export default UserTag;
