/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CodeLink
  from '../../static/scripts/common/components/CodeLink.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';

type Props = {
  +edit: RemoveIswcEditT,
};

const RemoveIswc = ({edit}: Props): React.Element<'table'> => {
  const iswc = edit.display_data.iswc;
  const work = linkedEntities.work[iswc.work_id];

  return (
    <table className="details remove-iswc">
      <tr>
        <th>{addColonText(l('ISWC'))}</th>
        <td><CodeLink code={iswc} key="iswc" /></td>
      </tr>
      <tr>
        <th>{addColonText(l('Work'))}</th>
        <td><DescriptiveLink entity={work} /></td>
      </tr>
    </table>
  );
};

export default RemoveIswc;
