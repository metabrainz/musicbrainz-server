/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import MediumTracklist from '../../../../medium/MediumTracklist.js';
import bracketed from '../utility/bracketed.js';

export component CDTocTracklistToggle(
  hidden: boolean,
  onButtonClick: (SyntheticMouseEvent<HTMLAnchorElement>) => void,
) {
  return (
    <>
      {' '}
      <small>
        {bracketed(
          <a
            className="toggle"
            onClick={onButtonClick}
            style={{cursor: 'pointer'}}
          >
            {hidden ? l('show tracklist') : l('hide tracklist')}
          </a>,
        )}
      </small>
    </>
  );
}

export component CDTocTracklistBlock(
  hidden: boolean,
  medium: MediumT,
) {
  return (
    <tr
      className="tracklist"
      style={hidden ? {display: 'none'} : {}}
    >
      <td />
      <td colSpan={6}>
        <table
          className="tbl medium"
          style={{borderCollapse: 'collapse'}}
        >
          <tbody>
            <MediumTracklist tracks={medium.tracks} />
          </tbody>
        </table>
      </td>
    </tr>
  );
}
