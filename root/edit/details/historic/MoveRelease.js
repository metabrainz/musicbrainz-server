/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import yesNo from '../../../static/scripts/common/utility/yesNo.js';
import HistoricReleaseList from '../../components/HistoricReleaseList.js';

component MoveRelease(edit: MoveReleaseHistoricEditT) {
  return (
    <table className="details edit-release">
      <HistoricReleaseList
        colSpan="2"
        releases={edit.display_data.releases}
      />
      <tr>
        <th>{l('Change track artists:')}</th>
        <td colSpan="2">{yesNo(edit.display_data.move_tracks)}</td>
      </tr>
      <tr>
        <th>{addColonText(l('Artist'))}</th>
        <td className="old">
          <DescriptiveLink entity={edit.display_data.artist.old} />
        </td>
        <td className="new">
          <DescriptiveLink entity={edit.display_data.artist.new} />
        </td>
      </tr>
    </table>
  );
}

export default MoveRelease;
