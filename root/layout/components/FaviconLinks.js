/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const FaviconLinks = (): React.Element<typeof React.Fragment> => (
  <>
    <link
      href="/static/images/favicons/apple-touch-icon-57x57.png"
      rel="apple-touch-icon"
      sizes="57x57"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-60x60.png"
      rel="apple-touch-icon"
      sizes="60x60"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-72x72.png"
      rel="apple-touch-icon"
      sizes="72x72"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-76x76.png"
      rel="apple-touch-icon"
      sizes="76x76"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-114x114.png"
      rel="apple-touch-icon"
      sizes="114x114"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-120x120.png"
      rel="apple-touch-icon"
      sizes="120x120"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-144x144.png"
      rel="apple-touch-icon"
      sizes="144x144"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-152x152.png"
      rel="apple-touch-icon"
      sizes="152x152"
    />
    <link
      href="/static/images/favicons/apple-touch-icon-180x180.png"
      rel="apple-touch-icon"
      sizes="180x180"
    />
    <link
      href="/static/images/favicons/favicon-32x32.png"
      rel="icon"
      sizes="32x32"
      type="image/png"
    />
    <link
      href="/static/images/favicons/favicon-16x16.png"
      rel="icon"
      sizes="16x16"
      type="image/png"
    />
    <link href="/static/images/favicons/site.webmanifest" rel="manifest" />
    <link
      color="#bb4890"
      href="/static/images/favicons/safari-pinned-tab.svg"
      rel="mask-icon"
    />
    <link href="/favicon.ico" rel="shortcut icon" />
    <meta content="#f1f1f1" name="msapplication-TileColor" />
    <meta
      content="/static/images/favicons/mstile-144x144.png"
      name="msapplication-TileImage"
    />
    <meta content="#ffffff" name="theme-color" />
  </>
);

export default FaviconLinks;
