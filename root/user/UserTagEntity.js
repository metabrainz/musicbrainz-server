/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import UserAccountLayout from '../components/UserAccountLayout.js';
import {
  formatPluralEntityTypeName,
} from '../static/scripts/common/utility/formatEntityTypeName.js';
import {EntityListContent} from '../tag/EntityList.js';

import {getTagListHeading, getTagListUrl} from './UserTagList.js';

type EntityTagsT = $ReadOnlyArray<{
  +entity: TaggableEntityT,
  +entity_id: number,
}>;

function getAllEntitiesTagUrl(
  user: string,
  tag: string,
  showDownvoted: boolean,
): string {
  return (
    '/user/' + encodeURIComponent(user) +
    '/tag/' + encodeURIComponent(tag) +
    '?show_downvoted=' + (showDownvoted ? '1' : '0')
  );
}

component UserTagEntity(
  entityTags: EntityTagsT,
  entityType: string,
  pager: PagerT,
  showDownvoted: boolean = false,
  tag: TagT,
  user: AccountLayoutUserT,
) {
  return (
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
}

export default UserTagEntity;
