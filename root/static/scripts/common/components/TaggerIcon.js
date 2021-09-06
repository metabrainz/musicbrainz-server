/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../../context';
import taggerIconUrl from '../../../images/icons/mblookup-tagger.png';

function buildTaggerLink(entity, tport: number): string {
  const gid = entity.gid;
  const t = Math.floor(Date.now() / 1000);
  let path = '';
  if (entity.entityType === 'release') {
    path = 'openalbum';
  } else if (entity.entityType === 'recording') {
    path = 'opennat';
  }
  return `http://127.0.0.1:${tport}/${path}?id=${gid}&t=${t}`;
}

type Props = {
  +entity: RecordingT | ReleaseT,
};

const TaggerIcon = ({entity}: Props): React.MixedElement => (
  <CatalystContext.Consumer>
    {$c => $c.session?.tport == null ? null : (
      <a
        className="tagger-icon"
        href={buildTaggerLink(entity, $c.session.tport)}
        title={l('Open in tagger')}
      >
        <img
          alt={l('Tagger')}
          src={taggerIconUrl}
        />
      </a>
    )}
  </CatalystContext.Consumer>
);

export default TaggerIcon;
