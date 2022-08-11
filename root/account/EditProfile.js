/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  sanitizedAccountLayoutUser,
} from '../components/UserAccountLayout.js';
import * as manifest from '../static/manifest.mjs';
import EditProfileForm
  from '../static/scripts/account/components/EditProfileForm.js';
import type {EditProfileFormPropsT}
  from '../static/scripts/account/components/EditProfileForm.js';

type Props = {
  ...EditProfileFormPropsT,
  +$c: CatalystContextT,
};

const EditProfile = ({
  $c,
  ...props
}: Props): React.Element<typeof UserAccountLayout> | null => {
  const user = $c.user;
  if (!user) {
    return null;
  }
  return (
    <UserAccountLayout
      entity={sanitizedAccountLayoutUser(user)}
      page="edit_profile"
      title={l('Edit Profile')}
    >
      <h2>{l('Edit Profile')}</h2>
      <p>
        {exp.l(
          `See also your {uri|user preferences}, which include
           your privacy settings.`,
          {uri: '/account/preferences'},
        )}
      </p>
      <EditProfileForm {...props} />
      {manifest.js('account/edit')}
    </UserAccountLayout>
  );
};

export default EditProfile;
