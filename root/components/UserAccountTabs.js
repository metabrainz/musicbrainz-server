/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context';
import * as DBDefs from '../static/scripts/common/DBDefs';
import {l} from '../static/scripts/common/i18n';

import Tabs from './Tabs';

const buildTab = (
  page: string,
  title: string,
  path: string,
  tabPage: string,
) => (
  <li className={tabPage === page ? 'sel' : null} key={tabPage}>
    <a href={path}>{title}</a>
  </li>
);

function buildTabs(
  $c: CatalystContextT,
  user: EditorT,
  page: string,
): React.Node {
  const viewingOwnProfile = $c.user && $c.user.id === user.id;
  const showPrivate = $c.user && $c.user.is_account_admin || viewingOwnProfile;

  const userName = encodeURIComponent(user.name);
  const userPath = '/user/' + userName;

  const tabs = [buildTab(page, l('Profile'), userPath, 'index')];

  if (showPrivate || user.preferences.public_subscriptions) {
    tabs.push(buildTab(page, l('Subscriptions'), userPath + '/subscriptions/artist', 'subscriptions'));
  }

  tabs.push(buildTab(page, l('Subscribers'), userPath + '/subscribers', 'subscribers'));
  tabs.push(buildTab(page, l('Collections'), userPath + '/collections', 'collections'));

  if (showPrivate || user.preferences.public_tags) {
    tabs.push(buildTab(page, l('Tags'), userPath + '/tags', 'tags'));
  }

  if (showPrivate || user.preferences.public_ratings) {
    tabs.push(buildTab(page, l('Ratings'), userPath + '/ratings', 'ratings'));
  }

  if (viewingOwnProfile) {
    tabs.push(buildTab(page, l('Edit Profile'), '/account/edit', 'edit_profile'));
    tabs.push(buildTab(page, l('Preferences'), '/account/preferences', 'preferences'));
    tabs.push(buildTab(page, l('Change Password'), '/account/change-password', 'change_password'));
    tabs.push(buildTab(page, l('Donation Check'), '/account/donation', 'donation'));
  }

  if (showPrivate || DBDefs.DB_STAGING_TESTING_FEATURES && $c.user_exists) {
    tabs.push(buildTab(page, l('Edit User'), '/admin/user/edit/' + userName, 'edit_user'));
  }

  if (showPrivate && !user.deleted) {
    tabs.push(buildTab(page, l('Delete Account'), '/admin/user/delete/' + userName, 'delete'));
  }

  return tabs;
}

type Props = {|
  +page: string,
  +user: EditorT,
|};

const UserAccountTabs = ({
  user,
  page,
}: Props) => (
  <Tabs>
    <CatalystContext.Consumer>
      {($c: CatalystContextT) => buildTabs($c, user, page)}
    </CatalystContext.Consumer>
  </Tabs>
);

export default UserAccountTabs;
