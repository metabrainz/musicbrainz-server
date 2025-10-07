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
  EDIT_VOTE_ADMIN_APPROVE,
  EDIT_VOTE_ADMIN_REJECT,
  EDIT_VOTE_APPROVE,
  EDIT_VOTE_NO,
  EDIT_VOTE_NONE,
  EDIT_VOTE_YES,
} from '../../../../constants.js';

export default function getVoteName(
  vote: VoteOptionT,
): string {
  return match (vote) {
    EDIT_VOTE_ABSTAIN => 'Abstain',
    EDIT_VOTE_ADMIN_APPROVE => 'Admin approval',
    EDIT_VOTE_ADMIN_REJECT => 'Admin rejection',
    EDIT_VOTE_APPROVE => 'Approve',
    EDIT_VOTE_YES => 'Yes',
    EDIT_VOTE_NO => 'No',
    EDIT_VOTE_NONE => 'None',
  };
}
