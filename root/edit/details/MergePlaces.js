/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PlaceList from '../../components/list/PlaceList.js';

type Props = {
  +edit: MergePlacesEditT,
};

const MergePlaces = ({edit}: Props): React.Element<'table'> => (
  <table className="details merge-place">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <PlaceList places={edit.display_data.old} />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <PlaceList places={[edit.display_data.new]} />
      </td>
    </tr>
  </table>
);

export default MergePlaces;
