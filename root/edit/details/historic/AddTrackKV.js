/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import HistoricReleaseList
  from '../../components/HistoricReleaseList';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength';

type AddTrackKVEditT = {
  ...EditT,
  +display_data: {
    +artist?: ArtistT,
    +length: number,
    +name: string,
    +position: number,
    +recording: RecordingT,
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
};

type Props = {
  +edit: AddTrackKVEditT,
};

const AddTrackKV = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const artist = display.artist;
  /*
   * Some lengths of -1 or 0 ms are stored, which is nonsensical
   * and probably meant as a placeholder for unknown duration
   */
  const length = (display.length != null && display.length <= 0)
    ? null
    : display.length;

  return (
    <table className="details add-track">
      <HistoricReleaseList releases={display.releases} />

      <tr>
        <th>{addColonText(l('Name'))}</th>
        <td>
          <EntityLink
            content={display.name}
            entity={display.recording}
          />
        </td>
      </tr>

      {artist ? (
        <tr>
          <th>{addColonText(l('Artist'))}</th>
          <td>
            <EntityLink entity={artist} />
          </td>
        </tr>
      ) : null}

      <tr>
        <th>{addColonText(l('Track number'))}</th>
        <td>{display.position}</td>
      </tr>

      <tr>
        <th>{addColonText(l('Length'))}</th>
        <td>{formatTrackLength(length)}</td>
      </tr>
    </table>
  );
};

export default AddTrackKV;
