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
import PreferencesForm
  from '../static/scripts/account/components/PreferencesForm.js';
import type {PreferencesFormPropsT}
  from '../static/scripts/account/components/PreferencesForm.js';
import * as manifest from '../static/manifest.mjs';

type Props = {
  ...PreferencesFormPropsT,
  +$c: $ReadOnly<{...CatalystContextT, user: UnsanitizedEditorT}>,
};

const Preferences = ({
  $c,
  ...props
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout
    entity={sanitizedAccountLayoutUser($c.user)}
    page="preferences"
    title={l('Preferences')}
  >
    <PreferencesForm {...props} />
    {manifest.js('account/preferences')}
  </UserAccountLayout>
);

export default Preferences;
