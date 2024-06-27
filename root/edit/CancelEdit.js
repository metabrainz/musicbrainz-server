/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import getEditDetailsElement from './utility/getEditDetailsElement.js';

component CancelEdit(
  edit: $ReadOnly<{...EditT, +id: number}>,
  form: ConfirmFormT,
) {
  const detailsElement = getEditDetailsElement(edit);

  return (
    <Layout fullWidth title={lp('Cancel edit', 'header')}>
      <h2>{lp('Cancel edit', 'header')}</h2>
      <p>
        {texp.l(
          'Are you sure you wish to cancel edit #{n}? This cannot be undone!',
          {n: edit.id},
        )}
      </p>

      <div className="edit-list">
        <h2>{lp(edit.edit_name, edit.edit_type_name_context)}</h2>
        <div className="edit-details">
          {edit.data
            ? detailsElement
            : <p>{l('An error occurred while loading this edit.')}</p>}
        </div>
      </div>

      <form method="post">
        <p>
          {l(`You may enter an edit note while cancelling this edit.
              This can be useful to point editors to another edit.`)}
        </p>

        <EnterEditNote field={form.field.edit_note} hideHelp />

        <div className="row no-label buttons">
          <button className="submit positive" type="submit">
            {lp('Cancel edit', 'interactive')}
          </button>
        </div>
      </form>
    </Layout>
  );
}

export default CancelEdit;
