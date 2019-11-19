/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import RequestLogin from '../../components/RequestLogin';
import returnUri from '../../utility/returnUri';

import MenuDropdown from './MenuDropdown';
import Search from './Search';

function userLink(userName, path) {
  return `/user/${encodeURIComponent(userName)}${path}`;
}

type UserProp = {+user: CatalystUserT};

const AccountMenu = ({user}: UserProp) => (
  <MenuDropdown
    className="account"
    id="account-menu-dropdown"
    label={user.name}
  >
    <a className="dropdown-item" href={userLink(user.name, '')}>
      {l('Profile')}
    </a>
    <a className="dropdown-item" href="/account/applications">
      {l('Applications')}
    </a>
    <a
      className="dropdown-item"
      href={userLink(user.name, '/subscriptions/artist')}
    >
      {l('Subscriptions')}
    </a>
    <a className="dropdown-item" href="/logout">{l('Log Out')}</a>
  </MenuDropdown>
);

const DataMenu = ({user}: UserProp) => {
  const userName = user.name;

  return (
    <MenuDropdown
      className="data"
      id="data-menu-dropdown"
      label={l('My Data')}
    >
      <a className="dropdown-item" href={userLink(userName, '/collections')}>
        {l('My Collections')}
      </a>
      <a className="dropdown-item" href={userLink(userName, '/ratings')}>
        {l('My Ratings')}
      </a>
      <a className="dropdown-item" href={userLink(userName, '/tags')}>
        {l('My Tags')}
      </a>
      <div className="dropdown-divider" />
      <a className="dropdown-item" href={userLink(userName, '/edits/open')}>
        {l('My Open Edits')}
      </a>
      <a className="dropdown-item" href={userLink(userName, '/edits')}>
        {l('All My Edits')}
      </a>
      <a className="dropdown-item" href="/edit/subscribed">
        {l('Edits for Subscribed Entities')}
      </a>
      <a className="dropdown-item" href="/edit/subscribed_editors">
        {l('Edits by Subscribed Editors')}
      </a>
      <a className="dropdown-item" href="/edit/notes-received">
        {l('Notes Left on My Edits')}
      </a>
    </MenuDropdown>
  );
};

const AdminMenu = ({user}: UserProp) => (
  <MenuDropdown
    className="admin"
    id="admin-menu-dropdown"
    label={l('Admin')}
  >
    {user.is_location_editor ? (
      <a className="dropdown-item" href="/area/create">
        {lp('Add Area', 'button/menu')}
      </a>
    ) : null}

    {user.is_relationship_editor ? (
      <>
        <a className="dropdown-item" href="/instrument/create">
          {lp('Add Instrument', 'button/menu')}
        </a>
        <a className="dropdown-item" href="/genre/create">
          {lp('Add Genre', 'button/menu')}
        </a>
        <a className="dropdown-item" href="/relationships">
          {l('Edit Relationship Types')}
        </a>
      </>
    ) : null}

    {user.is_wiki_transcluder ? (
      <a className="dropdown-item" href="/admin/wikidoc">
        {l('Transclude WikiDocs')}
      </a>
    ) : null}

    {user.is_banner_editor ? (
      <a className="dropdown-item" href="/admin/banner/edit">
        {l('Edit Banner Message')}
      </a>
    ) : null}

    {user.is_account_admin ? (
      <a className="dropdown-item" href="/admin/attributes">
        {l('Edit Attributes')}
      </a>
    ) : null}
  </MenuDropdown>
);

const UserMenu = ({$c}) => (
  <ul className="navbar-nav flex-grow-1 align-items-md-end">
    {$c.user ? (
      <>
        <AccountMenu user={$c.user} />
        <DataMenu user={$c.user} />
        {$c.user.is_admin ? <AdminMenu user={$c.user} /> : null}
      </>
    ) : (
      <>
        <li>
          <RequestLogin $c={$c} className="nav-link" text={l('Log In')} />
        </li>
        <li>
          <a className="nav-link" href={returnUri($c, '/register')}>
            {l('Create Account')}
          </a>
        </li>
      </>
    )}
  </ul>
);

const TopMenu = ({$c}: {$c: CatalystContextT}) => (
  <div className="d-flex w-100 flex-column flex-md-row" id="headerid-topmenu">
    <UserMenu $c={$c} />
    <Search />
  </div>
);

export default TopMenu;
