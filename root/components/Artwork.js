/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';
import {l_attributes} from '../static/scripts/common/i18n/attributes';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList';
import bracketed from '../static/scripts/common/utility/bracketed';

const lType = (x, index) => l_attributes(x);

function artworkHover(artwork: ArtworkT) {
  let result = '';
  if (artwork.types.length) {
    result = commaOnlyList(artwork.types.map(lType));
  }
  if (artwork.comment) {
    result += ' ' + bracketed(artwork.comment);
  }
  return result;
}

type Props = {|
  +artwork: ArtworkT,
  +fallback?: string,
  +message?: string,
|};

export const ArtworkImage = ({artwork, fallback, message}: Props) => (
  <>
    <noscript>
      <img src={artwork.small_thumbnail} />
    </noscript>
    <span
      className="cover-art-image"
      data-fallback={fallback || ''}
      data-large-thumbnail={artwork.large_thumbnail}
      data-message={message ? message : l('Image not available yet, please try again in a few minutes.')}
      data-small-thumbnail={artwork.small_thumbnail}
      data-title={artworkHover(artwork)}
    />
  </>
);

export const Artwork = ({artwork, fallback, message}: Props) => (
  <a
    className={artwork.mime_type === 'application/pdf' ? 'artwork-pdf' : 'artwork-image'}
    href={artwork.image}
    title={artworkHover(artwork)}
  >
    {artwork.mime_type === 'application/pdf' ? (
      <div
        className="file-format-tag"
        title={l('This is a PDF file, the thumbnail may not show the entire contents of the file.')}
      >
        {l('PDF file')}
      </div>
    ) : null}
    <ArtworkImage
      artwork={artwork}
      fallback={fallback}
      message={message}
    />
  </a>
);
