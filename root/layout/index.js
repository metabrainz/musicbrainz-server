/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import getRequestCookie from '../utility/getRequestCookie';
import {RT_SLAVE} from '../static/scripts/common/constants';
import * as DBDefs from '../static/scripts/common/DBDefs';
import {l} from '../static/scripts/common/i18n';

import Footer from './components/Footer';
import Header from './components/Header';
import Head from './components/Head';
import MergeHelper from './components/MergeHelper';

const DismissBannerButton = ({bannerName}) => (
  <button
    className="dismiss-banner remove-item icon"
    data-banner-name={bannerName}
    type="button"
  />
);

const ServerDetailsBanner = () => {
  if (DBDefs.DB_STAGING_SERVER) {
    let description = DBDefs.DB_STAGING_SERVER_DESCRIPTION;
    if (!description) {
      if (DBDefs.IS_BETA) {
        description = l('This beta test server allows testing of new features with the live database.');
      } else {
        description = l('This is a MusicBrainz development server.');
      }
    }
    return (
      <div className="banner server-details">
        <p>
          {description}
          {' '}
          {l('{uri|Return to musicbrainz.org}.',
            {
              uri: '//musicbrainz.org' + (DBDefs.BETA_REDIRECT_HOSTNAME === 'musicbrainz.org' ? '?unset_beta=1' : ''),
            })}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  if (DBDefs.REPLICATION_TYPE === RT_SLAVE) {
    return (
      <div className="banner server-details">
        <p>
          {l('This is a MusicBrainz mirror server. To edit or make changes to the data, please {uri|return to musicbrainz.org}.',
            {uri: '//musicbrainz.org'})}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  return null;
};

const Layout = ({$c, ...props}) => (
  <html lang={$c.stash.current_language_html}>
    <Head {...props} />

    <body>
      <Header {...props} />

      {!getRequestCookie($c.req, 'server_details_dismissed_mtime') && <ServerDetailsBanner />}

      {!!($c.stash.alert && $c.stash.alert_mtime > getRequestCookie($c.req, 'alert_dismissed_mtime', 0)) &&
        <div className="banner warning-header">
          <p dangerouslySetInnerHTML={{__html: $c.stash.alert}} />
          <DismissBannerButton bannerName="alert" />
        </div>}

      {!!DBDefs.DB_READ_ONLY &&
        <div className="banner server-details">
          <p>
            {l('The server is temporarily in read-only mode for database maintenance.')}
          </p>
        </div>}

      {!!($c.stash.new_edit_notes &&
          $c.stash.new_edit_notes_mtime > getRequestCookie($c.req, 'new_edit_notes_dismissed_mtime', 0) &&
          ($c.user.is_limited || getRequestCookie($c.req, 'alert_new_edit_notes', 'true') !== 'false')) &&
          <div className="banner new-edit-notes">
            <p>
              {l('{link|New notes} have been left on some of your edits. Please make sure to read them and respond if necessary.',
                {link: '/edit/notes-received'})}
            </p>
            <DismissBannerButton bannerName="new_edit_notes" />
          </div>}

      {!!$c.stash.makes_no_changes &&
        <div className="banner warning-header">
          <p>{l('The data you have submitted does not make any changes to the data already present.')}</p>
        </div>}

      {!!($c.sessionid && $c.flash.message) &&
        <div className="banner flash">
          <p dangerouslySetInnerHTML={{__html: $c.flash.message}} />
        </div>}

      <div className={(props.fullWidth ? 'fullwidth ' : '') + (props.homepage ? 'homepage' : '')} id="page">
        {props.children}
        <div style={{clear: 'both'}} />
      </div>

      {($c.session.merger && !$c.stash.hide_merge_helper) && <MergeHelper />}

      <Footer {...props} />
    </body>
  </html>
);

export default withCatalystContext(Layout);
