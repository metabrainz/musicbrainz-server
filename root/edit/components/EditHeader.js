/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RequestLogin from '../../components/RequestLogin.js';
import SubHeader from '../../components/SubHeader.js';
import VotingPeriod from '../../components/VotingPeriod.js';
import {EDIT_VOTE_ADMIN_APPROVE, EDIT_VOTE_APPROVE} from '../../constants.js';
import {CatalystContext} from '../../context.mjs';
import EditLink from '../../static/scripts/common/components/EditLink.js';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import linkedEntities from '../../static/scripts/common/linkedEntities.mjs';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import HelpIcon from '../../static/scripts/edit/components/HelpIcon.js';
import getVoteName from '../../static/scripts/edit/utility/getVoteName.js';
import {
  editorMayApprove,
  editorMayCancel,
  editorMayVote,
  getEditHeaderClass,
  getLatestVoteForEditor,
} from '../../utility/edit.js';
import formatUserDate from '../../utility/formatUserDate.js';
import {returnToCurrentPage} from '../../utility/returnUri.js';

import EditorTypeInfo from './EditorTypeInfo.js';
import VoteTally from './VoteTally.js';

component EditHeader(
  edit: GenericEditWithIdT,
  isSummary: boolean = false,
  voter?: UnsanitizedEditorT,
) {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  const mayApprove = editorMayApprove(edit, user);
  const mayCancel = editorMayCancel(edit, user);
  const mayVote = editorMayVote(user);
  const editTitle = texp.l(
    'Edit #{id} - {name}',
    {id: edit.id, name: lp(edit.edit_name, edit.edit_type_name_context)},
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
    (vote) => (vote.vote === EDIT_VOTE_APPROVE ||
               vote.vote === EDIT_VOTE_ADMIN_APPROVE),
  );
  const showVoteTally = latestVoteForEditor || isEditEditor || !edit.is_open;

  const docLink = `/doc/Edit_Types/${edit.edit_type}`;
  const docTooltip = (
    <div className="edit-help">
      <HelpIcon
        content={exp.l(
          `See the documentation for this edit type: {doc_link|{edit_name}}.`,
          {
            doc_link: {
              href: docLink,
              target: '_blank',
            },
            edit_name: l(edit.edit_name),
          },
        )}
        marginLeft="3px"
        verticalAlign="middle"
      />
    </div>
  );

  const subHeading = user ? (
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
        <RequestLogin text={l('log in to see who')} />,
      )}
    </>
  );

  return (
    <div className={getEditHeaderClass(edit)}>
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
                  ) : mayVote ? (
                    <div className="my-vote">
                      <strong>{l('My vote: ')}</strong>
                      {nonEmpty(latestVoteForEditorName) ? (
                        lp(latestVoteForEditorName, 'vote')
                      ) : isEditEditor ? (
                        l('N/A')
                      ) : lp('None', 'vote')}
                    </div>
                  ) : null}
                </td>
                <td className="vote-count">
                  {showVoteTally ? (
                    <div>
                      {user ? null : (
                        <>
                          <strong>{addColonText(l('Vote tally'))}</strong>
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
                      <strong>{addColonText(l('Voting'))}</strong>
                      {' '}
                      <VotingPeriod
                        closingDate={edit.expires_time}
                      />
                    </>
                  ) : editWasApproved ? (
                    <>
                      <strong>{addColonText(l('Approved'))}</strong>
                      {' '}
                      {formatUserDate($c, edit.close_time)}
                    </>
                  ) : (
                    <>
                      <strong>{addColonText(l('Closed'))}</strong>
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
            {docTooltip}
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
          <h1>
            {editTitle}
            {docTooltip}
          </h1>
        </>
      )}

      <SubHeader subHeading={subHeading} />
    </div>
  );
}

export default EditHeader;
