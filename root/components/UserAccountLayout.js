/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import EditorLink from '../static/scripts/common/components/EditorLink';
import sanitizedEditor from '../utility/sanitizedEditor.mjs';

import UserAccountTabs from './UserAccountTabs';

export type AccountLayoutUserT = {
  +avatar: string,
  +deleted: boolean,
  +entityType: 'editor',
  +id: number,
  +is_limited: boolean,
  +name: string,
  +preferences: {
    +public_ratings: boolean,
    +public_subscriptions: boolean,
    +public_tags: boolean,
  },
  +privileges: number,
};

type Props = {
  +children: React.Node,
  +entity: AccountLayoutUserT,
  +page: string,
  +title?: string,
};

export function sanitizedAccountLayoutUser(
  editor: UnsanitizedEditorT,
): AccountLayoutUserT {
  const preferences = editor.preferences;
  return {
    ...sanitizedEditor(editor),
    preferences: {
      public_ratings: preferences.public_ratings,
      public_subscriptions: preferences.public_subscriptions,
      public_tags: preferences.public_tags,
    },
  };
}

const UserAccountLayout = ({
  children,
  entity: user,
  page,
  title,
  ...layoutProps
}: Props): React.Element<typeof Layout> => (
  <Layout
    fullWidth
    title={nonEmpty(title)
      ? hyphenateTitle(texp.l('Editor “{user}”', {user: user.name}), title)
      : texp.l('Editor “{user}”', {user: user.name})}
    {...layoutProps}
  >
    <h1>
      <EditorLink avatarSize={54} editor={user} />
    </h1>
    <UserAccountTabs page={page} user={user} />
    {children}
  </Layout>
);

export default UserAccountLayout;
