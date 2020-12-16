/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {
  +entity: InstrumentT,
};

function isIrombookImage(url: UrlT): boolean {
  return /https:\/\/staticbrainz\.org\/irombook\//.test(url.href_url);
}

const IrombookImage = ({entity}: Props): React.Element<'div'> | null => {
  const relationships = entity.relationships;

  if (!relationships) {
    return null;
  }

  let imageLink;

  for (const r of relationships) {
    const target = r.target;
    if (target.entityType === 'url' &&
        // is image relationship
        r.linkTypeID === 732 &&
        isIrombookImage(target)) {
      imageLink = target.href_url;
    }
  }

  return nonEmpty(imageLink) ? (
    <div className="picture">
      <img src={imageLink} />
      <br />
      <span className="picture-note">
        {l('IROMBOOK image/IROMBOOKのイラスト')}
      </span>
    </div>
  ) : null;
};

export default IrombookImage;
