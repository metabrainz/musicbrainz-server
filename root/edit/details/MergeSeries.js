/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SeriesList from '../../components/list/SeriesList.js';

type Props = {
  +edit: MergeSeriesEditT,
};

const MergeSeries = ({edit}: Props): React.Element<'table'> => (
  <table className="details merge-series">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <SeriesList series={edit.display_data.old} />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <SeriesList series={[edit.display_data.new]} />
      </td>
    </tr>
  </table>
);

export default MergeSeries;
