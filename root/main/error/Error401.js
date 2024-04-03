/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CONTACT_URL} from '../../constants.js';
import {CatalystContext} from '../../context.mjs';

import ErrorLayout from './ErrorLayout.js';

component Error401() {
  const $c = React.useContext(CatalystContext);
  return (
    <ErrorLayout title={l('Unauthorized request')}>
      <p>
        <strong>
          {l('Sorry, you are not authorized to view this page.')}
        </strong>
      </p>

      {$c.user && !$c.user.has_confirmed_email_address ? (
        <p>
          {exp.l(
            `You must first {url|add and verify your email address} before
             being able to edit or add anything to the database.`,
            {url: '/account/edit'},
          )}
        </p>
      ) : null}

      <p>
        {exp.l(
          `If you think this is a mistake, please {contact|contact us}
           with the name of your account.`,
          {contact: CONTACT_URL},
        )}
      </p>
    </ErrorLayout>
  );
}

export default Error401;
