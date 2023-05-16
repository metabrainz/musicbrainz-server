/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';

import EditNoteListEntry from './components/EditNoteListEntry.js';

type DeleteNoteFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +reason: ReadOnlyFieldT<string>,
  +submit: ReadOnlyFieldT<string>,
}>;

type Props = {
  +edit: GenericEditWithIdT,
  +editNote: EditNoteT,
  +form: DeleteNoteFormT,
};

const DeleteNote = ({
  edit,
  editNote,
  form,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Remove edit note')}>
    <h1>{l('Remove edit note')}</h1>
    <p>
      {l('Are you sure you want to remove the following edit note?')}
    </p>
    <div className="edit-notes">
      <EditNoteListEntry
        edit={edit}
        editNote={editNote}
        showEditControls={false}
      />
    </div>
    <form method="post">
      <p>
        {l(
          `Providing a reason for the removal is recommended if you feel
           it will make things clearer for other editors checking
           the editing history in the future. Otherwise it can be omitted.`,
        )}
      </p>
      <FormRowText
        field={form.field.reason}
        label={addColonText(l('Reason'))}
        size={50}
        uncontrolled
      />
      <span className="buttons">
        <button
          name="edit-note-delete.submit"
          type="submit"
          value="1"
        >
          {l('Yes, I am sure')}
        </button>
        <button
          className="negative"
          name="edit-note-delete.cancel"
          type="submit"
          value="1"
        >
          {l('Cancel')}
        </button>
      </span>
    </form>
  </Layout>
);

export default DeleteNote;
