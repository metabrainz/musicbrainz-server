/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import InstrumentList from '../../components/list/InstrumentList';

type MergeInstrumentsEditT = {
  ...EditT,
  +display_data: {
    +new: InstrumentT,
    +old: $ReadOnlyArray<InstrumentT>,
  },
};

type Props = {
  +$c: CatalystContextT,
  +edit: MergeInstrumentsEditT,
};

const MergeInstruments = ({$c, edit}: Props): React.Element<'table'> => (
  <table className="details merge-instruments">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <InstrumentList $c={$c} instruments={edit.display_data.old} />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <InstrumentList $c={$c} instruments={[edit.display_data.new]} />
      </td>
    </tr>
  </table>
);

export default MergeInstruments;
