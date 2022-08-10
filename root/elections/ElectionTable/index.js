/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Rows from './ElectionTableRows.js';

type PropsT = {
  +$c: CatalystContextT,
  +elections: $ReadOnlyArray<AutoEditorElectionT>,
};

const ElectionTable = ({
  $c,
  elections,
}: PropsT): React.Element<'table'> => (
  <table className="tbl" style={{width: 'auto'}}>
    <thead>
      <tr>
        <th>{l('Candidate')}</th>
        <th>{lp('Status', 'election status')}</th>
        <th>{l('Start date')}</th>
        <th>{l('End date')}</th>
        <th>{l('Proposer')}</th>
        <th>{l('Seconder 1')}</th>
        <th>{l('Seconder 2')}</th>
        <th>{l('Votes for')}</th>
        <th>{l('Votes against')}</th>
        <th>{'\u00A0'}</th>
      </tr>
    </thead>
    <tbody>
      <Rows $c={$c} elections={elections} />
    </tbody>
  </table>
);

export default ElectionTable;
