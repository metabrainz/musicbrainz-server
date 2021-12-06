/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import HistoricReleaseList from '../../components/HistoricReleaseList';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';

type Props = {
  +edit: ChangeReleaseArtistHistoricEditT,
};

const ChangeReleaseArtist = ({edit}: Props): React.Element<'table'> => (
  <table className="details change-release-artist">
    <HistoricReleaseList
      colSpan="2"
      releases={edit.display_data.releases}
    />
    <tr>
      <th>{l('Artist:')}</th>
      <td className="old">
        <DescriptiveLink entity={edit.display_data.artist.old} />
      </td>
      <td className="new">
        <DescriptiveLink entity={edit.display_data.artist.new} />
      </td>
    </tr>
  </table>
);

export default ChangeReleaseArtist;
