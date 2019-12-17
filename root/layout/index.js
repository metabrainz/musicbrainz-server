/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import {formatUserDateObject} from '../utility/formatUserDate';
import getRequestCookie from '../utility/getRequestCookie';
import {RT_SLAVE} from '../static/scripts/common/constants';
import * as DBDefs from '../static/scripts/common/DBDefs';

import Footer from './components/Footer';
import Header from './components/Header';
import Head, {type HeadProps} from './components/Head';
import MergeHelper from './components/MergeHelper';

const DismissBannerButton = ({bannerName}) => (
  <button
    className="dismiss-banner remove-item icon"
    data-banner-name={bannerName}
    type="button"
  />
);

const BirthdayCakes = () => (
  <span aria-label={l('Birthday cakes')} role="img">
    {String.fromCodePoint(0x1F382)}
    {String.fromCodePoint(0x1F382)}
    {String.fromCodePoint(0x1F382)}
  </span>
);

function showBirthdayBanner($c) {
  const birthDate = $c.user ? $c.user.birth_date : null;
  if (!birthDate) {
    return false;
  }
  const now = new Date();
  return birthDate.day ===
           Number(formatUserDateObject($c, now, {format: '%d'})) &&
         birthDate.month ===
           Number(formatUserDateObject($c, now, {format: '%m'})) &&
         !getRequestCookie($c.req, 'birthday_message_dismissed_mtime');
}

const ServerDetailsBanner = () => {
  if (DBDefs.DB_STAGING_SERVER) {
    let description = DBDefs.DB_STAGING_SERVER_DESCRIPTION;
    if (!description) {
      if (DBDefs.IS_BETA) {
        description = l(
          `This beta test server allows testing of new features
           with the live database.`,
        );
      } else {
        description = l('This is a MusicBrainz development server.');
      }
    }
    return (
      <div className="banner server-details">
        <p>
          {description}
          {' '}
          {exp.l(
            '{uri|Return to musicbrainz.org}.',
            {
              uri: '//musicbrainz.org' + (
                DBDefs.BETA_REDIRECT_HOSTNAME === 'musicbrainz.org'
                  ? '?unset_beta=1'
                  : ''),
            },
          )}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  if (DBDefs.REPLICATION_TYPE === RT_SLAVE) {
    return (
      <div className="banner server-details">
        <p>
          {exp.l(
            `This is a MusicBrainz mirror server. To edit or make changes
             to the data, please {uri|return to musicbrainz.org}.`,
            {uri: '//musicbrainz.org'},
          )}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  return null;
};

export type Props = $ReadOnly<{
  ...HeadProps,
  children: React$Node,
  fullWidth?: boolean,
}>;

const Layout = ({$c, ...props}: Props) => (
  <html lang={$c.stash.current_language_html}>
    <Head {...props} />

    <body>
      <Header {...props} />

      {!getRequestCookie($c.req, 'server_details_dismissed_mtime') &&
        <ServerDetailsBanner />}

      {!!($c.stash.alert && ($c.stash.alert_mtime ?? Infinity) >
        Number(getRequestCookie($c.req, 'alert_dismissed_mtime', '0'))) &&
        <div className="banner warning-header">
          <p dangerouslySetInnerHTML={{__html: $c.stash.alert}} />
          <DismissBannerButton bannerName="alert" />
        </div>}

      {!!DBDefs.DB_READ_ONLY &&
        <div className="banner server-details">
          <p>
            {l(
              `The server is temporarily in read-only mode
               for database maintenance.`,
            )}
          </p>
        </div>}

      {showBirthdayBanner($c) &&
        <div className="banner birthday-message">
          <p>
            <BirthdayCakes />
            {' '}
            {l('Happy birthday, and thanks for contributing to MusicBrainz!')}
            {' '}
            <BirthdayCakes />
          </p>
          <DismissBannerButton bannerName="birthday_message" />
        </div>}

      {!!($c.stash.new_edit_notes &&
          ($c.stash.new_edit_notes_mtime ?? Infinity) >
          Number(
            getRequestCookie($c.req, 'new_edit_notes_dismissed_mtime', '0'),
          ) &&
          ($c.user?.is_limited ||
          getRequestCookie($c.req, 'alert_new_edit_notes', 'true') !==
          'false')) &&
          <div className="banner new-edit-notes">
            <p>
              {exp.l(
                `{link|New notes} have been left on some of your edits.
                 Please make sure to read them and respond if necessary.`,
                {link: '/edit/notes-received'},
              )}
            </p>
            <DismissBannerButton bannerName="new_edit_notes" />
          </div>}

      {!!$c.stash.makes_no_changes &&
        <div className="banner warning-header">
          <p>
            {l(
              `The data you have submitted does not make any changes
               to the data already present.`,
            )}
          </p>
        </div>}

      {!!($c.sessionid && $c.flash.message) &&
        <div className="banner flash">
          <p dangerouslySetInnerHTML={{__html: $c.flash.message}} />
        </div>}

      <div
        className={(props.fullWidth ? 'fullwidth ' : '') +
          (props.homepage ? 'homepage' : '')}
        id="page"
      >
        {props.children}
        <div style={{clear: 'both'}} />
      </div>

      {($c.session?.merger && !$c.stash.hide_merge_helper) &&
        <MergeHelper merger={$c.session.merger} />}

      <Footer {...props} />
    </body>
  </html>
);

export default withCatalystContext(Layout);
