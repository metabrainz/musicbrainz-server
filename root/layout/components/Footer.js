/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../context';
import DBDefs from '../../static/scripts/common/DBDefs';
import {DONATE_URL} from '../../constants';
import {l} from '../../static/scripts/common/i18n';
import formatUserDate from '../../utility/formatUserDate';

const Footer = ({$c, ...props}) => {
  const stash = $c.stash;
  return (
    <div id="footer">
      <p className="left">
        <a className="internal" href={DONATE_URL}>{l('Donate')}</a>
        {' | '}
        <a className="internal" href="//wiki.musicbrainz.org/">{l('Wiki')}</a>
        {' | '}
        <a className="internal" href="https://community.metabrainz.org/">{l('Forums')}</a>
        {' | '}
        <a className="internal" href="http://tickets.musicbrainz.org/">{l('Bug Tracker')}</a>
        {' | '}
        <a className="internal" href="https://blog.musicbrainz.org/">{l('Blog')}</a>
        {' | '}
        <a className="internal" href="https://twitter.com/MusicBrainz">{l('Twitter')}</a>

        {DBDefs.BETA_REDIRECT_HOSTNAME ? (
          <>
            {' | '}
            <a className="internal" href="/set-beta-preference">
              {DBDefs.IS_BETA ? l('Stop using beta site') : l('Use beta site')}
            </a>
          </>
        ) : null}

        {DBDefs.GIT_BRANCH ? (
          <>
            <br />
            {l('Running: {git_details}', {
              __react: true,
              git_details: (
                <span className="tooltip" key="git_details" title={DBDefs.GIT_MSG}>
                  {DBDefs.GIT_BRANCH} {' ('} {DBDefs.GIT_SHA} {' )'}
                </span>
              ),
            })}
          </>
        ) : null}

        {stash.last_replication_date ? (
          <>
            <br />
            {l('Last replication packet received at {datetime}', {
              datetime: $c.user
                ? formatUserDate($c.user, stash.last_replication_date)
                : stash.last_replication_date,
            })}
          </>
        ) : null}
      </p>

      <p className="right">
        {l('Brought to you by {MeB|MetaBrainz Foundation} and our {spon|sponsors} and {supp|supporters}. Cover Art provided by the {caa|Cover Art Archive}.',
          {
            __react: true,
            MeB: 'https://metabrainz.org/',
            caa: '//coverartarchive.org/',
            spon: 'https://metabrainz.org/sponsors',
            supp: 'https://metabrainz.org/supporters',
          })}
      </p>
    </div>
  );
};

export default withCatalystContext(Footer);
