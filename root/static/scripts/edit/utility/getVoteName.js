/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  EDIT_VOTE_ABSTAIN,
  EDIT_VOTE_APPROVE,
  EDIT_VOTE_YES,
  EDIT_VOTE_NO,
  EDIT_VOTE_NONE,
} from '../../../../constants.js';

export default function getVoteName(
  vote: VoteOptionT,
): string {
  switch (vote) {
    case EDIT_VOTE_ABSTAIN:
      return 'Abstain';
    case EDIT_VOTE_APPROVE:
      return 'Approve';
    case EDIT_VOTE_YES:
      return 'Yes';
    case EDIT_VOTE_NO:
      return 'No';
    case EDIT_VOTE_NONE:
      return 'None';
    default:
      throw new Error('Unknown vote type: ' + String(vote));
  }
}
