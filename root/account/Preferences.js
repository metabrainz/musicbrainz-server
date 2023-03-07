/*
 * @flow strict-local
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
import {CatalystContext} from '../context.mjs';
import * as manifest from '../static/manifest.mjs';
import type {PreferencesFormPropsT}
  from '../static/scripts/account/components/PreferencesForm.js';
import PreferencesForm
  from '../static/scripts/account/components/PreferencesForm.js';

const Preferences = (
  props: PreferencesFormPropsT,
): React$Element<typeof UserAccountLayout> | null => {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  if (!user) {
    return null;
  }
  return (
    <UserAccountLayout
      entity={sanitizedAccountLayoutUser(user)}
      page="preferences"
      title={l('Preferences')}
    >
      <PreferencesForm {...props} />
      {manifest.js('account/preferences')}
    </UserAccountLayout>
  );
};

export default Preferences;
