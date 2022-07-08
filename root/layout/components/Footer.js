/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import DBDefs from '../../static/scripts/common/DBDefs';
import {DONATE_URL} from '../../constants';
import {bracketedText} from '../../static/scripts/common/utility/bracketed';
import formatUserDate from '../../utility/formatUserDate';
import {returnToCurrentPage} from '../../utility/returnUri';

const Footer = (): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const stash = $c.stash;
  return (
    <div id="footer">
      <p className="left" id="footer-menu">
        <a className="internal" href={DONATE_URL}>{l('Donate')}</a>
        <a className="internal" href="//wiki.musicbrainz.org/">{l('Wiki')}</a>
        <a className="internal" href="https://community.metabrainz.org/">{l('Forums')}</a>
        <a className="internal" href="/doc/Communication/IRC">
          {l('Chat (IRC)')}
        </a>
        <a className="internal" href="http://tickets.metabrainz.org/">{l('Bug Tracker')}</a>
        <a className="internal" href="https://blog.metabrainz.org/">{l('Blog')}</a>
        <a className="internal" href="https://twitter.com/MusicBrainz">{l('Twitter')}</a>

        {DBDefs.BETA_REDIRECT_HOSTNAME ? (
          <a
            className="internal"
            href={
              '/set-beta-preference?' + returnToCurrentPage($c)
            }
          >
            {DBDefs.IS_BETA
              ? l('Stop using beta site')
              : l('Use beta site')}
          </a>
        ) : null}
      </p>

      <p className="right">
        {exp.l(
          `Brought to you by {MeB|MetaBrainz Foundation} and our
           {spon|sponsors} and {supp|supporters}. Cover Art provided
           by the {caa|Cover Art Archive}.`,
          {
            caa: '//coverartarchive.org/',
            MeB: 'https://metabrainz.org/',
            spon: 'https://metabrainz.org/sponsors',
            supp: 'https://metabrainz.org/supporters',
          },
        )}

        {DBDefs.DB_STAGING_SERVER && DBDefs.GIT_BRANCH ? (
          <>
            <br />
            {exp.l('Running: {git_details}', {
              git_details: (
                <span
                  className="tooltip"
                  key="git_details"
                  title={DBDefs.GIT_MSG}
                >
                  {DBDefs.GIT_BRANCH}
                  {' '}
                  {bracketedText(DBDefs.GIT_SHA)}
                </span>
              ),
            })}
          </>
        ) : null}

        {nonEmpty(stash.last_replication_date) ? (
          <>
            <br />
            {texp.l('Last replication packet received at {datetime}', {
              datetime: $c.user
                ? formatUserDate($c, stash.last_replication_date)
                : stash.last_replication_date,
            })}
          </>
        ) : null}
      </p>
    </div>
  );
};

export default Footer;
