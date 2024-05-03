/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {ACCESS_SCOPE_PERMISSIONS} from '../constants.js';
import Layout from '../layout/index.js';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';

component OAuth2Authorize(
  application: ApplicationT,
  form: SecureConfirmFormT,
  offline: boolean,
  permissions: $ReadOnlyArray<number>,
) {
  return (
    <Layout fullWidth title={l('OAuth authorization')}>
      <h1>{l('OAuth authorization')}</h1>

      <p>
        {texp.l(
          '{app} is requesting permission to:',
          {app: application.name},
        )}
      </p>

      <ul>
        {permissions.map(perm => (
          <li key={perm}>{ACCESS_SCOPE_PERMISSIONS[perm]()}</li>
        ))}
        {application.is_server && offline ? (
          <li>
            {l(`Perform the above operations when I'm not using the
                application`)}
          </li>
        ) : null}
      </ul>

      <form method="post" name="confirm">
        <FormCsrfToken form={form} />
        <span className="buttons">
          <button
            className="negative"
            name="confirm.cancel"
            type="submit"
            value="1"
          >
            {l('No thanks')}
          </button>
          <button name="confirm.submit" type="submit" value="1">
            {l('Allow access')}
          </button>
        </span>
      </form>
    </Layout>
  );
}

export default OAuth2Authorize;
