/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';

type RemovePuidEditT = {
  ...EditT,
  +display_data: {
    +puid_name: string,
    +recording: RecordingT,
  },
};

type Props = {
  +edit: RemovePuidEditT,
};

const RemovePuid = ({edit}: Props): React.Element<'table'> => (
  <table className="details remove-puid">
    <tr>
      <th>{l('Recording:')}</th>
      <td><DescriptiveLink entity={edit.display_data.recording} /></td>
    </tr>
    <tr>
      <th>{l('PUID:')}</th>
      <td>{edit.display_data.puid_name}</td>
    </tr>
  </table>
);

export default RemovePuid;
