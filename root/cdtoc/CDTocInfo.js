/*
 * @flow strict
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

type Props = {
  +cdToc: CDTocT,
};

const CDTocInfo = ({cdToc}: Props): React$Element<typeof React.Fragment> => (
  <>
    <h2>{l('CD TOC details')}</h2>

    <table>
      <tr>
        <th>{l('Full TOC:')}</th>
        <td>{calculateFullToc(cdToc)}</td>
      </tr>

      <tr>
        <th>{l('Disc ID:')}</th>
        <td><code>{cdToc.discid}</code></td>
      </tr>
      <tr>
        <th>{l('FreeDB:')}</th>
        <td>{cdToc.freedb_id}</td>
      </tr>
      <tr>
        <th>{l('Total tracks:')}</th>
        <td>{cdToc.track_count}</td>
      </tr>
      <tr>
        <th>{l('Total length:')}</th>
        <td>{formatTrackLength(cdToc.length)}</td>
      </tr>
      <tr>
        <th>{l('Track details:')}</th>
        <td>
          <table>
            <tr>
              <th rowSpan="2">{l('Track')}</th>
              <th colSpan="2">{l('Start')}</th>
              <th colSpan="2">{l('Length')}</th>
              <th colSpan="2">{l('End')}</th>
            </tr>
            <tr>
              <th>{l('Time')}</th>
              <th>{l('Sectors')}</th>
              <th>{l('Time')}</th>
              <th>{l('Sectors')}</th>
              <th>{l('Time')}</th>
              <th>{l('Sectors')}</th>
            </tr>
            {cdToc.track_details.map((track, index) => (
              <tr key={index}>
                <td>{index + 1}</td>
                <td>{formatTrackLength(track.start_time)}</td>
                <td>{track.start_sectors}</td>
                <td>{formatTrackLength(track.length_time)}</td>
                <td>{track.length_sectors}</td>
                <td>{formatTrackLength(track.end_time)}</td>
                <td>{track.end_sectors}</td>
              </tr>
            ))}
          </table>
        </td>
      </tr>
    </table>
  </>
);

export default CDTocInfo;
