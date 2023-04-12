/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import TagEntitiesList from '../components/TagEntitiesList.js';
import UserAccountLayout, {type AccountLayoutUserT}
  from '../components/UserAccountLayout.js';

import {getTagListHeading, getTagListUrl} from './UserTagList.js';

type Props = {
  +showDownvoted?: boolean,
  +tag: TagT,
  +taggedEntities: {
    +[entityType: string]: {
      +count: number,
      +tags: $ReadOnlyArray<{
        +count: number,
        +entity: TaggableEntityT,
        +entity_id: number,
      }>,
    },
  },
  +user: AccountLayoutUserT,
};

const UserTag = ({
  showDownvoted = false,
  tag,
  taggedEntities,
  user,
}: Props): React$Element<typeof UserAccountLayout> => (
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
