/*
 * @flow strict
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
  EDITOR_MODBOT,
} from '../../constants.js';
import {CatalystContext} from '../../context.mjs';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import {isAccountAdmin, isAddingNotesDisabled}
  from '../../static/scripts/common/utility/privileges.js';
import getVoteName from '../../static/scripts/edit/utility/getVoteName.js';
import formatUserDate from '../../utility/formatUserDate.js';
import parseIsoDate from '../../utility/parseIsoDate.js';

import EditorTypeInfo from './EditorTypeInfo.js';

type PropsT = {
  +edit: GenericEditWithIdT,
  +editNote: EditNoteT,
  +index: number,
  +isOnEditPage?: boolean,
  +showEditControls?: boolean,
};

function returnNoteAnchor(edit: GenericEditWithIdT, index: number) {
  return `note-${edit.id}-${index + 1}`;
}

function returnVoteClass(vote: ?VoteT, isOwner: boolean) {
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
  showEditControls = true,
}: PropsT): React$Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  const allEditNotes = edit.edit_notes;
  const isModBot = editNote.editor_id === EDITOR_MODBOT;
  const anchor = returnNoteAnchor(edit, index);
  const isOwner = edit.editor_id === editNote.editor_id;
  const isCurrentEditor = Boolean(user && user.id === editNote.editor_id);
  const lastRelevantVote = edit.votes.find(vote => (
    vote.editor_id === editNote.editor_id &&
    !vote.superseded
  ));
  const showVotingIcon = lastRelevantVote && (
    lastRelevantVote.vote === EDIT_VOTE_APPROVE ||
    lastRelevantVote.vote === EDIT_VOTE_NO ||
    lastRelevantVote.vote === EDIT_VOTE_YES
  );

  // To display the appropriate message if the edit note has been changed
  const isDeleted = editNote.latest_change?.status === 'deleted';
  const isModified = editNote.latest_change?.status === 'edited';
  const changedBySelf =
    editNote.latest_change?.change_editor_id === editNote.editor_id;
  const changeReason = editNote.latest_change?.reason;
  const changeTime = editNote.latest_change?.change_time
    ? formatUserDate($c, editNote.latest_change.change_time)
    : null;

  /*
   * We only want to show the controls for modifying/removing a note
   * to a normal user in the case where the note is their own, nobody else
   * has posted in response (the same user or ModBot can have other notes),
   * the note is not older than 24 hours, and it hasn't already been removed.
   * For admins, we can show it all the time.
   */
  let hasReply = true;
  /*
   * If we haven't loaded the edit notes, we're probably
   * on the notes received page, so they won't be the editor's own notes
   * anyway and there's nothing to modify or remove for non-admins.
   */
  if (allEditNotes.length) {
    const noteIndex = allEditNotes.findIndex(note => note.id === editNote.id);
    const noteAndAfter = allEditNotes.slice(noteIndex);
    hasReply = (noteAndAfter.some(
      note => note.editor_id !== editNote.editor_id &&
              note.editor_id !== EDITOR_MODBOT,
    ));
  }
  const noteDate = nonEmpty(editNote.post_time)
    ? parseIsoDate(editNote.post_time)
    : null;
  const twentyFourHours = 86400000;
  const isRecent = Boolean(
    noteDate && (new Date().getTime() - noteDate.getTime()) < twentyFourHours,
  );
  const isAdmin = isAccountAdmin(user);
  const canBeChangedByOwner = isCurrentEditor && !hasReply &&
                              isRecent && !isDeleted &&
                              !isAddingNotesDisabled(user);
  const canShowEditControls = showEditControls &&
                              (canBeChangedByOwner || isAdmin);

  return (
    <div className="edit-note" id={anchor}>
      <h3 className={returnVoteClass(lastRelevantVote, isOwner)}>
        <EditorLink editor={editNote.editor} />
        {showVotingIcon /*:: === true */
          ? <div className="voting-icon" />
          : null}
        {' '}
        <EditorTypeInfo editor={editNote.editor} />
        {canShowEditControls ? (
          <span className="change-note-controls">
            {' '}
            <a
              className="edit-item icon"
              href={`/edit-note/${editNote.id}/modify`}
              title={l('Modify edit note')}
            />
            <a
              className="remove-item icon"
              href={`/edit-note/${editNote.id}/delete`}
              title={l('Remove edit note')}
            />
          </span>
        ) : null}
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
      {isDeleted ? (
        <div className="edit-note-text">
          <span className="deleted-note">
            {changedBySelf ? (
              nonEmpty(changeReason) ? (
                texp.l(
                  `This edit note was removed by its author.
                   Reason given: “{reason}”.`,
                  {reason: changeReason},
                )
              ) : (
                l(`This edit note was removed by its author.
                   No reason was provided.`)
              )
            ) : (
              nonEmpty(changeReason) ? (
                texp.l(
                  `This edit note was removed by an admin.
                   Reason given: “{reason}”.`,
                  {reason: changeReason},
                )
              ) : (
                l(`This edit note was removed by an admin.
                   No reason was provided.`)
              )
            )}
          </span>
          {isAdmin ? (
            <span className="small">
              {' '}
              {bracketed(
                <a href={`/edit-note/${editNote.id}/changes`}>
                  {lp('see all changes', 'edit note')}
                </a>,
              )}
            </span>
          ) : null}
        </div>
      ) : (
        <>
          <div
            className={'edit-note-text' + (isModBot ? ' modbot' : '')}
            dangerouslySetInnerHTML={{__html: editNote.formatted_text}}
          />
          {isModified ? (
            <div className="edit-note-modified-text small">
              {changedBySelf ? (
                nonEmpty(changeReason) ? (
                  texp.l(
                    `Last modified by the note author ({time}).
                     Reason given: “{reason}”.`,
                    {
                      reason: changeReason,
                      // $FlowIgnore[incompatible-call]
                      time: changeTime,
                    },
                  )
                ) : (
                  texp.l(
                    'Last modified by the note author ({time}).',
                    // $FlowIgnore[incompatible-call]
                    {time: changeTime},
                  )
                )
              ) : (
                nonEmpty(changeReason) ? (
                  texp.l(
                    `Last modified by an admin ({time}).
                     Reason given: “{reason}”.`,
                    {
                      reason: changeReason,
                      // $FlowIgnore[incompatible-call]
                      time: changeTime,
                    },
                  )
                ) : (
                  texp.l(
                    'Last modified by an admin ({time}).',
                    // $FlowIgnore[incompatible-call]
                    {time: changeTime},
                  )
                )
              )}
              {isAdmin ? (
                <>
                  {' '}
                  {bracketed(
                    <a href={`/edit-note/${editNote.id}/changes`}>
                      {lp('see all changes', 'edit note')}
                    </a>,
                  )}
                </>
              ) : null}
            </div>
          ) : null}
        </>
      )}
    </div>
  );
};

export default EditNote;
