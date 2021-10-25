/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import 'bootstrap/dist/css/bootstrap.css';
import "bootstrap-icons/font/bootstrap-icons.css" ;
import "react-multi-carousel/lib/styles.css";
import {CatalystContext} from '../../context';
import * as manifest from '../../static/manifest';
import DBDefs from '../../static/scripts/common/DBDefs';
import commonLessUrl from '../../static/styles/common.less';
import bootstrapUrl from 'bootstrap/dist/css/bootstrap.css';
import bootstrapIconsUrl from 'bootstrap-icons/font/bootstrap-icons.css';
import multiCarousel from 'react-multi-carousel/lib/styles.css';
import iconLessUrl from '../../static/styles/icons.less';
import noScriptLessUrl from '../../static/styles/noscript.less';
import escapeClosingTags from '../../utility/escapeClosingTags';

import globalsScript from './globalsScript';
import FaviconLinks from './FaviconLinks';
import MetaDescription from './MetaDescription';

export type HeadProps = {
  +homepage?: boolean,
  +noIcons?: boolean,
  +pager?: PagerT,
  +title?: string,
};

const canonRegexp = new RegExp('^(https?:)?//' + DBDefs.WEB_SERVER);
function canonicalize(url) {
  return DBDefs.CANONICAL_SERVER
    ? url.replace(canonRegexp, DBDefs.CANONICAL_SERVER)
    : url;
}

function getTitle(props) {
  const pager = props.pager;
  let title = props.title;

  if (!props.homepage) {
    const parts = [];

    if (title) {
      parts.push(title);
    }

    if (pager?.current_page && pager.current_page > 1) {
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

const Head = ({...props}: HeadProps): React.Element<'head'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <head>
      <meta charSet="utf-8" />
      <meta content="IE=edge" httpEquiv="X-UA-Compatible" />
      <meta content="width=device-width, initial-scale=1" name="viewport" />
      <FaviconLinks />

      <MetaDescription entity={$c.stash.entity} />

      <title>{getTitle(props)}</title>

      <CanonicalLink requestUri={$c.req.uri} />
      <link
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3"
          crossorigin="anonymous"
      />
      <link
        href={commonLessUrl}
        rel="stylesheet"
        type="text/css"
      />
      <link
        href={bootstrapUrl}
        rel="stylesheet"
      />
      <link
        href={bootstrapIconsUrl}
        rel="stylesheet"
        type="text/css"
      />
      <link
        href={multiCarousel}
        rel="stylesheet"
        type="text/css"
      />

      {props.noIcons ? null : (
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
