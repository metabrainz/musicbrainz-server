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
import * as manifest from '../../static/manifest.mjs';
import DBDefs from '../../static/scripts/common/DBDefs.mjs';
import commonLessUrl from '../../static/styles/common.less';
import iconLessUrl from '../../static/styles/icons.less';
import noScriptLessUrl from '../../static/styles/noscript.less';
import escapeClosingTags from '../../utility/escapeClosingTags.js';

import FaviconLinks from './FaviconLinks.js';
import globalsScript from './globalsScript.mjs';
import MetaDescription from './MetaDescription.js';

export type HeadProps = {
  +isHomepage?: boolean,
  +noIcons?: boolean,
  +pager?: PagerT,
  +title?: string,
};

const canonRegexp = new RegExp('^(https?:)?//' + DBDefs.WEB_SERVER);
function canonicalize(url: string) {
  return DBDefs.CANONICAL_SERVER
    ? url.replace(canonRegexp, DBDefs.CANONICAL_SERVER)
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

const Head = ({
  isHomepage = false,
  noIcons = false,
  pager,
  title,
}: HeadProps): React$Element<'head'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <head>
      <meta charSet="utf-8" />
      <meta content="IE=edge" httpEquiv="X-UA-Compatible" />
      <meta content="width=device-width, initial-scale=1" name="viewport" />
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
        <link
          href={noScriptLessUrl}
          rel="stylesheet"
          type="text/css"
        />
      </noscript>

      {globalsScript}

      {manifest.js('runtime')}

      {manifest.js('common-chunks')}

      {manifest.js('jed-data')}

      {$c.stash.current_language === 'en'
        ? null
        : manifest.js('jed-' + $c.stash.current_language)}

      {manifest.js('common', {
        'data-args': JSON.stringify({
          user: $c.user ? {id: $c.user.id, name: $c.user.name} : null,
        }),
      })}

      {MUSICBRAINZ_RUNNING_TESTS ? manifest.js('selenium') : null}

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
};

export default Head;
