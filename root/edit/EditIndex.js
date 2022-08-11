/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import FormSubmit from '../components/FormSubmit.js';
import RequestLogin from '../components/RequestLogin.js';
import {CatalystContext} from '../context.mjs';
import DBDefs from '../static/scripts/common/DBDefs.mjs';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import EditLink from '../static/scripts/common/components/EditLink.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import getVoteName from '../static/scripts/edit/utility/getVoteName.js';
import {editorMayAddNote, editorMayVote}
  from '../utility/edit.js';
import formatUserDate from '../utility/formatUserDate.js';

import EditHeader from './components/EditHeader.js';
import EditNotes from './components/EditNotes.js';
import EditSidebar from './components/EditSidebar.js';
import Vote from './components/Vote.js';
import VoteTally from './components/VoteTally.js';
import getEditDetailsElement from './utility/getEditDetailsElement.js';

type Props = {
  +edit: $ReadOnly<{...EditT, +id: number}>,
  +fullWidth?: boolean,
};

const EditIndex = ({
  edit,
  fullWidth = false,
}: Props): React.Element<typeof Layout> => {
  const $c = React.useContext(CatalystContext);
  const canAddNote = Boolean($c.user && editorMayAddNote(edit, $c.user));
  const isOwnEdit = Boolean($c.user && $c.user.id === edit.editor_id);
  const canVote = Boolean($c.user && editorMayVote(edit, $c.user));
  const detailsElement = getEditDetailsElement(edit);

  return (
    <Layout fullWidth={fullWidth} title={texp.l('Edit #{id}', {id: edit.id})}>
      <div id="content">
        <EditHeader edit={edit} />

        <h2>{l('Changes')}</h2>
        {edit.data ? detailsElement : (
          <>
            <p>{l('An error occurred while loading this edit.')}</p>
            <EditLink
              content={l('Raw edit data may be available.')}
              edit={edit}
              subPath="data"
            />
          </>
        )}

        <h2>{l('Votes')}</h2>
        <form action="/edit/enter_votes" method="post">
          <input name="url" type="hidden" value={$c.req.uri} />
          <input
            name="enter-vote.vote.0.edit_id"
            type="hidden"
            value={edit.id}
          />

          <table className="vote-tally">
            <tr className="noborder">
              <th>{addColonText(l('Vote tally'))}</th>
              <td className="vote"><VoteTally edit={edit} /></td>
            </tr>
            {$c.user ? (
              <>
                {canVote ? (
                  <tr className="noborder">
                    <th>{l('My vote:')}</th>
                    <td className="vote">
                      <Vote edit={edit} />
                    </td>
                  </tr>
                ) : null}
                {edit.votes.map((vote, index) => {
                  const voter = linkedEntities.editor[vote.editor_id];

                  return (
                    <tr
                      className={vote.superseded
                        ? 'superseded'
                        : edit.votes.length === 1
                          ? 'first'
                          : ''}
                      key={index}
                    >
                      <th><EditorLink editor={voter} /></th>
                      <td className="vote">
                        {lp(getVoteName(vote.vote), 'vote')}
                        <span className="date">
                          {formatUserDate($c, vote.vote_time)}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </>
            ) : null}
          </table>

          {edit.is_open && $c.user && !canVote && !isOwnEdit ? (
            <p>
              {exp.l(
                `You are not currently able
                 to vote on this edit. ({url|Details})`,
                {url: '/doc/Introduction_to_Voting'},
              )}
            </p>
          ) : null}

          {$c.user ? (
            edit.is_open && DBDefs.DB_STAGING_TESTING_FEATURES ? (
              <>
                <h2>{l('Testing features')}</h2>
                <p>
                  {l(`To aid in testing, the following features
                      have been made available on testing servers:`)}
                </p>
                <ul>
                  <li>
                    <a href={'/test/accept-edit/' + edit.id}>
                      {l('Accept edit')}
                    </a>
                  </li>
                  <li>
                    <a href={'/test/reject-edit/' + edit.id}>
                      {l('Reject edit')}
                    </a>
                  </li>
                </ul>
              </>
            ) : null
          ) : (
            <p>
              {l('You must be logged in to vote on edits.')}
              {' '}
              <RequestLogin />
            </p>
          )}

          <h2>{l('Edit notes')}</h2>
          {$c.user ? (
            <>
              <EditNotes edit={edit} index={0} isOnEditPage />
              {canVote ? (
                <FormSubmit label={l('Submit vote and note')} />
              ) : canAddNote ? (
                <FormSubmit label={l('Submit note')} />
              ) : null}
            </>
          ) : (
            <p>
              {l('You must be logged in to see edit notes.')}
              {' '}
              <RequestLogin />
            </p>
          )}
        </form>
      </div>

      {fullWidth ? null : (
        <EditSidebar edit={edit} />
      )}
    </Layout>
  );
};

export default EditIndex;
