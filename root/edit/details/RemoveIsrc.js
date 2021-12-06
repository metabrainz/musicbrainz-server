/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CodeLink
  from '../../static/scripts/common/components/CodeLink';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import linkedEntities from '../../static/scripts/common/linkedEntities';

type Props = {
  +edit: RemoveIsrcEditT,
};

const RemoveIsrc = ({edit}: Props): React.Element<'table'> => {
  const isrc = edit.display_data.isrc;
  const recording = linkedEntities.recording[isrc.recording_id];

  return (
    <table className="details remove-isrc">
      <tr>
        <th>{addColonText(l('ISRC'))}</th>
        <td><CodeLink code={isrc} key="isrc" /></td>
      </tr>
      <tr>
        <th>{addColonText(l('Recording'))}</th>
        <td><DescriptiveLink entity={recording} /></td>
      </tr>
    </table>
  );
};

export default RemoveIsrc;
