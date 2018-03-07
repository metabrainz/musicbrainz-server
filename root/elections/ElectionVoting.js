/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import Frag from '../components/Frag';
import {l, lp} from '../static/scripts/common/i18n';
import EditorLink from '../static/scripts/common/components/EditorLink';
import formatUserDate from '../utility/formatUserDate';
import {canCancel, canSecond, canVote, isInvolved, votesVisible} from '../utility/voting';
import ExpirationDate from '../components/ExpirationDate';

const ElectionVoting = ({election, user}) => {
  let message = l('To find out if you can vote for this candidate, please {url|log in}.',
    {__react: true, url: '/login'});
  if (user) {
    if (!user.is_auto_editor) {
      message = l('You cannot vote for this candidate, because you are not an auto-editor.');
    } else if (isInvolved(election, user)) {
      message = l('You cannot vote for this candidate, because you proposed / seconded them.');
    } else if (election.is_pending) {
      message = l('Voting is not yet open. If you would like to support this candidate, you can second their nomination. If you do not support this candidate, please note that you cannot cast a "No" vote (or abstain) until two seconders have been found.');
    } else if (election.is_closed) {
      message = l('Voting is closed.');
    }
  }
  return (
    <Frag>
      {canSecond(election, user) ? (
        <p>
          <form action={`/election/${election.id}/second`} method="post">
            <span className="buttons">
              <button name="confirm.submit" type="submit" value="1">{l('Second this candidate')}</button>
            </span>
          </form>
        </p>
      ) : null}
      <p>
        {canVote(election, user) ? (
          <form action={`/election/${election.id}/vote`} method="post">
            <span className="buttons">
              <button name="vote.vote" type="submit" value="1">{l('Vote YES')}</button>
              <button name="vote.vote" type="submit" value="-1">{l('Vote NO')}</button>
              <button name="vote.vote" type="submit" value="0">{l('Abstain')}</button>
            </span>
          </form>
        ) : message}
      </p>
      {canCancel(election, user) ? (
        <p>
          <form action={`/election/${election.id}/cancel`} method="post">
            <span className="buttons">
              <button className="negative" name="confirm.submit" type="submit" value="1">{l('Cancel the election')}</button>
            </span>
          </form>
        </p>
      ) : null}
    </Frag>
  );
};

export default ElectionVoting;
