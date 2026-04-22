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
import manifest from '../static/manifest.mjs';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import {isBeginner} from '../static/scripts/common/utility/privileges.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import InlineSubmitButton
  from '../static/scripts/edit/components/InlineSubmitButton.js';
import NewNotesAlertCheckbox
  from '../static/scripts/edit/components/NewNotesAlertCheckbox.js';
import getRequestCookie from '../utility/getRequestCookie.mjs';

import EditNoteListEntry from './components/EditNoteListEntry.js';

component NotesReceived(
  editNotes: $ReadOnlyArray<EditNoteT>,
  modbotCondition?: '' | '=' | '!=',
  pager: PagerT,
) {
  const $c = React.useContext(CatalystContext);

  return (
    <Layout fullWidth title={l('Recent notes left on your edits')}>
      <div id="content">
        <h1>{l('Recent notes left on your edits')}</h1>
        {isBeginner($c.user) ? null : (
          <NewNotesAlertCheckbox
            checked={getRequestCookie(
              $c.req,
              'alert_new_edit_notes',
              'true',
            ) !== 'false'}
          />
        )}

        <form style={{marginTop: '1em'}}>
          <FormRow>
            <label>
              {addColonText(l('ModBot notes'))}
              {' '}
              <select
                defaultValue={modbotCondition ?? ''}
                name="modbot_condition"
              >
                <option value="">{l('Show all notes')}</option>
                <option value="=">{l('Show only notes by ModBot')}</option>
                <option value="!=">
                  {l('Show only notes by someone else')}
                </option>
              </select>
            </label>
            <InlineSubmitButton />
          </FormRow>
        </form>

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
      {manifest('edit/components/NewNotesAlertCheckbox', {async: true})}
    </Layout>
  );
}

export default NotesReceived;
