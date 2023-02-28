/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  EDIT_VOTE_NO,
  EDIT_VOTE_YES,
} from '../../constants.js';

function countVotes(
  votes: $ReadOnlyArray<VoteT>,
  voteValue: number,
): number {
  return votes.reduce(
    (count, vote) => {
      return count + ((vote.vote === voteValue && !vote.superseded) ? 1 : 0);
    },
    0,
  );
}

const VoteTally = ({edit}: {
  edit: GenericEditWithIdT,
}): Expand2ReactOutput => {
  if (edit.auto_edit) {
    return <strong>{l('automatically applied')}</strong>;
  }

  const yesVotes = countVotes(edit.votes, EDIT_VOTE_YES);
  const noVotes = countVotes(edit.votes, EDIT_VOTE_NO);

  return (
    exp.l(
      '{yes} yes : {no} no',
      {
        no: <strong>{noVotes}</strong>,
        yes: <strong>{yesVotes}</strong>,
      },
    )
  );
};

export default VoteTally;
