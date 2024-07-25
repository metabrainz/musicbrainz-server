/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import DBDefs from '../../static/scripts/common/DBDefs.mjs';
import {
  editorMayAddNote,
} from '../../utility/edit.js';

import EditNote from './EditNote.js';
import EditNoteHelp from './EditNoteHelp.js';

component EditNotes(
  edit: GenericEditWithIdT,
  hide: boolean = false,
  index: number = 0,
  isOnEditList?: boolean,
  isOnEditPage?: boolean,
  verbose: boolean = true,
) {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  const mayAddNote = editorMayAddNote(edit, user);
  const editNotes = edit.edit_notes;

  return (
    <div className="edit-notes">
      {editNotes?.length ? (
        editNotes.map((note, index) => (
          <EditNote
            edit={edit}
            editNote={note}
            index={index}
            isOnEditList={isOnEditList}
            isOnEditPage={isOnEditPage}
            key={index}
          />
        ))
      ) : verbose ? (
        <div className="edit-note">
          <em>{l('No edit notes have been added.')}</em>
        </div>
      ) : null}

      {DBDefs.DB_READ_ONLY ? null : (
        mayAddNote ? (
          <div
            className="add-edit-note edit-note"
            style={hide ? {display: 'none'} : {}}
          >
            <EditNoteHelp />
            <div className="edit-note-text">
              <textarea
                className="edit-note"
                name={`enter-vote.vote.${index}.edit_note`}
                placeholder={l('Add an edit note')}
                rows="5"
              />
            </div>
          </div>
        ) : (
          <p>
            {exp.l(
              `You are not currently able to add notes to this edit.
               ({url|Details})`,
              {url: '/doc/Editing_FAQ'},
            )}
          </p>
        )
      )}
    </div>
  );
}

export default EditNotes;
