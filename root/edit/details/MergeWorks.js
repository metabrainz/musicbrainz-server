/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WorkList from '../../components/list/WorkList';

type MergeWorksEditT = {
  ...EditT,
  +display_data: {
    +new: WorkT,
    +old: $ReadOnlyArray<WorkT>,
  },
};

type Props = {
  +edit: MergeWorksEditT,
};

const MergeWorks = ({edit}: Props): React.Element<'table'> => (
  <table className="details merge-works">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <WorkList works={edit.display_data.old} />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <WorkList works={[edit.display_data.new]} />
      </td>
    </tr>
  </table>
);

export default MergeWorks;
