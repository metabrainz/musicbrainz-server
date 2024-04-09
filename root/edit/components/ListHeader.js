/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../../entities.mjs';
import {CatalystContext} from '../../context.mjs';
import DBDefs from '../../static/scripts/common/DBDefs.mjs';
import uriWith from '../../utility/uriWith.js';

component QuickLinks(
  entity?: EditableEntityT | CollectionT,
  isSearch: boolean = false,
  page: string,
  refineUrlArgs?: {+[argument: string]: string},
  username?: string,
) {
  const $c = React.useContext(CatalystContext);
  const isSecureConnection = $c.req.secure;
  const protocol = isSecureConnection ? 'https://' : 'http://';
  const openParam = $c.req.query_params.open;
  const entityUrlFragment = entity
    ? ENTITIES[entity.entityType].url
    : undefined;
  const isEntityAllPage = !!entity && page === entity.entityType + '_all';
  const isEntityOpenPage = !!entity && page === entity.entityType + '_open';

  const quickLinks = [];

  if (nonEmpty(username)) {
    if (page === 'user_all') {
      quickLinks.push(
        <a href={`/user/${username}/edits/open`}>
          <strong>
            {exp.l('Open edits for {user}', {user: username})}
          </strong>
        </a>,
      );
    } else {
      quickLinks.push(
        <a href={`/user/${username}/edits`}>
          <strong>
            {exp.l('All edits for {user}', {user: username})}
          </strong>
        </a>,
      );
    }
  }
  if (entity && entityUrlFragment) {
    if (isEntityAllPage) {
      quickLinks.push(
        <a href={`/${entityUrlFragment}/${entity.gid}/open_edits`}>
          <strong>
            {entity.entityType === 'collection'
              ? l('Open edits for this collection')
              : l('Open edits for this entity')}
          </strong>
        </a>,
      );
    }
    if (isEntityOpenPage) {
      quickLinks.push(
        <a href={`/${entityUrlFragment}/${entity.gid}/edits`}>
          <strong>
            {entity.entityType === 'collection'
              ? l('All edits for this collection')
              : l('All edits for this entity')}
          </strong>
        </a>,
      );
    }
  }
  if (page === 'subscribed') {
    if (openParam === '1') {
      quickLinks.push(
        <a href="/edit/subscribed?open=0">
          <strong>
            {l('All edits for your subscribed entities')}
          </strong>
        </a>,
      );
    } else {
      quickLinks.push(
        <a href="/edit/subscribed?open=1">
          <strong>
            {l('Open edits for your subscribed entities')}
          </strong>
        </a>,
      );
    }
  }
  if (page === 'subscribed_editors') {
    if (openParam === '1') {
      quickLinks.push(
        <a href="/edit/subscribed_editors?open=0">
          <strong>
            {l('All edits for your subscribed editors')}
          </strong>
        </a>,
      );
    } else {
      quickLinks.push(
        <a href="/edit/subscribed_editors?open=1">
          <strong>
            {l('Open edits for your subscribed editors')}
          </strong>
        </a>,
      );
    }
  }
  if (refineUrlArgs) {
    quickLinks.push(
      <a
        href={uriWith(
          protocol + DBDefs.WEB_SERVER + '/search/edits',
          refineUrlArgs,
        )}
      >
        <strong>
          {l('Refine this search')}
        </strong>
      </a>,
    );
  }
  if ($c.user) {
    if (page !== 'subscribed') {
      quickLinks.push(
        <a href="/edit/subscribed">
          {l('Subscribed entities')}
        </a>,
      );
    }
    if (page !== 'subscribed_editors') {
      quickLinks.push(
        <a href="/edit/subscribed_editors">
          {l('Subscribed editors')}
        </a>,
      );
    }
  }
  if (page !== 'open') {
    quickLinks.push(
      <a href="/edit/open">
        {lp('Open edits', 'noun')}
      </a>,
    );
  }
  if ($c.user) {
    quickLinks.push(
      <a href="/vote">
        {l('Voting suggestions')}
      </a>,
    );
  }
  if (!isSearch) {
    quickLinks.push(
      <a href="/search/edits">
        {l('Search for edits')}
      </a>,
    );
  }
  return React.createElement(React.Fragment, null, ...quickLinks.reduce(
    (accum: Array<React$Node>, link, index) => {
      accum.push(link);
      if (index < (quickLinks.length - 1)) {
        accum.push(' | ');
      }
      return accum;
    }, [],
  ));
}

component ListHeader(...props: React.PropsOf<QuickLinks>) {
  return (
    <table className="search-help">
      <tr>
        <th>
          {l('Quick links:')}
        </th>
        <td>
          <QuickLinks {...props} />
        </td>
      </tr>
      <tr>
        <th>
          {l('Help:')}
        </th>
        <td>
          <a href="/doc/Introduction_to_Voting">
            {l('Introduction to voting')}
          </a>
          {' | '}
          <a href="/doc/Introduction_to_Editing">
            {l('Introduction to editing')}
          </a>
          {' | '}
          <a href="/doc/Style">{l('Style guidelines')}</a>
        </td>
      </tr>
    </table>
  );
}

export default ListHeader;
