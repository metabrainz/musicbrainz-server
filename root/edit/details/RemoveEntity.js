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
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {ENTITY_NAMES} from '../../static/scripts/common/constants.js';

type Props = {
  +edit: RemoveEntityEditT,
};

const RemoveEntity = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className={`details remove-${display.entity_type}`}>
      <tr>
        <th>{addColonText(ENTITY_NAMES[display.entity_type]())}</th>
        <td><DescriptiveLink entity={display.entity} /></td>
      </tr>
    </table>
  );
};

export default RemoveEntity;
