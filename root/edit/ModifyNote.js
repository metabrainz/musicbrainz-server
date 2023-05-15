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
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';

import EditNoteHelp from './components/EditNoteHelp.js';
import EditNoteListEntry from './components/EditNoteListEntry.js';

type ModifyEditNoteFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +reason: ReadOnlyFieldT<string>,
  +submit: ReadOnlyFieldT<string>,
  +text: ReadOnlyFieldT<string>,
}>;

type Props = {
  +edit: GenericEditWithIdT,
  +editNote: EditNoteT,
  +form: ModifyEditNoteFormT,
};

const ModifyNote = ({
  edit,
  editNote,
  form,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Modify edit note')}>
    <h1>{l('Modify edit note')}</h1>
    <p>
      {l('You are modifying the following edit note:')}
    </p>
    <div className="edit-notes">
      <EditNoteListEntry
        edit={edit}
        editNote={editNote}
        showEditControls={false}
      />
    </div>
    <form method="post">
      <FormRowTextArea
        cols={50}
        field={form.field.text}
        label={addColonText(l('New edit note'))}
        rows={10}
      />
      <EditNoteHelp>
        <p>
          {l(
            `Keep in mind modification of edit notes is mostly intended
             to correct small mistakes. Editors won’t be notified
             of your changes via email.`,
          )}
        </p>
      </EditNoteHelp>
      <p>
        {l(`Providing a reason is optional but can make things more clear
            for editors checking this edit in the future. Keep in mind
            the reason will be displayed to other editors.`)}
      </p>
      <FormRowText
        field={form.field.reason}
        label={addColonText(l('Reason'))}
        size={50}
        uncontrolled
      />
      <span className="buttons">
        <button
          name="edit-note-modify.submit"
          type="submit"
          value="1"
        >
          {l('Submit')}
        </button>
        <button
          className="negative"
          name="edit-note-modify.cancel"
          type="submit"
          value="1"
        >
          {l('Cancel')}
        </button>
      </span>
    </form>
  </Layout>
);

export default ModifyNote;
