/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength.js';
import HistoricReleaseList
  from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: AddTrackKVHistoricEditT,
};

const AddTrackKV = ({edit}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const artist = display.artist;

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
        <td>{formatTrackLength(display.length)}</td>
      </tr>
    </table>
  );
};

export default AddTrackKV;
