/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Rows from './ElectionTableRows.js';

component ElectionTable(elections: $ReadOnlyArray<AutoEditorElectionT>) {
  return (
    <table className="tbl" style={{width: 'auto'}}>
      <thead>
        <tr>
          <th>{l('Candidate')}</th>
          <th>{lp('Status', 'election status')}</th>
          <th>{l('Start date')}</th>
          <th>{l('End date')}</th>
          <th>{l('Proposer')}</th>
          <th>{l('1st seconder')}</th>
          <th>{l('2nd seconder')}</th>
          <th>{l('Votes for')}</th>
          <th>{l('Votes against')}</th>
          <th>{'\u00A0'}</th>
        </tr>
      </thead>
      <tbody>
        <Rows elections={elections} />
      </tbody>
    </table>
  );
}

export default ElectionTable;
