/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import taggerIconUrl from '../../../images/icons/mblookup-tagger.png';

function buildTaggerLink(
  entityType: 'recording' | 'release',
  gid: string,
  tport: number,
): string {
  let path = '';
  if (entityType === 'release') {
    path = 'openalbum';
  } else if (entityType === 'recording') {
    path = 'opennat';
  }
  return `http://127.0.0.1:${tport}/${path}?id=${gid}`;
}

type Props = {
  +entityType: 'recording' | 'release',
  +gid: string,
};

const TaggerIcon = ({
  entityType,
  gid,
}: Props): React$MixedElement | null => {
  const $c = React.useContext(SanitizedCatalystContext);

  const tport = $c.session?.tport;
  if (tport == null) {
    return null;
  }

  const handleClick = (event: SyntheticMouseEvent<HTMLAnchorElement>) => {
    event.preventDefault();

    const target = event.currentTarget;

    /*
     * MBS-6785: Use the tagger iframe if window.opera exists
     *
     * Opera doesn't seem to allow loading localhost as an image with its
     * security policy, so the fix for mixed-content introduced in
     * commit 2fef85c causes the tagger button to have no effect on Opera.
     *
     * Conditionally branch on the 'window.opera' object, which (should)
     * only be set if the browser is Opera. If the browser is Opera, we use
     * an approach similar to the old iframe approach, though we do so
     * dynamically. If window.opera does not exist, we continue to use the
     * new Image technique.
     */
    if (window.opera) {
      const iframe = document.createElement('iframe');
      iframe.src = target.href;
      iframe.style.display = 'none';
      document.body?.appendChild(iframe);
    } else {
      const tagger = new Image();
      tagger.src = target.href;
    }
  };

  return (
    <a
      className="tagger-icon"
      href={buildTaggerLink(entityType, gid, tport)}
      onClick={handleClick}
      title={l('Open in tagger')}
    >
      <img
        alt={l('Tagger')}
        src={taggerIconUrl}
      />
    </a>
  );
};

export default (
  hydrate<Props>(
    'span.tagger-icon',
    TaggerIcon,
  ): React.AbstractComponent<Props, void>
);
