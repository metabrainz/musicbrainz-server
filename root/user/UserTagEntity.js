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
import {
  formatPluralEntityTypeName,
} from '../static/scripts/common/utility/formatEntityTypeName';
import {EntityListContent} from '../tag/EntityList';

import {getTagListHeading, getTagListUrl} from './UserTagList';

type UserTagEntityProps = {
  +$c: CatalystContextT,
  +entityTags: $ReadOnlyArray<{
    +entity: CoreEntityT,
    +entity_id: number,
  }>,
  +entityType: string,
  +pager: PagerT,
  +showDownvoted?: boolean,
  +tag: TagT,
  +user: AccountLayoutUserT,
};

function getAllEntitiesTagUrl(
  user: string,
  tag: string,
  showDownvoted: boolean,
): Expand2ReactOutput {
  return (
    '/user/' + encodeURIComponent(user) +
    '/tag/' + encodeURIComponent(tag) +
    '?show_downvoted=' + (showDownvoted ? '1' : '0')
  );
}

const UserTagEntity = ({
  $c,
  entityTags,
  entityType,
  pager,
  showDownvoted = false,
  tag,
  user,
}: UserTagEntityProps): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout entity={user} page="tags">
    <nav className="breadcrumb">
      <ol>
        <li>
          <a href={getTagListUrl(user.name, showDownvoted)}>
            {getTagListHeading(user.name, showDownvoted)}
          </a>
        </li>
        <li>
          <a
            href={getAllEntitiesTagUrl(
              user.name,
              tag.name,
              showDownvoted,
            )}
          >
            {tag.name}
          </a>
        </li>
        <li>
          {formatPluralEntityTypeName(entityType)}
        </li>
      </ol>
    </nav>
    <EntityListContent
      $c={$c}
      entityTags={entityTags}
      entityType={entityType}
      pager={pager}
      showDownvoted={showDownvoted}
      showVotesSelect
      tag={tag.name}
      user={user}
    />
  </UserAccountLayout>
);

export default UserTagEntity;
