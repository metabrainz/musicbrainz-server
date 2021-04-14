/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ReleaseGroupListTable} from '../../components/list/ReleaseGroupList';

type MergeReleaseGroupsEditT = {
  ...EditT,
  +display_data: {
    +new: ReleaseGroupT,
    +old: $ReadOnlyArray<ReleaseGroupT>,
  },
};

type Props = {
  +edit: MergeReleaseGroupsEditT,
};

const MergeReleaseGroups = ({edit}: Props): React.Element<'table'> => (
  <table className="details merge-release-groups">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <ReleaseGroupListTable releaseGroups={edit.display_data.old} />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <ReleaseGroupListTable releaseGroups={[edit.display_data.new]} />
      </td>
    </tr>
  </table>
);

export default MergeReleaseGroups;
