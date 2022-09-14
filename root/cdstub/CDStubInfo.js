/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import loopParity from '../utility/loopParity.js';

type Props = {
  +cdstub: CDStubT,
  +showArtists?: boolean,
};

const CDStubInfo = ({
  cdstub,
  showArtists = false,
}: Props): React.Element<'table'> => (
  <table className="tbl">
    <thead>
      <tr>
        <th className="pos t">{l('#')}</th>
        <th>{l('Title')}</th>
        {showArtists ? <th>{l('Artist')}</th> : null}
        <th className="treleases">{l('Length')}</th>
      </tr>
    </thead>
    <tbody>
      {cdstub.tracks.map((track, index) => (
        <tr className={loopParity(index)} key={index}>
          <td>{track.sequence}</td>
          <td>{track.title}</td>
          {showArtists ? <td>{track.artist}</td> : null}
          <td>{formatTrackLength(track.length)}</td>
        </tr>
      ))}
    </tbody>
  </table>
);

export default CDStubInfo;
