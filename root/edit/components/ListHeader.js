/*
 * @flow
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import ENTITIES from '../../../entities';
import DBDefs from '../../static/scripts/common/DBDefs.mjs';
import uriWith from '../../utility/uriWith';

type Props = {
  +entity?: CoreEntityT | CollectionT,
  +isSearch?: boolean,
  +page: string,
  +refineUrlArgs?: {+[argument: string]: string},
  +username?: string,
};

const ListHeader = ({
  entity,
  isSearch = false,
  page,
  refineUrlArgs,
  username,
}: Props): React.Element<'table'> => {
  const $c = React.useContext(CatalystContext);
  const isSecureConnection = $c.req.secure;
  const protocol = isSecureConnection ? 'https://' : 'http://';
  const openParam = $c.req.query_params.open;
  const entityUrlFragment = entity
    ? ENTITIES[entity.entityType].url
    : undefined;
  const isEntityAllPage = !!entity && page === entity.entityType + '_all';
  const isEntityOpenPage = !!entity && page === entity.entityType + '_open';

  return (
    <table className="search-help">
      <tr>
        <th>
          {l('Quick links:')}
        </th>
        <td>
          {isSearch ? null : (
            <a href="/search/edits">{l('Search for edits')}</a>
          )}
          {refineUrlArgs ? (
            <>
              {' | '}
              <a
                href={uriWith(
                  protocol + DBDefs.WEB_SERVER + '/search/edits',
                  refineUrlArgs,
                )}
              >
                {l('Refine this search')}
              </a>
            </>
          ) : null}
          {nonEmpty(username) && page === 'user_all' ? (
            <>
              {' | '}
              <a href={`/user/${username}/edits/open`}>
                {exp.l('Open edits for {user}', {user: username})}
              </a>
            </>
          ) : null}
          {nonEmpty(username) && page !== 'user_all' ? (
            <>
              {' | '}
              <a href={`/user/${username}/edits`}>
                {exp.l('All edits for {user}', {user: username})}
              </a>
            </>
          ) : null}
          {entity && entityUrlFragment && isEntityAllPage ? (
            <>
              {' | '}
              <a href={`/${entityUrlFragment}/${entity.gid}/open_edits`}>
                {entity.entityType === 'collection'
                  ? l('Open edits for this collection')
                  : l('Open edits for this entity')}
              </a>
            </>
          ) : null}
          {entity && entityUrlFragment && isEntityOpenPage ? (
            <>
              {' | '}
              <a href={`/${entityUrlFragment}/${entity.gid}/edits`}>
                {entity.entityType === 'collection'
                  ? l('All edits for this collection')
                  : l('All edits for this entity')}
              </a>
            </>
          ) : null}
          {page === 'subscribed' && !(openParam === '1') ? (
            <>
              {' | '}
              <a href="/edit/subscribed?open=1">
                {l('Open edits for your subscribed entities')}
              </a>
            </>
          ) : null}
          {page === 'subscribed' && openParam === '1' ? (
            <>
              {' | '}
              <a href="/edit/subscribed?open=0">
                {l('All edits for your subscribed entities')}
              </a>
            </>
          ) : null}
          {page === 'subscribed_editors' && !(openParam === '1') ? (
            <>
              {' | '}
              <a href="/edit/subscribed_editors?open=1">
                {l('Open edits for your subscribed editors')}
              </a>
            </>
          ) : null}
          {page === 'subscribed_editors' && openParam === '1' ? (
            <>
              {' | '}
              <a href="/edit/subscribed_editors?open=0">
                {l('All edits for your subscribed editors')}
              </a>
            </>
          ) : null}
          {page === 'open' ? null : (
            <>
              {' | '}
              <a href="/edit/open">
                {l('Open edits')}
              </a>
            </>
          )}
          {$c.user && page !== 'subscribed' ? (
            <>
              {' | '}
              <a href="/edit/subscribed">
                {l('Subscribed entities')}
              </a>
            </>
          ) : null}
          {$c.user && page !== 'subscribed_editors' ? (
            <>
              {' | '}
              <a href="/edit/subscribed_editors">
                {l('Subscribed editors')}
              </a>
            </>
          ) : null}
          {$c.user ? (
            <>
              {' | '}
              <a href="/vote">
                {l('Voting suggestions')}
              </a>
            </>
          ) : null}
        </td>
      </tr>
      <tr>
        <th>
          {l('Help:')}
        </th>
        <td>
          <a href="/doc/Introduction_to_Voting">
            {l('Introduction to Voting')}
          </a>
          {' | '}
          <a href="/doc/Introduction_to_Editing">
            {l('Introduction to Editing')}
          </a>
          {' | '}
          <a href="/doc/Style">{l('Style guidelines')}</a>
        </td>
      </tr>
    </table>
  );
};

export default ListHeader;
