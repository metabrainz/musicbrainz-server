/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import loopParity from '../utility/loopParity.js';

component CDStubInfo(cdstub: CDStubT, showArtists: boolean = false) {
  return (
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
}

export default CDStubInfo;
