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
  +edit: MoveDiscIdEditT,
};

const MoveDiscId = ({edit}: Props): React.Element<'table'> => {
  const oldMedium = edit.display_data.old_medium;
  const newMedium = edit.display_data.new_medium;
  const cdToc = edit.display_data.medium_cdtoc.cdtoc;

  return (
    <table className="details move-disc-id">
      <tr>
        <th>{l('Disc ID:')}</th>
        <td>
          <CDTocLink cdToc={cdToc} />
        </td>
      </tr>
      <tr>
        <th>{l('From:')}</th>
        <td><MediumLink medium={oldMedium} /></td>
      </tr>
      <tr>
        <th>{l('To:')}</th>
        <td><MediumLink medium={newMedium} /></td>
      </tr>
    </table>
  );
};

export default MoveDiscId;
