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
import CDTocLink
  from '../../../static/scripts/common/components/CDTocLink';

type Props = {
  +edit: MoveDiscIdHistoricEditT,
};

const MoveDiscId = ({edit}: Props): React.Element<'table'> => (
  <table className="details move-discid">
    <tr>
      <th>{l('Disc ID:')}</th>
      <td>
        <CDTocLink
          cdToc={edit.display_data.cdtoc}
          content={edit.display_data.cdtoc.discid}
        />
      </td>
    </tr>
    <HistoricReleaseList
      label={l('From:')}
      releases={edit.display_data.old_releases}
    />
    <HistoricReleaseList
      label={l('To:')}
      releases={edit.display_data.new_releases}
    />
  </table>
);

export default MoveDiscId;
