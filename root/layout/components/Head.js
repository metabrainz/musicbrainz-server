/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import * as manifest from '../../static/manifest';
import * as DBDefs from '../../static/scripts/common/DBDefs';
import escapeClosingTags from '../../utility/escapeClosingTags';

import MetaDescription from './MetaDescription';

const canonRegexp = new RegExp('^(https?:)?//' + DBDefs.WEB_SERVER);
function canonicalize(url) {
  return DBDefs.CANONICAL_SERVER
    ? url.replace(canonRegexp, DBDefs.CANONICAL_SERVER)
    : url;
}

function getTitle(props) {
  let {title, pager} = props;

  if (!props.homepage) {
    const parts = [];

    if (title) {
      parts.push(title);
    }

    if (pager && pager.current_page && pager.current_page > 1) {
      parts.push(texp.l('Page {n}', {n: pager.current_page}));
    }

    parts.push('MusicBrainz');
    title = parts.join(' - ');
  }

  return title;
}

const CanonicalLink = ({requestUri}) => {
  const canonUri = canonicalize(requestUri);
  if (requestUri !== canonUri) {
    return <link href={canonUri} rel="canonical" />;
  }
  return null;
};

const Head = ({$c, ...props}) => (
  <head>
    <meta charSet="utf-8" />
    <meta content="IE=edge" httpEquiv="X-UA-Compatible" />
    <meta content="width=device-width, initial-scale=1" name="viewport" />
    <MetaDescription entity={$c.stash.entity} />

    <title>{getTitle(props)}</title>

    <CanonicalLink requestUri={$c.req.uri} />

    <link
      href={require('../../static/styles/common.less')}
      rel="stylesheet"
      type="text/css"
    />

    {props.no_icons
      ? null
      : <link
          href={require('../../static/styles/icons.less')}
          rel="stylesheet"
          type="text/css"
        />}

    <link
      href="/static/search_plugins/opensearch/musicbrainz_artist.xml"
      rel="search"
      title={l('MusicBrainz: Artist')}
      type="application/opensearchdescription+xml"
    />
    <link
      href="/static/search_plugins/opensearch/musicbrainz_label.xml"
      rel="search"
      title={l('MusicBrainz: Label')}
      type="application/opensearchdescription+xml"
    />
    <link
      href="/static/search_plugins/opensearch/musicbrainz_release.xml"
      rel="search"
      title={l('MusicBrainz: Release')}
      type="application/opensearchdescription+xml"
    />
    <link
      href="/static/search_plugins/opensearch/musicbrainz_track.xml"
      rel="search"
      title={l('MusicBrainz: Track')}
      type="application/opensearchdescription+xml"
    />

    <noscript>
      <style
        dangerouslySetInnerHTML={{
          __html: '.header > .right > .bottom > .menu' +
                  ' > li:focus > ul { left: auto; }',
        }}
        type="text/css"
      />
    </noscript>

    {manifest.js('runtime')}

    {manifest.js('common-chunks')}

    {manifest.js('jed-data')}

    {$c.stash.current_language !== 'en' ? (
      ['mb_server']
        .concat(props.gettext_domains || [])
        .map(function (domain) {
          const name = 'jed-' + $c.stash.current_language + '-' + domain;
          return manifest.js(name, {key: name});
        })
    ) : null}

    {manifest.js('common', {
      'data-args': JSON.stringify({
        user: $c.user ? {id: $c.user.id, name: $c.user.name} : null,
      }),
    })}

    {$c.stash.jsonld_data ? (
      <script
        dangerouslySetInnerHTML={
          {__html: escapeClosingTags(JSON.stringify($c.stash.jsonld_data))}
        }
        type="application/ld+json"
      />
    ) : null}
  </head>
);

export default withCatalystContext(Head);
