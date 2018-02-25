/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';
import React from 'react';

import Frag from '../../components/Frag';
import {l, lp} from '../../static/scripts/common/i18n';

import Search from './Search';

function userLink(userName, path) {
  return `/user/${encodeURIComponent(userName)}${path}`;
}

type UserProp = {|+user: CatalystUserT|};

const AccountMenu = ({user}: UserProp) => (
  <li className="account" tabIndex="-1">
    <span className="menu-header">{user.name}{'\xA0\u25BE'}</span>
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
        <a href="/logout">{l('Log Out')}</a>
      </li>
    </ul>
  </li>
);

const DataMenu = ({user}: UserProp) => {
  const userName = user.name;

  return (
    <li className="data" tabIndex="-1">
      <span className="menu-header">{l('My Data')}{'\xA0\u25BE'}</span>
      <ul>
        <li>
          <a href={userLink(userName, '/collections')}>{l('My Collections')}</a>
        </li>
        <li>
          <a href={userLink(userName, '/ratings')}>{l('My Ratings')}</a>
        </li>
        <li>
          <a href={userLink(userName, '/tags')}>{l('My Tags')}</a>
        </li>
        <li className="separator">
          <a href={userLink(userName, '/edits/open')}>{l('My Open Edits')}</a>
        </li>
        <li>
          <a href={userLink(userName, '/edits/all')}>{l('All My Edits')}</a>
        </li>
        <li>
          <a href="/edit/subscribed">{l('Edits for Subscribed Entities')}</a>
        </li>
        <li>
          <a href="/edit/subscribed_editors">{l('Edits by Subscribed Editors')}</a>
        </li>
        <li>
          <a href="/edit/notes-received">{l('Notes Left on My Edits')}</a>
        </li>
      </ul>
    </li>
  );
};

const AdminMenu = ({user}: UserProp) => (
  <li className="admin" tabIndex="-1">
    <span className="menu-header">{l('Admin')}{'\xA0\u25BE'}</span>
    <ul>
      {user.is_location_editor ? (
        <li>
          <a href="/area/create">{lp('Add Area', 'button/menu')}</a>
        </li>
      ) : null}

      {user.is_relationship_editor ? (
        <Frag>
          <li>
            <a href="/instrument/create">{lp('Add Instrument', 'button/menu')}</a>
          </li>
          <li>
            <a href="/relationships">{l('Edit Relationship Types')}</a>
          </li>
        </Frag>
      ) : null}

      {user.is_wiki_transcluder ? (
        <li>
          <a href="/admin/wikidoc">{l('Transclude WikiDocs')}</a>
        </li>
      ) : null}

      {user.is_banner_editor ? (
        <li>
          <a href="/admin/banner/edit">{l('Edit Banner Message')}</a>
        </li>
      ) : null}

      {user.is_account_admin ? (
        <li>
          <a href="/admin/attributes">{l('Edit Attributes')}</a>
        </li>
      ) : null}
    </ul>
  </li>
);

const UserMenu = () => (
  <ul className="menu" tabIndex="-1">
    {$c.user ? (
      <Frag>
        <AccountMenu user={$c.user} />
        <DataMenu user={$c.user} />
        {$c.user.is_admin ? <AdminMenu user={$c.user} /> : null}
      </Frag>
    ) : (
      <Frag>
        <li>
          <a href={'/login?uri=' + encodeURIComponent($c.req.query_params.uri || $c.relative_uri)}>
            {l('Log In')}
          </a>
        </li>
        <li>
          <a href={'/register?uri=' + encodeURIComponent($c.req.query_params.uri || $c.relative_uri)}>
            {l('Create Account')}
          </a>
        </li>
      </Frag>
    )}
  </ul>
);

const TopMenu = () => (
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
