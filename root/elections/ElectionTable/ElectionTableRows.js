/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import formatUserDate from '../../utility/formatUserDate.js';
import {votesVisible} from '../../utility/voting.js';

type RowProps = {
  +election: AutoEditorElectionT,
  +index: number,
};

const ElectionTableRow = ({
  election,
  index,
}: RowProps): React.Element<'tr'> => {
  const $c = React.useContext(CatalystContext);
  return (
    <tr className={index % 2 ? 'even' : 'odd'}>
      <td><EditorLink editor={election.candidate} /></td>
      <td>
        {lp(election.status_name_short, 'autoeditor election status (short)')}
      </td>
      <td>{formatUserDate($c, election.propose_time)}</td>
      <td>
        {nonEmpty(election.close_time)
          ? formatUserDate($c, election.close_time)
          : '-'}
      </td>
      <td><EditorLink editor={election.proposer} /></td>
      <td>
        {election.seconder_1
          ? <EditorLink editor={election.seconder_1} />
          : '-'}
      </td>
      <td>
        {election.seconder_2
          ? <EditorLink editor={election.seconder_2} />
          : '-'}
      </td>
      <td>
        {votesVisible(election, $c.user)
          ? election.yes_votes
          : '-'}
      </td>
      <td>
        {votesVisible(election, $c.user)
          ? election.no_votes
          : '-'}
      </td>
      <td><a href={`/election/${election.id}`}>{l('View details')}</a></td>
    </tr>
  );
};

type Props = {
  +elections: $ReadOnlyArray<AutoEditorElectionT>,
};

const ElectionTableRows = ({
  elections,
}: Props): $ReadOnlyArray<React.Element<typeof ElectionTableRow>> => (
  elections.map((election, index) => (
    <ElectionTableRow
      election={election}
      index={index}
      key={election.id}
    />
  ))
);

export default ElectionTableRows;
