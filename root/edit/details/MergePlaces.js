/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PlaceList from '../../components/list/PlaceList.js';

component MergePlaces(edit: MergePlacesEditT) {
  return (
    <table className="details merge-place">
      <tr>
        <th>{addColonText(lp('Merge', 'verb, header, paired with Into'))}</th>
        <td>
          <PlaceList places={edit.display_data.old} />
        </td>
      </tr>
      <tr>
        <th>{addColonText(lp('Into', 'header, paired with Merge'))}</th>
        <td>
          <PlaceList places={[edit.display_data.new]} />
        </td>
      </tr>
    </table>
  );
}

export default MergePlaces;
