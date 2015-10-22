// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import {l} from '../../static/scripts/common/i18n';
import formatUserDate from '../../utility/formatUserDate';

const Footer = (props) => {
  let stash = $c.stash;
  let server_details = stash.server_details;

  return (
    <div id="footer">
      <p className="left">
        <a href="http://metabrainz.org/donate" className="internal">{l('Donate')}</a>
        {' | '}
        <a href="//wiki.musicbrainz.org/" className="internal">{l('Wiki')}</a>
        {' | '}
        <a href="http://forums.musicbrainz.org/" className="internal">{l('Forums')}</a>
        {' | '}
        <a href="http://tickets.musicbrainz.org/" className="internal">{l('Bug Tracker')}</a>
        {' | '}
        <a href="https://twitter.com/MusicBrainz" className="internal">{l('Twitter')}</a>

        {!!server_details.beta_redirect && [
          ' | ',
          <a href={$c.uri_for('/set-beta-preference')} className="internal">
            {server_details.is_beta ? l('Stop using beta site') : l('Use beta site')}
          </a>
        ]}

        {!!server_details.git.branch && [
          <br />,
          l('Running: {git_details}',
            {__react: true,
             git_details: <span className="tooltip" title={server_details.git.msg}>
                            {server_details.git.branch} ({server_details.git.sha})
                          </span>
            })
        ]}

        {!!stash.last_replication_date && [
          <br />,
          l('Last replication packet received at {datetime}',
            {datetime: formatUserDate($c.user, stash.last_replication_date)})
        ]}
      </p>

      <p className="right">
        {l('Cover Art provided by the {caa|Cover Art Archive}. Hosted by {host|Digital West}. Sponsored by: {url1|Google}, {url2|OSUOSL} and {more|others...}.',
           {__react: true,
            host: 'https://www.digitalwest.com/',
            url1: 'https://www.google.com/',
            url2: '//osuosl.org/',
            more: 'http://metabrainz.org/doc/Sponsors',
            caa: '//coverartarchive.org/'})}
      </p>
    </div>
  );
};

export default Footer;
