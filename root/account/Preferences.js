/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout from '../components/UserAccountLayout';
import {withCatalystContext} from '../context';
import PreferencesForm from '../static/scripts/account/components/PreferencesForm';
import type {PreferencesFormPropsT} from '../static/scripts/account/components/PreferencesForm';
import {l} from '../static/scripts/common/i18n';
import * as manifest from '../static/manifest';

type Props = {|
  +$c: CatalystContextT,
  ...PreferencesFormPropsT,
|};

const Preferences = withCatalystContext(({$c, ...props}) => (
  <UserAccountLayout
    page="preferences"
    title={l('Preferences')}
    user={$c.user}
  >
    <PreferencesForm {...props} />
    {manifest.js('account/preferences')}
  </UserAccountLayout>
));

export default Preferences;
