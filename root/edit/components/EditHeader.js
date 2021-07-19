/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {EDIT_VOTE_APPROVE} from '../../constants';
import RequestLogin from '../../components/RequestLogin';
import VotingPeriod from '../../components/VotingPeriod';
import linkedEntities from '../../static/scripts/common/linkedEntities';
import EditLink from '../../static/scripts/common/components/EditLink';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import {isBot} from '../../static/scripts/common/utility/privileges';
import {kebabCase} from '../../static/scripts/common/utility/strings';
import getVoteName from '../../static/scripts/edit/utility/getVoteName';
import {
  editorMayApprove,
  editorMayCancel,
  getEditStatusClass,
  getLatestVoteForEditor,
} from '../../utility/edit';
import formatUserDate from '../../utility/formatUserDate';
import {returnToCurrentPage} from '../../utility/returnUri';

import VoteTally from './VoteTally';

type Props = {
  +$c: CatalystContextT,
  +edit: {...EditT, +id: number},
  +isSummary?: boolean,
  +voter?: UnsanitizedEditorT,
};

const EditorTypeInfo = ({editor}: {editor: EditorT}) => (
  editor.is_limited ? (
    <span className="editor-class">
      {bracketed(
        <span
          className="tooltip"
          title={l('This user is new to MusicBrainz.')}
        >
          {l('beginner')}
        </span>,
      )}
    </span>
  ) : isBot(editor) ? (
    <span className="editor-class">
      {bracketed(
        <span className="tooltip" title={l('This user is automated.')}>
          {l('bot')}
        </span>,
      )}
    </span>
  ) : null
);

const EditHeader = ({
  $c,
  edit,
  isSummary = false,
  voter,
}: Props): React.Element<'div'> => {
  const user = $c.user;
  const mayApprove = editorMayApprove(edit, user);
  const mayCancel = editorMayCancel(edit, user);
  const editTitle = texp.l(
    'Edit #{id} - {name}',
    {id: edit.id, name: l(edit.edit_name)},
  );
  const editEditor = linkedEntities.editor[edit.editor_id];
  const isEditEditor = user ? user.id === edit.editor_id : false;
  const isVoter = user && voter && user.id === voter.id;
  const latestVoteForEditor = user
    ? getLatestVoteForEditor(edit, user)
    : null;
  const latestVoteForEditorName = latestVoteForEditor
    ? getVoteName(latestVoteForEditor.vote)
    : null;
  const latestVoteForVoter = voter
    ? getLatestVoteForEditor(edit, voter)
    : null;
  const latestVoteForVoterName = latestVoteForVoter
    ? getVoteName(latestVoteForVoter.vote)
    : null;
  const editWasApproved = !edit.is_open && edit.votes.some(
    (vote) => vote.vote === EDIT_VOTE_APPROVE,
  );
  const showVoteTally = latestVoteForEditor || isEditEditor || !edit.is_open;

  return (
    <div
      className={
        'edit-header' + ' ' +
        getEditStatusClass(edit) + ' ' +
        'edit-' + edit.edit_kind + ' ' +
        kebabCase(edit.edit_name)}
    >
      {isSummary ? (
        <>
          <div className="edit-description">
            <table>
              <tr>
                <td>
                  {voter && isVoter === false ? (
                    <div className="my-vote">
                      <strong>{l('Their vote: ')}</strong>
                      {nonEmpty(latestVoteForVoterName)
                        ? lp(latestVoteForVoterName, 'vote')
                        : null}
                    </div>
                  ) : user ? (
                    <div className="my-vote">
                      <strong>{l('My vote: ')}</strong>
                      {nonEmpty(latestVoteForEditorName) ? (
                        lp(latestVoteForEditorName, 'vote')
                      ) : isEditEditor ? (
                        l('N/A')
                      ) : l('None')}
                    </div>
                  ) : null}
                </td>
                <td className="vote-count">
                  {showVoteTally ? (
                    <div>
                      {user ? null : (
                        <>
                          <strong>{addColon(l('Vote tally'))}</strong>
                          {' '}
                        </>
                      )}
                      <VoteTally edit={edit} />
                    </div>
                  ) : null}
                </td>
              </tr>
              <tr>
                <td className="edit-expiration" colSpan="2">
                  {edit.is_open ? (
                    <>
                      <strong>{addColon(l('Voting'))}</strong>
                      {' '}
                      <VotingPeriod
                        $c={$c}
                        closingDate={edit.expires_time}
                      />
                    </>
                  ) : editWasApproved ? (
                    <>
                      <strong>{addColon(l('Approved'))}</strong>
                      {' '}
                      {formatUserDate($c, edit.close_time)}
                    </>
                  ) : (
                    <>
                      <strong>{addColon(l('Closed'))}</strong>
                      {' '}
                      {formatUserDate($c, edit.close_time)}
                    </>
                  )}
                </td>
              </tr>
            </table>
          </div>
          <h2>
            <EditLink content={editTitle} edit={edit} />
          </h2>
        </>
      ) : (
        <>
          {user && (mayApprove || mayCancel) ? (
            <div className="cancel-edit buttons">
              {mayApprove ? (
                <a
                  className="positive"
                  href={`/edit/${edit.id}/approve?${returnToCurrentPage($c)}`}
                >
                  {l('Approve edit')}
                </a>
              ) : null}
              {mayCancel ? (
                <a
                  className="negative"
                  href={`/edit/${edit.id}/cancel?${returnToCurrentPage($c)}`}
                >
                  {l('Cancel edit')}
                </a>
              ) : null}
            </div>
          ) : null}
          <h1>{editTitle}</h1>
        </>
      )}

      <p className="subheader">
        <span className="prefix">{'~'}</span>
        {user ? (
          <>
            {exp.l(
              'Edit by {editor}',
              {editor: <EditorLink editor={editEditor} />},
            )}
            {' '}
            <EditorTypeInfo editor={editEditor} />
          </>
        ) : (
          <>
            {l('Editor hidden')}
            {' '}
            {/* Show editor type since knowing it's, say, a bot is useful */}
            <EditorTypeInfo editor={editEditor} />
            {' '}
            {bracketed(
              <RequestLogin $c={$c} text={l('log in to see who')} />,
            )}
          </>
        )}
      </p>
    </div>
  );
};

export default EditHeader;
