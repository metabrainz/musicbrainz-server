/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaList from '../../components/list/AreaList.js';

component MergeAreas(edit: MergeAreasEditT) {
  return (
    <table className="details merge-areas">
      <tr>
        <th>{addColonText(lp('Merge', 'verb, header, paired with Into'))}</th>
        <td>
          <AreaList areas={edit.display_data.old} />
        </td>
      </tr>
      <tr>
        <th>{addColonText(lp('Into', 'header, paired with Merge'))}</th>
        <td>
          <AreaList areas={[edit.display_data.new]} />
        </td>
      </tr>
    </table>
  );
}

export default MergeAreas;
