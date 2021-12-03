/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import NewNotesAlertCheckbox
  from '../static/scripts/edit/components/NewNotesAlertCheckbox.js';
import getRequestCookie from '../utility/getRequestCookie.mjs';

import EditNoteListEntry from './components/EditNoteListEntry.js';

type Props = {
  +editNotes: $ReadOnlyArray<EditNoteT>,
  +pager: PagerT,
};

const NotesReceived = ({
  editNotes,
  pager,
}: Props): React$Element<typeof Layout> => {
  const $c = React.useContext(CatalystContext);

  return (
    <Layout fullWidth title={l('Recent Notes Left on Your Edits')}>
      <div id="content">
        <h1>{l('Recent Notes Left on Your Edits')}</h1>
        {$c.user?.is_limited ? null : (
          <NewNotesAlertCheckbox
            checked={getRequestCookie(
              $c.req,
              'alert_new_edit_notes',
              'true',
            ) !== 'false'}
          />
        )}


        {editNotes.length ? (
          <div className="edit-notes">
            <PaginatedResults pager={pager}>
              {editNotes.map((editNote, index) => {
                const edit = linkedEntities.edit[editNote.edit_id];
                return (
                  <EditNoteListEntry
                    edit={edit}
                    editNote={editNote}
                    key={index}
                    showEditControls
                  />
                );
              })}
            </PaginatedResults>
          </div>
        ) : (
          <p>
            {l(`Nobody has left notes on any of your edits
                in the past three months.`)}
          </p>
        )}
      </div>
      {manifest.js('edit/components/NewNotesAlertCheckbox', {async: 'async'})}
    </Layout>
  );
};

export default NotesReceived;
