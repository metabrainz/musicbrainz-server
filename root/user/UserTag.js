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
import TagList from '../components/TagList';

import DownvotedSwitch from './components/DownvotedSwitch';
import UserHasNotUsedTag from './components/UserHasNotUsedTag';
import UserTagHeading from './components/UserTagHeading';

type Props = {
  +$c: CatalystContextT,
  +showDownvoted: boolean,
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
  +tagInUse: boolean,
  +user: AccountLayoutUserT,
};

const UserTag = (props: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout $c={props.$c} entity={props.user} page="tags">
    <UserTagHeading showDownvoted={props.showDownvoted} tag={props.tag} />

    <DownvotedSwitch
      $c={props.$c}
      showDownvoted={props.showDownvoted}
      tag={props.tag}
      user={props.user}
    />

    {props.tagInUse ? (
      <TagList {...props} />
    ) : (
      <UserHasNotUsedTag
        showDownvoted={props.showDownvoted}
        tag={props.tag}
        user={props.user}
      />
    )}
  </UserAccountLayout>
);

export default UserTag;
