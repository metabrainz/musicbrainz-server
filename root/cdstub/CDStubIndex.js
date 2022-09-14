/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import calculateFullToc
  from '../static/scripts/common/utility/calculateFullToc.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';

import CDStubInfo from './CDStubInfo.js';
import CDStubLayout from './CDStubLayout.js';

type Props = {
  +cdstub: CDStubT,
  +showArtists: boolean,
};

const CDStubIndex = ({
  cdstub,
  showArtists,
}: Props): React.Element<typeof CDStubLayout> => {
  const totalLength = cdstub.tracks.reduce(
    (length, track) => length + track.length,
    0,
  );

  return (
    <CDStubLayout entity={cdstub} page="index">
      {nonEmpty(cdstub.comment) ? (
        <>
          <h2>{l('Comment')}</h2>
          <p>{cdstub.comment}</p>
        </>
      ) : null}

      <h2>{l('Tracklist')}</h2>
      <CDStubInfo cdstub={cdstub} showArtists={showArtists} />

      <h2>{l('Disc ID information')}</h2>
      <table className="details">
        <tr>
          <th>{exp.l('{doc|Disc ID}:', {doc: '/doc/Disc_ID'})}</th>
          <td><code>{cdstub.discid}</code></td>
        </tr>
        <tr>
          <th>{l('Total tracks:')}</th>
          <td>{cdstub.track_count}</td>
        </tr>
        <tr>
          <th>{l('Total length:')}</th>
          <td>{formatTrackLength(totalLength)}</td>
        </tr>
        <tr>
          <th>{l('Full TOC:')}</th>
          <td>{calculateFullToc(cdstub)}</td>
        </tr>
      </table>
    </CDStubLayout>
  );
};

export default CDStubIndex;
