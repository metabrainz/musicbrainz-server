/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import bracketed from '../static/scripts/common/utility/bracketed.js';
import formatUserDate from '../utility/formatUserDate.js';

type EditNoteHistoryTableProps = {
  +changes: $ReadOnlyArray<EditNoteChangeT>,
};

type EditNoteHistoryProps = {
  +changes: $ReadOnlyArray<EditNoteChangeT>,
  +noteUrl: string,
  +pager: PagerT,
};

const EditNoteHistoryTable = ({
  changes,
}: EditNoteHistoryTableProps): React$Element<'table'> => {
  const $c = React.useContext(SanitizedCatalystContext);

  return (
    <table className="tbl">
      <thead>
        <tr>
          <th>{'Editor'}</th>
          <th>{'Status'}</th>
          <th>{'Date'}</th>
          <th>{'Version History'}</th>
        </tr>
      </thead>
      <tbody>
        {changes.map(change => {
          const editor = linkedEntities.editor[change.change_editor_id];
          return (
            <tr key={change.id}>
              <td>
                <EditorLink editor={editor} />
              </td>
              <td>{change.status}</td>
              <td>
                {formatUserDate($c, change.change_time)}
              </td>
              <td>
                <a
                  href={
                    `/edit-note/${change.edit_note_id}/change/${change.id}`
                  }
                >
                  {'View this change'}
                </a>
                {' '}
                {bracketed(
                  change.reason ||
                  expand2react('<em>no reason specified</em>'),
                )}
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
};

const EditNoteHistory = ({
  changes,
  noteUrl,
  pager,
}: EditNoteHistoryProps): React$MixedElement => (
  <Layout fullWidth title="Edit note change history">
    <h2>{'Edit note change history'}</h2>
    {changes.length ? (
      <PaginatedResults pager={pager}>
        <EditNoteHistoryTable changes={changes} />
      </PaginatedResults>
    ) : (
      <p>
        {'This edit note has no change history.'}
      </p>
    )}
    <p className="small">
      <a href={noteUrl}>
        {'Go to the edit note'}
      </a>
    </p>
  </Layout>
);

export default EditNoteHistory;
