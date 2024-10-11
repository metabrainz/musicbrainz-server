/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {RT_MIRROR} from '../static/scripts/common/constants.js';
import * as DBDefs from '../static/scripts/common/DBDefs.mjs';
import {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList.js';
import parseDate from '../static/scripts/common/utility/parseDate.js';
import {
  getRestrictionsForUser,
  isBeginner,
} from '../static/scripts/common/utility/privileges.js';
import {age} from '../utility/age.js';
import {formatUserDateObject} from '../utility/formatUserDate.js';
import getRequestCookie from '../utility/getRequestCookie.mjs';

import Footer from './components/Footer.js';
import Head from './components/Head.js';
import Header from './components/Header.js';
import MergeHelper from './components/MergeHelper.js';

component DismissBannerButton(bannerName: string) {
  return (
    <button
      className="dismiss-banner remove-item icon"
      data-banner-name={bannerName}
      type="button"
    />
  );
}

component BirthdayCakes() {
  return (
    <span aria-label={l('Birthday cakes')} role="img">
      {String.fromCodePoint(0x1F382)}
      {String.fromCodePoint(0x1F382)}
      {String.fromCodePoint(0x1F382)}
    </span>
  );
}

function showBirthdayBanner($c: CatalystContextT) {
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

component AnniversaryBanner() {
  const $c = React.useContext(CatalystContext);
  const registrationDate = $c.user ? $c.user.registration_date : null;
  if (registrationDate == null) {
    return null;
  }

  const parsedDate = parseDate(registrationDate.slice(0, 10));
  if (parsedDate == null) {
    return null;
  }

  const now = parseDate((new Date()).toISOString().slice(0, 10));
  const editorAge = age({begin_date: parsedDate, end_date: now, ended: true});
  if (editorAge == null) {
    return null;
  }

  const showBanner =
    editorAge[1] === 0 && editorAge[2] === 0 &&
    !getRequestCookie($c.req, 'anniversary_message_dismissed_mtime');

  if (showBanner /*:: === true */) {
    return (
      <div className="banner anniversary-message">
        <p>
          <BirthdayCakes />
          {' '}
          {exp.ln(
            `You’ve been a MusicBrainz editor for {num} year!
             Happy anniversary, and thanks for contributing to MusicBrainz!`,
            `You’ve been a MusicBrainz editor for {num} years!
             Happy anniversary, and thanks for contributing to MusicBrainz!`,
            editorAge[0],
            {num: editorAge[0]},
          )}
          {' '}
          <BirthdayCakes />
        </p>
        <DismissBannerButton bannerName="anniversary_message" />
      </div>
    );
  }

  return null;
}

component ServerDetailsBanner(url: string) {
  const returnUrl = new URL(url);
  returnUrl.port = ''; // won't unset it itself when setting host
  returnUrl.host = nonEmpty(DBDefs.BETA_REDIRECT_HOSTNAME)
    ? DBDefs.BETA_REDIRECT_HOSTNAME
    : 'musicbrainz.org';
  if (DBDefs.IS_BETA) {
    returnUrl.searchParams.append('unset_beta', '1');
  }
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
              uri: returnUrl.toString(),
            },
          )}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  if (DBDefs.REPLICATION_TYPE === RT_MIRROR) {
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
}

