/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ConfirmLayout from '../../components/ConfirmLayout.js';
import {ACCESS_SCOPE_PERMISSIONS} from '../../constants.js';

type Props = {
  +application: ApplicationT,
  +form: SecureConfirmFormT,
  +permissions: $ReadOnlyArray<number>,
};

const RevokeApplicationAccess = ({
  application,
  form,
  permissions,
}: Props): React$Element<typeof ConfirmLayout> => (
  <ConfirmLayout
    form={form}
    question={
      <>
        <p>
          {texp.l(
            'You’re about to revoke {app}’s permissions to:',
            {app: application.name},
          )}
        </p>
        <ul>
          {permissions.map(permission => (
            <li key={permission}>
              {ACCESS_SCOPE_PERMISSIONS[permission]()}
            </li>
          ))}
        </ul>
        <p>
          {l('Are you sure you want to revoke this application’s access?')}
        </p>
      </>
    }
    title={l('Revoke Application Access')}
  />
);

export default RevokeApplicationAccess;
