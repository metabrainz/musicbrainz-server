// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const Frag = require('../../components/Frag');
const {withCatalystContext} = require('../../context');
const DBDefs = require('../../static/scripts/common/DBDefs');
const {l} = require('../../static/scripts/common/i18n');
const formatUserDate = require('../../utility/formatUserDate');

const Footer = ({$c, ...props}) => {
  const stash = $c.stash;
  return (
    <div id="footer">
      <p className="left">
        <a href="http://metabrainz.org/donate" className="internal">{l('Donate')}</a>
        {' | '}
        <a href="//wiki.musicbrainz.org/" className="internal">{l('Wiki')}</a>
        {' | '}
        <a href="https://community.metabrainz.org/" className="internal">{l('Forums')}</a>
        {' | '}
        <a href="http://tickets.musicbrainz.org/" className="internal">{l('Bug Tracker')}</a>
        {' | '}
        <a href="https://blog.musicbrainz.org/" className="internal">{l('Blog')}</a>
        {' | '}
        <a href="https://twitter.com/MusicBrainz" className="internal">{l('Twitter')}</a>

        {!!DBDefs.BETA_REDIRECT_HOSTNAME && [
          ' | ',
          <a href="/set-beta-preference" className="internal">
            {DBDefs.IS_BETA ? l('Stop using beta site') : l('Use beta site')}
          </a>
        ]}

        {!!DBDefs.GIT_BRANCH && [
          <br />,
          l('Running: {git_details}',
            {__react: true,
             git_details: <span className="tooltip" title={DBDefs.GIT_MSG}>
                            {DBDefs.GIT_BRANCH} ({DBDefs.GIT_SHA})
                          </span>
            })
        ]}

        {stash.last_replication_date ? (
          <Frag>
            <br />
            {l('Last replication packet received at {datetime}', {
                datetime: $c.user ?
                  formatUserDate($c.user, stash.last_replication_date) :
                  stash.last_replication_date
            })}
          </Frag>
        ) : null}
      </p>

      <p className="right">
        {l('Brought to you by {MeB|MetaBrainz Foundation} and our {spon|sponsors} and {supp|supporters}. Cover Art provided by the {caa|Cover Art Archive}.',
           {__react: true,
            MeB: 'https://metabrainz.org/',
            spon: 'https://metabrainz.org/sponsors',
            supp: 'https://metabrainz.org/supporters',
            caa: '//coverartarchive.org/'})}
      </p>
    </div>
  );
};

export default withCatalystContext(Footer);
