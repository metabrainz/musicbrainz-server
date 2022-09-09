/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDTocLink from '../../static/scripts/common/components/CDTocLink.js';
import MediumLink
  from '../../static/scripts/common/components/MediumLink.js';

type Props = {
  +edit: RemoveDiscIdEditT,
};

const RemoveDiscId = ({edit}: Props): React.Element<'table'> => {
  const medium = edit.display_data.medium;
  const cdToc = edit.display_data.cdtoc;

  return (
    <table className="details remove-disc-id">
      <tr>
        <th>{l('Medium:')}</th>
        <td colSpan="2">
          <MediumLink medium={medium} />
        </td>
      </tr>
      <tr>
        <th>{l('Disc ID:')}</th>
        <td>
          <CDTocLink cdToc={cdToc} />
        </td>
      </tr>
    </table>
  );
};

export default RemoveDiscId;
