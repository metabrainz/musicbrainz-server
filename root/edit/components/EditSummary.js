/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  EDIT_STATUS_OPEN,
  EDIT_STATUS_APPLIED,
} from '../../constants';
import {withCatalystContext} from '../../context';
import * as DBDefs from '../../static/scripts/common/DBDefs';
import {l} from '../../static/scripts/common/i18n';
import {
  editorMayAddNote,
  editorMayApprove,
  editorMayCancel,
  getEditStatusName,
} from '../../utility/edit';
import returnUri from '../../utility/returnUri';

import Vote from './Vote';

type Props = {|
  +$c: CatalystContextT,
  +edit: EditT,
  +index: number,
|};

const EditSummary = ({$c, edit, index}: Props) => {
  const user = $c.user;
  const mayAddNote = editorMayAddNote(edit, user);
  const mayApprove = editorMayApprove(edit, user);
  const mayCancel = editorMayCancel(edit, user);

  return (
    <>
      {edit.status !== EDIT_STATUS_OPEN && edit.status !== EDIT_STATUS_APPLIED ? (
        <div className="edit-status">
          {getEditStatusName(edit)}
        </div>
      ) : null}

      <Vote edit={edit} index={index} summary />

      {!DBDefs.DB_READ_ONLY && (mayAddNote || mayApprove || mayCancel) ? (
        <div className="cancel-edit buttons">
          {mayAddNote ? (
            <a className="positive edit-note-toggle">{l('Add Note')}</a>
          ) : null}

          {mayApprove ? (
            <a
              className="positive"
              href={returnUri($c, `/edit/${edit.id}/approve`, 'returnto')}
            >
              {l('Approve edit')}
            </a>
          ) : null}

          {mayCancel ? (
            <a
              className="negative"
              href={returnUri($c, `/edit/${edit.id}/cancel`, 'returnto')}
            >
              {l('Cancel edit')}
            </a>
          ) : null}

          {edit.status === EDIT_STATUS_OPEN && DBDefs.DB_STAGING_TESTING_FEATURES ? (
            <>
              <a className="positive" href={`/test/accept-edit/${edit.id}`}>
                {l('Accept edit')}
              </a>
              <a className="negative" href={`/test/reject-edit/${edit.id}`}>
                {l('Reject edit')}
              </a>
            </>
          ) : null}
        </div>
      ) : null}
    </>
  );
};

export default withCatalystContext(EditSummary);
