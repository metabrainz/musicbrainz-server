/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

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

export component ArtworkImage(
  artwork: ArtworkT,
  hover?: string,
  message?: string,
) {
  return (
    <>
      <noscript>
        <img src={artwork.small_ia_thumbnail} />
      </noscript>
      <span
        className="artwork-image"
        data-huge-thumbnail={artwork.huge_ia_thumbnail}
        data-large-thumbnail={artwork.large_ia_thumbnail}
        data-message={nonEmpty(message)
          ? message
          : l('Image not available, please try again later.')}
        data-small-thumbnail={artwork.small_ia_thumbnail}
        data-title={nonEmpty(hover) ? hover : artworkHover(artwork)}
      />
    </>
  );
}

export component Artwork(...props: React.PropsOf<ArtworkImage>) {
  const artwork = props.artwork;

  return (
    <a
      className={artwork.mime_type === 'application/pdf'
        ? 'artwork-pdf'
        : 'artwork-image'}
      href={artwork.image}
      title={nonEmpty(props.hover) ? props.hover : artworkHover(artwork)}
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
      <ArtworkImage {...props} />
    </a>
  );
}
