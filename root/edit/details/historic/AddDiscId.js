/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDTocLink
  from '../../../static/scripts/common/components/CDTocLink.js';
import HistoricReleaseList
  from '../../components/HistoricReleaseList.js';

type Props = {
  +edit: AddDiscIdHistoricEditT,
};

const AddDiscId = ({edit}: Props): React.Element<'table'> => (
  <table className="details add-discid">
    <HistoricReleaseList releases={edit.display_data.releases} />
    <tr>
      <th>{l('CD TOC:')}</th>
      <td>{edit.display_data.full_toc}</td>
    </tr>
    <tr>
      <th>{l('Disc ID:')}</th>
      <td>
        <CDTocLink cdToc={edit.display_data.cdtoc} />
      </td>
    </tr>
  </table>
);

export default AddDiscId;
