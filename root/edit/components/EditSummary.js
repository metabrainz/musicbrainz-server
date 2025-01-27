/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  EDIT_STATUS_APPLIED,
  EDIT_STATUS_OPEN,
} from '../../constants.js';
import {CatalystContext} from '../../context.mjs';
import {
  DB_READ_ONLY,
  DB_STAGING_TESTING_FEATURES,
} from '../../static/scripts/common/DBDefs.mjs';
import {
  editorMayAddNote,
  editorMayApprove,
  editorMayCancel,
  getEditStatusName,
} from '../../utility/edit.js';
import returnUri from '../../utility/returnUri.js';

import Vote from './Vote.js';

component EditSummary(
  edit: GenericEditWithIdT,
  index: number,
) {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;
  const mayAddNote = editorMayAddNote(edit, user);
  const mayApprove = editorMayApprove(edit, user);
  const mayCancel = editorMayCancel(edit, user);

  return (
    <>
      {edit.status !== EDIT_STATUS_OPEN &&
        edit.status !== EDIT_STATUS_APPLIED ? (
          <div className="edit-status">
            {getEditStatusName(edit)}
          </div>
        ) : null}

      <Vote edit={edit} index={index} summary />

      {($c.user && !DB_READ_ONLY &&
        (mayAddNote || mayApprove || mayCancel)
      ) ? (
        <div className="cancel-edit buttons">
          {mayAddNote ? (
            <button className="positive edit-note-toggle" type="button">
              {lp('Add note', 'interactive')}
            </button>
          ) : null}

          {mayApprove ? (
            <a
              className="positive"
              href={returnUri($c, `/edit/${edit.id}/approve`)}
            >
              {l('Approve edit')}
            </a>
          ) : null}

          {mayCancel ? (
            <a
              className="negative"
              href={returnUri($c, `/edit/${edit.id}/cancel`)}
            >
              {l('Cancel edit')}
            </a>
          ) : null}

          {edit.status === EDIT_STATUS_OPEN &&
            DB_STAGING_TESTING_FEATURES ? (
              <>
                <a
                  className="positive"
                  href={`/test/accept-edit/${edit.id}`}
                >
                  {l('Accept edit')}
                </a>
                <a
                  className="negative"
                  href={`/test/reject-edit/${edit.id}`}
                >
                  {l('Reject edit')}
                </a>
              </>
            ) : null}
        </div>) : null}
    </>
  );
}

export default EditSummary;
