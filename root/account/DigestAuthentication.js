/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';

component DigestAuthentication(
  form: DigestAuthFormT,
  token?: string,
) {
  const action = form.field.action.value;

  return (
    <Layout fullWidth title={lp('Digest access authentication', 'header')}>
      <h1>{lp('Digest access authentication', 'header')}</h1>

        {form.has_errors ? (
          <FieldErrors field={form} />
        ) : action === 'disable' ? (
          <p>
            {exp.l(`Digest authentication is
                    <strong>disabled</strong> on your account.`)}
          </p>
        ) : action === 'reset_token' ? (
          <>
            <p>
              {exp.l(
                `Your new digest authentication token is below.
                 Use this in place of your MusicBrainz account password in
                 applications that require it.
                 You cannot retrieve this token again after closing the page;
                 if it’s lost, you can reset it from
                 {applications_url|Applications}.`,
                {applications_url: '/account/applications'},
              )}
            </p>
            <p>
              <code>{token}</code>
            </p>
          </>
        ) : null}

        <p>
          {exp.lp(
            '{applications_url|Back to Applications}.',
            'interactive',
            {applications_url: '/account/applications'},
          )}
        </p>
    </Layout>
  );
}

export default DigestAuthentication;
