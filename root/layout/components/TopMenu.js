/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RequestLogin from '../../components/RequestLogin.js';
import {CatalystContext} from '../../context.mjs';
import {l_admin} from '../../static/scripts/common/i18n/admin.js';
import {
  isAccountAdmin,
  isAdmin,
  isBannerEditor,
  isLocationEditor,
  isRelationshipEditor,
  isWikiTranscluder,
} from '../../static/scripts/common/utility/privileges.js';
import returnUri, {returnToCurrentPage} from '../../utility/returnUri.js';

import Search from './Search.js';

function userLink(userName: string, path: string) {
  return `/user/${encodeURIComponent(userName)}${path}`;
}

type UserProp = {+user: UnsanitizedEditorT};

type AccountMenuPropsT = {
  +user: UnsanitizedEditorT,
};

const AccountMenu = ({
  user,
}: AccountMenuPropsT) => {
  const $c = React.useContext(CatalystContext);
  return (
    <li className="account" tabIndex="-1">
      <span className="menu-header">
        {user.name}
        {'\xA0\u25BE'}
      </span>
      <ul>
        <li>
          <a href={userLink(user.name, '')}>{l('Profile')}</a>
        </li>
        <li>
          <a href="/account/applications">{l('Applications')}</a>
        </li>
        <li>
          <a href={userLink(user.name, '/subscriptions/artist')}>
            {l('Subscriptions')}
          </a>
        </li>
        <li>
          <a
            href={
              '/logout' + (
                $c.stash.current_action_requires_auth === true
                  ? ''
                  : ('?' + returnToCurrentPage($c))
              )
            }
          >
            {l('Log out')}
          </a>
        </li>
      </ul>
    </li>
  );
};

const DataMenu = ({user}: UserProp) => {
  const userName = user.name;

  return (
    <li className="data" tabIndex="-1">
      <span className="menu-header">
        {l('My data')}
        {'\xA0\u25BE'}
      </span>
      <ul>
        <li>
          <a href={userLink(userName, '/collections')}>
            {l('My collections')}
          </a>
        </li>
        <li>
          <a href={userLink(userName, '/ratings')}>{l('My ratings')}</a>
        </li>
        <li>
          <a href={userLink(userName, '/tags')}>
            {lp('My tags', 'folksonomy')}
          </a>
        </li>
        <li className="separator">
          <a href={userLink(userName, '/edits/open')}>{l('My open edits')}</a>
        </li>
        <li>
          <a href={userLink(userName, '/edits')}>{l('All my edits')}</a>
        </li>
        <li>
          <a href="/edit/subscribed">{l('Edits for subscribed entities')}</a>
        </li>
        <li>
          <a href="/edit/subscribed_editors">
            {l('Edits by subscribed editors')}
          </a>
        </li>
        <li>
          <a href="/edit/notes-received">{l('Notes left on my edits')}</a>
        </li>
      </ul>
    </li>
  );
};

const AdminMenu = ({user}: UserProp) => (
  <li className="admin" tabIndex="-1">
    <span className="menu-header">
      {l('Admin')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      {isLocationEditor(user) ? (
        <li>
          <a href="/area/create">{lp('Add area', 'interactive')}</a>
        </li>
      ) : null}

      {isRelationshipEditor(user) ? (
        <>
          <li>
            <a href="/instrument/create">
              {lp('Add instrument', 'interactive')}
            </a>
          </li>
          <li>
            <a href="/genre/create">{lp('Add genre', 'interactive')}</a>
          </li>
          <li>
            <a href="/relationships">{l('Edit relationship types')}</a>
          </li>
        </>
      ) : null}

      {isWikiTranscluder(user) ? (
        <li>
          <a href="/admin/wikidoc">{l_admin('Transclude WikiDocs')}</a>
        </li>
      ) : null}

      {isBannerEditor(user) ? (
        <li>
          <a href="/admin/banner/edit">{l_admin('Edit banner message')}</a>
        </li>
      ) : null}

      {isAccountAdmin(user) ? (
        <>
          <li>
            <a href="/attributes">{l_admin('Edit attributes')}</a>
          </li>
          <li>
            <a href="/admin/statistics-events">
              {l_admin('Edit statistics events')}
            </a>
          </li>
          <li>
            <a href="/admin/email-search">{l_admin('Email search')}</a>
          </li>
          <li>
            <a href="/admin/privilege-search">
              {l_admin('Privilege search')}
            </a>
          </li>
          <li>
            <a href="/admin/locked-usernames/search">
              {l_admin('Locked username search')}
            </a>
          </li>
        </>
      ) : null}
    </ul>
  </li>
);

const UserMenu = () => {
  const $c = React.useContext(CatalystContext);
  return (
    <ul className="menu" tabIndex="-1">
      {$c.user ? (
        <>
          <AccountMenu user={$c.user} />
          <DataMenu user={$c.user} />
          {isAdmin($c.user) ? <AdminMenu user={$c.user} /> : null}
        </>
      ) : (
        <>
          <li>
            <RequestLogin text={lp('Log in', 'interactive')} />
          </li>
          <li>
            <a href={returnUri($c, '/register')}>
              {lp('Create account', 'interactive')}
            </a>
          </li>
        </>
      )}
    </ul>
  );
};

const TopMenu = (): React$Element<'div'> => (
  <div className="top">
    <div className="links-container">
      <UserMenu />
    </div>
    <div className="search-container">
      <Search />
    </div>
  </div>
);

export default TopMenu;
