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
import HistoricReleaseList
  from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: RemoveTrackHistoricEditT,
};

const RemoveTrack = ({edit}: Props): React$Element<'table'> => (
  <table className="details remove-track">
    <HistoricReleaseList releases={edit.display_data.releases} />
    <tr>
      <th>{l('Track:')}</th>
      <td>
        <DescriptiveLink
          content={edit.display_data.name}
          entity={edit.display_data.recording}
        />
      </td>
    </tr>
  </table>
);

export default RemoveTrack;
