/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context';
import DBDefs from '../static/scripts/common/DBDefs';
import buildTab from '../utility/buildTab';

import Tabs from './Tabs';
import type {AccountLayoutUserT} from './UserAccountLayout';

function buildTabs(
  $c: CatalystContextT,
  user: AccountLayoutUserT,
  page: string,
): $ReadOnlyArray<React.Element<'li'>> {
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);
  const showAdmin = Boolean($c.user && $c.user.is_account_admin);
  const showPrivate = showAdmin || viewingOwnProfile;

  const userName = encodeURIComponent(user.name);
  const userPath = '/user/' + userName;

  const tabs = [buildTab(page, l('Profile'), userPath, 'index')];

  if (showPrivate || user.preferences.public_subscriptions) {
    tabs.push(buildTab(
      page,
      l('Subscriptions'),
      userPath + '/subscriptions/artist',
      'subscriptions',
    ));
  }

  tabs.push(buildTab(
    page,
    l('Subscribers'),
    userPath + '/subscribers',
    'subscribers',
  ));
  tabs.push(buildTab(
    page,
    l('Collections'),
    userPath + '/collections',
    'collections',
  ));

  if (showPrivate || user.preferences.public_tags) {
    tabs.push(buildTab(page, l('Tags'), userPath + '/tags', 'tags'));
  }

  if (showPrivate || user.preferences.public_ratings) {
    tabs.push(buildTab(page, l('Ratings'), userPath + '/ratings', 'ratings'));
  }

  if (viewingOwnProfile) {
    tabs.push(buildTab(
      page,
      l('Edit Profile'),
      '/account/edit',
      'edit_profile',
    ));
    tabs.push(buildTab(
      page,
      l('Preferences'),
      '/account/preferences',
      'preferences',
    ));
    tabs.push(buildTab(
      page,
      l('Change Password'),
      '/account/change-password',
      'change_password',
    ));
    tabs.push(buildTab(
      page,
      l('Donation Check'),
      '/account/donation',
      'donation',
    ));
  }

  if (showAdmin ||
    DBDefs.DB_STAGING_TESTING_FEATURES && $c.user) {
    tabs.push(buildTab(
      page,
      l('Edit User'),
      '/admin/user/edit/' + userName,
      'edit_user',
    ));
  }

  if (showPrivate && !user.deleted) {
    tabs.push(buildTab(
      page,
      l('Delete Account'),
      '/admin/user/delete/' + userName,
      'delete',
    ));
  }

  return tabs;
}

type Props = {
  +page: string,
  +user: AccountLayoutUserT,
};

const UserAccountTabs = ({
  user,
  page,
}: Props): React.Element<typeof Tabs> => (
  <Tabs>
    <CatalystContext.Consumer>
      {($c: CatalystContextT) => buildTabs($c, user, page)}
    </CatalystContext.Consumer>
  </Tabs>
);

export default UserAccountTabs;
