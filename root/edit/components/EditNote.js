/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  EDIT_VOTE_APPROVE,
  EDIT_VOTE_NO,
  EDIT_VOTE_YES,
} from '../../constants';
import {CatalystContext} from '../../context.mjs';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import getVoteName from '../../static/scripts/edit/utility/getVoteName';
import formatUserDate from '../../utility/formatUserDate';

import EditorTypeInfo from './EditorTypeInfo';

type PropsT = {
  +edit: GenericEditWithIdT,
  +editNote: EditNoteT,
  +index: number,
  +isOnEditPage?: boolean,
};

function returnNoteAnchor(edit, index) {
  return `note-${edit.id}-${index + 1}`;
}

function returnVoteClass(vote, isOwner) {
  let className = '';

  if (vote) {
    className = getVoteName(vote.vote);
  }

  if (isOwner) {
    if (vote) {
      className += ' ';
    }
    className += 'owner';
  }

  return className;
}

const EditNote = ({
  edit,
  editNote,
  index,
  isOnEditPage = false,
}: PropsT): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const isModBot = editNote.editor_id === 4;
  const anchor = returnNoteAnchor(edit, index);
  const isOwner = edit.editor_id === editNote.editor_id;
  const lastRelevantVote = edit.votes.find(vote => (
    vote.editor_id === editNote.editor_id &&
    !vote.superseded
  ));
  const showVotingIcon = lastRelevantVote && (
    lastRelevantVote.vote === EDIT_VOTE_APPROVE ||
    lastRelevantVote.vote === EDIT_VOTE_NO ||
    lastRelevantVote.vote === EDIT_VOTE_YES
  );

  return (
    <div className="edit-note" id={anchor}>
      <h3 className={returnVoteClass(lastRelevantVote, isOwner)}>
        <EditorLink editor={editNote.editor} />
        {showVotingIcon /*:: === true */
          ? <div className="voting-icon" />
          : null}
        {' '}
        <EditorTypeInfo editor={editNote.editor} />
        <a
          className="date"
          href={(isOnEditPage ? '' : `/edit/${edit.id}`) + `#${anchor}`}
          rel={isOnEditPage ? null : 'noopener noreferrer'}
          target={isOnEditPage ? null : '_blank'}
        >
          {nonEmpty(editNote.post_time)
            ? formatUserDate($c, editNote.post_time)
            : l('[time missing]')}
        </a>
      </h3>
      <div
        className={'edit-note-text' + (isModBot ? ' modbot' : '')}
        dangerouslySetInnerHTML={{__html: editNote.formatted_text}}
      />
    </div>
  );
};

export default EditNote;
