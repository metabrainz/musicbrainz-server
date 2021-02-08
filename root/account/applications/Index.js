/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ACCESS_SCOPE_PERMISSIONS} from '../../constants';
import {compare} from '../../static/scripts/common/i18n';
import Layout from '../../layout';
import PaginatedResults from '../../components/PaginatedResults';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';
import loopParity from '../../utility/loopParity';

type Props = {
  +$c: CatalystContextT,
  +applications: $ReadOnlyArray<ApplicationT>,
  +appsPager: PagerT,
  +tokens: $ReadOnlyArray<EditorOAuthTokenT>,
  +tokensPager: PagerT,
};

const buildApplicationRow = (application: ApplicationT, index: number) => (
  <tr className={loopParity(index)} key={application.id}>
    <td>{application.name}</td>
    <td>
      {application.is_server
        ? l('Web Application')
        : l('Installed Application')}
    </td>
    <td><code>{application.oauth_id}</code></td>
    <td><code>{application.oauth_secret}</code></td>
    <td>
      <a href={'/account/applications/edit/' + application.id}>
        {l('Edit')}
      </a>
      {' | '}
      <a href={'/account/applications/remove/' + application.id}>
        {l('Remove')}
      </a>
    </td>
  </tr>
);

const buildTokenRow = (token: EditorOAuthTokenT, index: number) => (
  <tr className={loopParity(index)} key={token.id}>
    <td>{token.application.name}</td>
    <td>{formatScopes(token)}</td>
    <td>
      <a
        href={'/account/applications/revoke-access/' +
          token.application.id + '/' + token.scope}
      >
        {l('Revoke Access')}
      </a>
    </td>
  </tr>
);

function formatScopes(token: EditorOAuthTokenT) {
  const lScopes = token.permissions.map(
    perm => ACCESS_SCOPE_PERMISSIONS[+perm](),
  );

  if (token.is_offline) {
    lScopes.push(l('Offline Access'));
  }

  lScopes.sort(compare);

  return commaOnlyList(lScopes);
}

const Index = ({
  $c,
  applications,
  appsPager,
  tokens,
  tokensPager,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Applications')}>
    <h1>{l('Applications')}</h1>

    <h2>{l('Authorized Applications')}</h2>

    <p>
      {l(
        `Some applications and websites support accessing private data from
         or submitting data to MusicBrainz but require your permission to
         access your account. These are the applications that you have
         authorized to access your MusicBrainz account. If you no longer use
         some of the applications, you can revoke their access.`,
      )}
    </p>

    {tokens.length
      ? (
        <PaginatedResults pageVar="tokens_page" pager={tokensPager}>
          <table className="tbl">
            <thead>
              <tr>
                <th>{l('Application')}</th>
                <th>{l('Access')}</th>
                <th>{l('Actions')}</th>
              </tr>
            </thead>
            <tbody>
              {tokens.map(buildTokenRow)}
            </tbody>
          </table>
        </PaginatedResults>
      ) : (
        <p>{l('You have not authorized any applications.')}</p>
      )}

    <h2>{l('Developer Applications')}</h2>

    <p>
      {exp.l(
        `Do you want to develop an application that uses the
         {mb_api_doc_url|MusicBrainz API}? 
         {register_url|Register an application} to generate OAuth tokens.
         See our {oauth2_doc_url|OAuth documentation} for more details.`,
        {
          mb_api_doc_url: '/doc/MusicBrainz_API',
          oauth2_doc_url: '/doc/Development/OAuth2',
          register_url: '/account/applications/register',
        },
      )}
    </p>

    {applications.length
      ? (
        <PaginatedResults pageVar="apps_page" pager={appsPager}>
          <table className="tbl">
            <thead>
              <tr>
                <th>{l('Application')}</th>
                <th>{l('Type')}</th>
                <th>{l('OAuth Client ID')}</th>
                <th>{l('OAuth Client Secret')}</th>
                <th>{l('Actions')}</th>
              </tr>
            </thead>
            <tbody>
              {applications.map(buildApplicationRow)}
            </tbody>
          </table>
        </PaginatedResults>
      ) : (
        <p>{l('You do not have any registered applications.')}</p>
      )}
  </Layout>
);

export default Index;
