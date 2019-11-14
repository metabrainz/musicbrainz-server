/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import EditorLink from '../static/scripts/common/components/EditorLink';

import UserAccountTabs from './UserAccountTabs';

type Props = {
  +children: React.Node,
  +entity: EditorT,
  +page: string,
  +title?: string,
  ...,
};

const UserAccountLayout = ({
  children,
  entity: user,
  page,
  title,
  ...layoutProps
}: Props) => (
  <Layout
    fullWidth
    title={title
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
