/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import HistoricReleaseList from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: ChangeReleaseGroupHistoricEditT,
};

const ChangeReleaseGroup = ({edit}: Props): React.Element<'table'> => (
  <table className="details change-release-group">
    <HistoricReleaseList
      colSpan="2"
      releases={edit.display_data.releases}
    />
    <tr>
      <th>{l('Release group:')}</th>
      <td className="old">
        <DescriptiveLink entity={edit.display_data.release_group.old} />
      </td>
      <td className="new">
        <DescriptiveLink entity={edit.display_data.release_group.new} />
      </td>
    </tr>
  </table>
);

export default ChangeReleaseGroup;
