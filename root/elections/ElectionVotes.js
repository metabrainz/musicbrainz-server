/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import formatUserDate from '../utility/formatUserDate.js';

type PropsT = {
  +election: AutoEditorElectionT,
};

const ElectionVotes = ({election}: PropsT): React.Element<'table'> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <table className="tbl" style={{width: 'auto'}}>
      <thead>
        <tr>
          <th>{l('Voter')}</th>
          <th>{l('Vote')}</th>
          <th>{l('Date')}</th>
        </tr>
      </thead>
      <tbody>
        {election.votes.map((vote, index) => (
          <tr className={index % 2 ? 'even' : 'odd'} key={vote.voter.id}>
            <td><EditorLink editor={vote.voter} /></td>
            <td>
              {$c.user && $c.user.id === vote.voter.id
                ? lp(vote.vote_name, 'vote')
                : l('(private)')}
            </td>
            <td>{formatUserDate($c, vote.vote_time)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default ElectionVotes;