component HeaderAndBanners(
  $c: CatalystContextT,
) {
  const showAlert = nonEmpty($c.stash.alert) &&
    ($c.stash.alert_mtime ?? Infinity) > Number(
      getRequestCookie($c.req, 'alert_dismissed_mtime', '0'),
    );

  const showNewEditNotesBanner = $c.stash.new_edit_notes /*:: === true */ &&
    ($c.stash.new_edit_notes_mtime ?? Infinity) > Number(
      getRequestCookie($c.req, 'new_edit_notes_dismissed_mtime', '0'),
    ) && (($c.user &&
      (isBeginner($c.user) || !$c.user.has_confirmed_email_address)) ||
      getRequestCookie($c.req, 'alert_new_edit_notes', 'true') !== 'false');

  const restrictions = getRestrictionsForUser($c.user);

  return (
    <>
      <Header />

      {restrictions.length > 0 ? (
        <div className="banner editing-disabled">
          <p>
            {exp.l(
              `An admin has set the following restrictions
               on your account: {list}.
               If you haven’t already been contacted
               about why, please {uri|send us a message}.`,
              {
                list: commaOnlyListText(restrictions),
                uri: {href: 'https://metabrainz.org/contact', target: '_blank'},
              },
            )}
          </p>
        </div>
      ) : null}

      {getRequestCookie($c.req, 'server_details_dismissed_mtime')
        ? null
        : <ServerDetailsBanner url={$c.req.uri} />}

      {showAlert ? (
        <div className="banner warning-header">
          <p dangerouslySetInnerHTML={{__html: $c.stash.alert}} />
          <DismissBannerButton bannerName="alert" />
        </div>
      ) : null}

      {DBDefs.DB_READ_ONLY ? (
        <div className="banner server-details">
          <p>
            {l(
              `The server is temporarily in read-only mode
               for database maintenance.`,
            )}
          </p>
        </div>
      ) : null}

      {showBirthdayBanner($c) ? (
        <div className="banner birthday-message">
          <p>
            <BirthdayCakes />
            {' '}
            {l(`Happy birthday, and thanks
                for contributing to MusicBrainz!`)}
            {' '}
            <BirthdayCakes />
          </p>
          <DismissBannerButton bannerName="birthday_message" />
        </div>
      ) : null}

      <AnniversaryBanner />

      {showNewEditNotesBanner ? (
        <div className="banner new-edit-notes">
          <p>
            {exp.l(
              `{link|New notes} have been left on some of your edits.
               Please make sure to read them and respond if necessary.`,
              {link: '/edit/notes-received'},
            )}
          </p>
          <DismissBannerButton bannerName="new_edit_notes" />
        </div>
      ) : null}

      {$c.stash.makes_no_changes /*:: === true */ ? (
        <div className="banner warning-header">
          <p>
            {l(
              `The data you have submitted does not make any changes
               to the data already present.`,
            )}
          </p>
        </div>
      ) : null}

      {$c.stash.overlong_string /*:: === true */ ? (
        <div className="banner warning-header">
          <p>
            {l(
              `Some text you entered is overlong! Please shorten it,
               and if necessary enter the full text in the annotation
               for reference.`,
            )}
          </p>
        </div>
      ) : null}

      {nonEmpty($c.sessionid) && nonEmpty($c.flash.message) ? (
        <div className="banner flash">
          <p dangerouslySetInnerHTML={{__html: $c.flash.message}} />
        </div>
      ) : null}
    </>
  );
}

component MergeHelperAndFooter(
  $c: CatalystContextT,
) {
  return (
    <>
      {$c.session?.merger && !$c.stash.hide_merge_helper /*:: === true */
        ? <MergeHelper merger={$c.session.merger} />
        : null}
      <Footer />
    </>
  );
}

component Layout(
  children: React.Node,
  fullWidth: boolean = false,
  ...headProps: React.PropsOf<Head>
) {
  const $c = React.useContext(CatalystContext);

  return (
    <html lang={$c.stash.current_language_html}>
      <Head {...headProps} />

      <body>
        {$c.stash.within_dialog === true
          ? null
          : <HeaderAndBanners $c={$c} />}

        <div
          className={(fullWidth ? 'fullwidth ' : '') +
            (headProps.isHomepage /*:: === true */ ? 'homepage' : '')}
          id="page"
        >
          {children}
        </div>

        {$c.stash.within_dialog === true
          ? null
          : <MergeHelperAndFooter $c={$c} />}
      </body>
    </html>
  );
}

export default Layout;
