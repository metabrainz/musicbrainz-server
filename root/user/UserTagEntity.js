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
import {EntityListContent} from '../tag/EntityList';

import DownvotedSwitch from './components/DownvotedSwitch';
import UserHasNotUsedTag from './components/UserHasNotUsedTag';
import UserTagHeading from './components/UserTagHeading';

type UserTagEntityProps = {
  +$c: CatalystContextT,
  +entityTags: $ReadOnlyArray<{
    +entity: CoreEntityT,
    +entity_id: number,
  }>,
  +entityType: string,
  +page: string,
  +pager: PagerT,
  +showDownvoted: boolean,
  +tag: TagT,
  +user: AccountLayoutUserT,
};

const UserTagEntity = ({
  $c,
  entityTags,
  entityType,
  page,
  pager,
  showDownvoted,
  tag,
  user,
}: UserTagEntityProps): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout $c={$c} entity={user} page={page}>
    <UserTagHeading
      entityType={entityType}
      showDownvoted={showDownvoted}
      tag={tag}
    />

    <DownvotedSwitch
      $c={$c}
      entityType={entityType}
      showDownvoted={showDownvoted}
      tag={tag}
      user={user}
    />

    <p>
      {showDownvoted ? (
        exp.l(
          'See {tag_link|all votes against tag “{tag}” by {user}}',
          {
            tag: tag.name,
            tag_link: `/user/${user.name}/tag/${tag.name}`,
            user: user.name,
          },
        )
      ) : (
        exp.l(
          'See {tag_link|all uses of tag “{tag}” by {user}}',
          {
            tag: tag.name,
            tag_link: `/user/${user.name}/tag/${tag.name}`,
            user: user.name,
          },
        )
      )}
    </p>

    {entityTags.length > 0 ? (
      <EntityListContent
        entityTags={entityTags}
        entityType={entityType}
        pager={pager}
      />
    ) : (
      <UserHasNotUsedTag
        entityType={entityType}
        showDownvoted={showDownvoted}
        tag={tag}
        user={user}
      />
    )}
  </UserAccountLayout>
);

export default UserTagEntity;
