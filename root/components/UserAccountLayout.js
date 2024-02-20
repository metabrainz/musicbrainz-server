/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import sanitizedEditor from '../utility/sanitizedEditor.mjs';

import UserAccountTabs from './UserAccountTabs.js';

export type AccountLayoutUserT = {
  +avatar: string,
  +deleted: boolean,
  +entityType: 'editor',
  +id: number,
  +name: string,
  +preferences: {
    +public_ratings: boolean,
    +public_subscriptions: boolean,
    +public_tags: boolean,
  },
  +privileges: number,
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

component UserAccountLayout(
  children: React$Node,
  entity as user: AccountLayoutUserT,
  page: string,
  title?: string,
) {
  return (
    <Layout
      fullWidth
      title={nonEmpty(title)
        ? hyphenateTitle(texp.l('Editor “{user}”', {user: user.name}), title)
        : texp.l('Editor “{user}”', {user: user.name})}
    >
      <h1>
        <EditorLink avatarSize={32} editor={user} />
      </h1>
      <UserAccountTabs page={page} user={user} />
      {children}
    </Layout>
  );
}

export default UserAccountLayout;
