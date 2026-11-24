/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::AutoEditorElection::TO_JSON
declare type AutoEditorElectionT = {
  ...EntityRoleT<empty>,
  readonly candidate: EditorT,
  readonly close_time?: string,
  readonly current_expiration_time: string,
  readonly is_closed: boolean,
  readonly is_open: boolean,
  readonly is_pending: boolean,
  readonly no_votes: number,
  readonly open_time?: string,
  readonly propose_time: string,
  readonly proposer: EditorT,
  readonly seconder_1?: EditorT,
  readonly seconder_2?: EditorT,
  readonly status_name: string,
  readonly status_name_short: string,
  readonly votes: ReadonlyArray<AutoEditorElectionVoteT>,
  readonly yes_votes: number,
};

// MusicBrainz::Server::Entity::AutoEditorElectionVote::TO_JSON
declare type AutoEditorElectionVoteT = {
  ...EntityRoleT<empty>,
  readonly vote_name: string,
  readonly vote_time: string,
  readonly voter: EditorT,
};
