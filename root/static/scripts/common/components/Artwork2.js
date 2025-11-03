/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {commaOnlyListText} from '../i18n/commaOnlyList.js';
import {bracketedText} from '../utility/bracketed.js';

const lType = (x: string) => lp_attributes(x, 'cover_art_type');

function artworkHover(artwork: ArtworkT) {
  let result = '';
  if (artwork.types.length) {
    result = commaOnlyListText(artwork.types.map(lType));
  }
  if (artwork.comment) {
    result += ' ' + bracketedText(artwork.comment);
  }
  return result;
}

/*
 * This is an alternate Artwork that plays well with hydrated
 * components, by using HTML lazy loading and srcSet to pick the
 * right images at the right time rather than loading them with
 * jQuery potentially before the hydration has time to apply.
 */
component Artwork(
  artwork: ArtworkT,
  hover?: string,
  message?: string,
) {
  const [hasErrors, setHasErrors] = React.useState<boolean>(false);

  const title = nonEmpty(hover) ? hover : artworkHover(artwork);
  const failureMessage = nonEmpty(message)
    ? message
    : l('Image not available, please try again later.');

  return hasErrors ? (
    <em className="cover-art-error">
      {failureMessage}
    </em>
  ) : (
    <a
      className={artwork.mime_type === 'application/pdf'
        ? 'artwork-pdf'
        : 'artwork-image'}
      href={artwork.image}
      title={title}
    >
      {artwork.mime_type === 'application/pdf' ? (
        <div
          className="file-format-tag"
          title={l(
            `This is a PDF file, the thumbnail may not show
             the entire contents of the file.`,
          )}
        >
          {l('PDF file')}
        </div>
      ) : null}
      <img
        loading="lazy"
        onError={() => setHasErrors(true)}
        src={artwork.small_ia_thumbnail}
        srcSet={
          artwork.small_ia_thumbnail + ' 1x, ' +
          artwork.large_ia_thumbnail + ' 1.5x'
        }
        title={title}
      />
    </a>
  );
}

export default Artwork;
