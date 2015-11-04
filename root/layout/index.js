// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import Footer from './components/Footer';
import Header from './components/Header';
import MergeHelper from './components/MergeHelper';
import * as manifest from '../static/manifest';
import {l} from '../static/scripts/common/i18n';

let canonRegexp = new RegExp('^(https?:)?//' + process.env.WEB_SERVER);
function canonicalize(url) {
  return process.env.CANONICAL_SERVER ? url.replace(canonRegexp, process.env.CANONICAL_SERVER) : url;
}

const metaTags = [
  <meta key={1} httpEquiv="Content-Type" content="text/html; charset=UTF-8" />,
  <meta key={2} charSet="utf-8" />,
  <meta key={3} httpEquiv="X-UA-Compatible" content="IE=edge" />,
  <meta key={4} name="viewport" content="width=device-width, initial-scale=1" />,
];

const openSearchTags = [
  <link key={1} rel="search" type="application/opensearchdescription+xml" title={l("MusicBrainz: Artist")} href="/static/search_plugins/opensearch/musicbrainz_artist.xml" />,
  <link key={2} rel="search" type="application/opensearchdescription+xml" title={l("MusicBrainz: Label")} href="/static/search_plugins/opensearch/musicbrainz_label.xml" />,
  <link key={3} rel="search" type="application/opensearchdescription+xml" title={l("MusicBrainz: Release")} href="/static/search_plugins/opensearch/musicbrainz_release.xml" />,
  <link key={4} rel="search" type="application/opensearchdescription+xml" title={l("MusicBrainz: Track")} href="/static/search_plugins/opensearch/musicbrainz_track.xml" />,
];

const Layout = (props) => {
  let {title, pager} = props;
  let canonURL = canonicalize(props.canonical_url || $c.req.url);
  let currentLanguage = $c.stash.current_language;
  let server = $c.stash.server_details;

  if (props.homepage) {
    let parts = [];

    if (title) {
      parts.push(title);
    }

    if (pager.current_page && pager.current_page > 1) {
      parts.push(l('Page {n}', {n: pager.current_page}));
    }

    parts.push('MusicBrainz');
    title = parts.join(' - ');
  }

  return (
    <html lang={$c.stash.current_language_html}>
      <head>
        {metaTags}

        <title>{title}</title>

        {canonURL !== $c.req.url && <link rel="canonical" href={canonURL} />}

        {manifest.css('common')}
        {!!props.noIcons || manifest.css('icons')}

        {openSearchTags}

        <noscript>
          <style type="text/css">
            {'#header-menu li:hover ul { left: auto; }'}
          </style>
        </noscript>

        {manifest.js('jed-' + currentLanguage)}
        {manifest.js('common')}
        {!!$c.stash.jsonld_data && <script type="application/ld+json">{$c.stash.jsonld_data}</script>}
        {!!process.env.GOOGLE_ANALYTICS_CODE &&
          <script type="text/javascript" dangerouslySetInnerHTML={{__html: `
            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', '${process.env.GOOGLE_ANALYTICS_CODE}']);
            _gaq.push(['_setCustomVar', 1, 'User is logged in', '${$c.user ? "Yes" : "No"}', 2]);
            _gaq.push(['_trackPageview']);

            (function () {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
          `}}></script>}
      </head>

      <body>
        <Header {...props} />

        {!!server.staging_server &&
          <div className="banner server-details">
            <p>
              {server.staging_server_description || l('This is a MusicBrainz development server.')}
              {' '}
              {l('{uri|Return to musicbrainz.org}.',
                 {__react: true,
                  uri: '//musicbrainz.org' + (server.beta_redirect === 'musicbrainz.org' ? '?unset_beta=1' : '' )})}
            </p>
          </div>}

        {!!server.is_slave_db &&
          <div className="banner server-details">
            <p>
              {l('This is a Musicbrainz mirror server. To edit or make changes to the data please ' +
                 '{uri|return to musicbrainz.org}.', {uri: '//musicbrainz.org'})}
            </p>
          </div>}

        {!!server.alert &&
          <div className="banner warning-header">
            <p>{server.alert}</p>
          </div>}

        {!!server.read_only &&
          <div className="banner server-details">
            <p>
              {l('The server is temporary in read-only mode for database maintainance.')}
            </p>
          </div>}

        {!!$c.stash.makes_no_changes &&
          <div className="banner warning-header">
            <p>{l('The data you have submitted does not make any changes to the data already present.')}</p>
          </div>}

        {!!($c.sessionid && $c.flash.message) &&
          <div className="banner flash">
            <p>{$c.flash.message}</p>
          </div>}

        <div id="page" className={(props.fullwidth ? 'fullwidth ' : '') + (props.homepage ? 'homepage' : '')}>
          {props.children}
          <div style={{clear: 'both'}}></div>
        </div>

        {($c.session.merger && !$c.stash.hide_merge_helper) && <MergeHelper />}

        <Footer {...props} />
      </body>
    </html>
  );
};

export default Layout;
