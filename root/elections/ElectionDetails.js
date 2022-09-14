/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import VotingPeriod from '../components/VotingPeriod.js';
import {CatalystContext} from '../context.mjs';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import bracketed from '../static/scripts/common/utility/bracketed.js';
import formatUserDate from '../utility/formatUserDate.js';
import {votesVisible} from '../utility/voting.js';

type PropsT = {
  +election: AutoEditorElectionT,
};

const ElectionDetails = ({election}: PropsT): React.MixedElement => {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <h2>{l('Details')}</h2>
      <table className="properties">
        <tr>
          <th>{l('Candidate:')}</th>
          <td><EditorLink editor={election.candidate} /></td>
        </tr>
        <tr>
          <th>{l('Proposer:')}</th>
          <td><EditorLink editor={election.proposer} /></td>
        </tr>
        <tr>
          <th>{l('1st seconder:')}</th>
          <td>
            {election.seconder_1
              ? <EditorLink editor={election.seconder_1} />
              : '-'}
          </td>
        </tr>
        <tr>
          <th>{l('2nd seconder:')}</th>
          <td>
            {election.seconder_2
              ? <EditorLink editor={election.seconder_2} />
              : '-'}
          </td>
        </tr>
        {votesVisible(election, $c.user)
          ? (
            <>
              <tr>
                <th>{l('Votes for:')}</th>
                <td>{election.yes_votes}</td>
              </tr>
              <tr>
                <th>{l('Votes against:')}</th>
                <td>{election.no_votes}</td>
              </tr>
            </>
          ) : (
            election.is_open
              ? (
                <tr>
                  <th>{l('Votes for/against:')}</th>
                  <td>
                    {l(`The tally of votes cast will only be shown
                        when the election is complete.`)}
                  </td>
                </tr>
              ) : null
          )
        }
        <tr>
          <th>{lp('Status:', 'election status')}</th>
          <td>
            {election.is_open && nonEmpty(election.open_time)
              ? (
                texp.lp(election.status_name, 'autoeditor election status', {
                  date: formatUserDate($c, election.open_time),
                })
              ) : null}

            {election.is_pending
              ? lp(election.status_name, 'autoeditor election status')
              : null}

            {election.is_pending || election.is_open
              ? (
                <>
                  {' '}
                  {bracketed(
                    <VotingPeriod
                      closingDate={election.current_expiration_time}
                    />,
                  )}
                </>
              ) : null}

            {election.is_closed
              ? (
                nonEmpty(election.close_time)
                  ? (
                    texp.lp(
                      election.status_name,
                      'autoeditor election status',
                      {
                        date: formatUserDate($c, election.close_time),
                      },
                    )
                  ) : (
                    lp(
                      election.status_name_short,
                      'autoeditor election status (short)',
                    )
                  )
              ) : null}

            {(election.is_open || election.is_pending || election.is_closed)
              ? null
              : lp(election.status_name, 'autoeditor election status')}
          </td>
        </tr>
      </table>
    </>
  );
};

export default ElectionDetails;
