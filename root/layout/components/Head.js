/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import manifest from '../../static/manifest.mjs';
import {
  CANONICAL_SERVER,
  WEB_SERVER,
} from '../../static/scripts/common/DBDefs.mjs';
import commonLessUrl from '../../static/styles/common.less';
import iconLessUrl from '../../static/styles/icons.less';
import noScriptLessUrl from '../../static/styles/noscript.less';
import escapeClosingTags from '../../utility/escapeClosingTags.js';

import FaviconLinks from './FaviconLinks.js';
import globalsScript from './globalsScript.mjs';
import MetaDescription from './MetaDescription.js';

const canonRegexp = new RegExp('^(https?:)?//' + WEB_SERVER);
function canonicalize(url: string) {
  return CANONICAL_SERVER
    ? url.replace(canonRegexp, CANONICAL_SERVER)
    : url;
}

function getTitle(title?: string, isHomepage: boolean, pager?: PagerT) {
  let finalTitle = title;

  if (!isHomepage) {
    const parts = [];

    if (nonEmpty(title)) {
      parts.push(title);
    }

    if (pager?.current_page && pager.current_page > 1) {
      parts.push(texp.l('Page {n}', {n: pager.current_page}));
    }

    parts.push('MusicBrainz');
    finalTitle = parts.join(' - ');
  }

  return finalTitle;
}

const CanonicalLink = ({requestUri}: {+requestUri: string}) => {
  const canonUri = canonicalize(requestUri);
  if (requestUri !== canonUri) {
    return <link href={canonUri} rel="canonical" />;
  }
  return null;
};

component Head(
  isHomepage: boolean = false,
  noIcons: boolean = false,
  pager?: PagerT,
  title?: string,
) {
  const $c = React.useContext(CatalystContext);

  return (
    <head>
      <meta charSet="utf-8" />
      <meta content="IE=edge" httpEquiv="X-UA-Compatible" />
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, viewport-fit=cover" />
      <FaviconLinks />

      <MetaDescription entity={$c.stash.entity} />

      <title>{getTitle(title, isHomepage, pager)}</title>

      <CanonicalLink requestUri={$c.req.uri} />

      <link
        href={commonLessUrl}
        rel="stylesheet"
        type="text/css"
      />

      {noIcons ? null : (
        <link
          href={iconLessUrl}
          rel="stylesheet"
          type="text/css"
        />
      )}

      {isHomepage && (
        <link
          href="/static/build/bootstrap.css"
          rel="stylesheet"
          type="text/css"
        />
      )}

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

      <link rel="preconnect" href="https://fonts.googleapis.com" />
      <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100..900;1,100..900&family=Sintony:wght@400;700&display=swap" rel="stylesheet" />

      <noscript>
        <link
          href={noScriptLessUrl}
          rel="stylesheet"
          type="text/css"
        />
      </noscript>

      {globalsScript}

      {manifest('public-path')}

      {manifest('runtime')}

      {manifest('whatwg-fetch')}

      {manifest('vendors')}

      {manifest('common-chunks')}

      {manifest('common/jquery-global')}

      {manifest('common/bootstrap')}

      {manifest('common/sentry')}

      {$c.stash.current_language === 'en'
        ? null
        : manifest('jed-' + $c.stash.current_language)}

      {MUSICBRAINZ_RUNNING_TESTS ? manifest('selenium') : null}

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
}

export default Head;
