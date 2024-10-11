/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {CatalystContext} from '../context.mjs';
import {DB_STAGING_TESTING_FEATURES}
  from '../static/scripts/common/DBDefs.mjs';
import {isAccountAdmin} from '../static/scripts/common/utility/privileges.js';
import buildTab from '../utility/buildTab.js';

import Tabs from './Tabs.js';
import type {AccountLayoutUserT} from './UserAccountLayout.js';

function buildTabs(
  $c: CatalystContextT,
  user: AccountLayoutUserT,
  page: string,
): $ReadOnlyArray<React.MixedElement> {
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  const userName = encodeURIComponent(user.name);
  const userPath = '/user/' + userName;

  const tabs = [buildTab(page, l('Profile'), userPath, 'index')];

  const userDeleted = user.deleted;
  const showAdmin = !userDeleted && isAccountAdmin($c.user);
  const hasPublicSubscriptions =
    !userDeleted && user.preferences.public_subscriptions;
  const hasPublicTags = !userDeleted && user.preferences.public_tags;
  const hasPublicRatings = !userDeleted && user.preferences.public_ratings;

  const subsRequireAdminPrivs = showAdmin && !hasPublicSubscriptions;
  if ((showAdmin || viewingOwnProfile) || hasPublicSubscriptions) {
    tabs.push(buildTab(
      page,
      l('Subscriptions'),
      userPath + '/subscriptions',
      'subscriptions',
      subsRequireAdminPrivs ? 'private-tab requires-admin-privileges' : '',
    ));
  }

  if (!userDeleted) {
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
  }

  if (viewingOwnProfile || hasPublicTags) {
    tabs.push(
      buildTab(page, lp('Tags', 'folksonomy'), userPath + '/tags', 'tags'),
    );
  }

  if (viewingOwnProfile || hasPublicRatings) {
    tabs.push(buildTab(page, l('Ratings'), userPath + '/ratings', 'ratings'));
  }

  if (viewingOwnProfile) {
    tabs.push(buildTab(
      page,
      l('Edit profile'),
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
      lp('Change password', 'header'),
      '/account/change-password',
      'change_password',
    ));
    tabs.push(buildTab(
      page,
      l('Donation check'),
      '/account/donation',
      'donation',
    ));
  }

  if (showAdmin || (DB_STAGING_TESTING_FEATURES && $c.user)) {
    tabs.push(buildTab(
      page,
      l_admin('Edit user'),
      '/admin/user/edit/' + userName,
      'edit_user',
    ));
  }

  if (!user.deleted) {
    if (viewingOwnProfile) {
      tabs.push(buildTab(
        page,
        lp('Delete account', 'header'),
        '/account/delete',
        'delete',
      ));
    } else if (showAdmin) {
      tabs.push(buildTab(
        page,
        l_admin('Delete account'),
        '/admin/user/delete/' + userName,
        'delete',
      ));
    }
  }

  return tabs;
}

component UserAccountTabs(page: string, user: AccountLayoutUserT) {
  return (
    <Tabs>
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => buildTabs($c, user, page)}
      </CatalystContext.Consumer>
    </Tabs>
  );
}

export default UserAccountTabs;
