/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';
import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

type CommonsImageRequestCallbackT = (CommonsImageT | null) => void;

function loadCommonsImage(
  entity: NonUrlRelatableEntityT,
  callback: CommonsImageRequestCallbackT,
): void {
  const url = entityHref(entity, '/commons-image');

  fetch(url)
    .then(resp => resp.json())
    .then((reqData) => {
      try {
        callback(reqData.image);
      } catch (error) {
        console.error(error);
        Sentry.captureException(error);
      }
    })
    .catch(console.error);
}

component CommonsImage(
  cachedImage: ?CommonsImageT,
  entity: NonUrlRelatableEntityT,
) {
  const [commonsImage, setCommonsImage] = React.useState(cachedImage);

  React.useEffect(() => {
    if (cachedImage == null) {
      loadCommonsImage(entity, setCommonsImage);
    }
  }, [entity, cachedImage]);

  return commonsImage ? (
    <div className="picture">
      <img src={commonsImage.thumb_url} />
      <br />
      <span className="picture-note">
        <a href={commonsImage.page_url}>
          {l('Image from Wikimedia Commons')}
        </a>
      </span>
    </div>
  ) : null;
}

export default (hydrate<React.PropsOf<CommonsImage>>(
  'div.commons-image',
  CommonsImage,
  minimalEntity,
): component(...React.PropsOf<CommonsImage>));
