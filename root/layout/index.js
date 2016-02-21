// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const Footer = require('./components/Footer');
const Header = require('./components/Header');
const MergeHelper = require('./components/MergeHelper');
const manifest = require('../static/manifest');
const {l} = require('../static/scripts/common/i18n');
const getCookie = require('../static/scripts/common/utility/getCookie');

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

const DismissBannerButton = ({bannerName}) => (
  <button className="dismiss-banner remove-item icon"
          data-banner-name={bannerName}
          type="button">
  </button>
);

const serverDetailsBanner = (server) => {
  if (server.staging_server) {
    return (
      <div className="banner server-details">
        <p>
          {server.staging_server_description || l('This is a MusicBrainz development server.')}
          {' '}
          {l('{uri|Return to musicbrainz.org}.',
             {__react: true,
              uri: '//musicbrainz.org' + (server.beta_redirect === 'musicbrainz.org' ? '?unset_beta=1' : '' )})}
        </p>
        <DismissBannerButton bannerName="server_details" />
      </div>
    );
  }

  if (server.is_slave_db) {
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
};

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

        {!getCookie('server_details_dismissed_mtime') && serverDetailsBanner(server)}

        {!!(server.alert && server.alert_mtime > getCookie('alert_dismissed_mtime', 0)) &&
          <div className="banner warning-header">
            <p dangerouslySetInnerHTML={{__html: server.alert}}></p>
            <DismissBannerButton bannerName="alert" />
          </div>}

        {!!server.read_only &&
          <div className="banner server-details">
            <p>
              {l('The server is temporarily in read-only mode for database maintenance.')}
            </p>
          </div>}

        {!!($c.stash.new_edit_notes &&
            $c.stash.new_edit_notes_mtime > getCookie('new_edit_notes_dismissed_mtime', 0) &&
            ($c.user.is_limited || getCookie('alert_new_edit_notes', 'true') !== 'false')) &&
          <div className="banner new-edit-notes">
            <p>
              {l('{link|New notes} have been left on some of your edits. Please make sure to read them and respond if necessary.',
                 {__react: true, link: '/edit/notes-received'})}
            </p>
            <DismissBannerButton bannerName="new_edit_notes" />
          </div>}

        {!!$c.stash.makes_no_changes &&
          <div className="banner warning-header">
            <p>{l('The data you have submitted does not make any changes to the data already present.')}</p>
          </div>}

        {!!($c.sessionid && $c.flash.message) &&
          <div className="banner flash">
            <p dangerouslySetInnerHTML={{__html: $c.flash.message}}></p>
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

module.exports = Layout;
