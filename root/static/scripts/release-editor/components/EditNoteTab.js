/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {MakeVotable} from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';

type EditPreviewT = {
  +editHash: string,
  +editName: string,
  +preview: string,
  ...
};

type ReleaseEditorFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  ...
}>;

component EditNoteTab(
  editPreviews?: $ReadOnlyArray<EditPreviewT> = [],
  editsExist?: boolean = false,
  errorsExist?: boolean = false,
  form?: ReleaseEditorFormT | null = null,
  invalidEditNote?: boolean = false,
  loadingEditPreviews?: boolean = false,
  missingEditNote?: boolean = true,
  onEditNoteChange?: ((
    SyntheticKeyboardEvent<HTMLTextAreaElement>,
  ) => void) | null = null,
  onMakeVotableChange?: ((
    SyntheticEvent<HTMLInputElement>,
  ) => void) | null = null,
  submissionError?: string = '',
  submissionInProgress?: boolean = false,
) {
  return (
    <div className="form" id="form">
      {errorsExist ? (
        <div className="warning">
          <p>
            {l(`Some errors were detected in the data you’ve entered.
                Click on the highlighted tabs and correct any visible
                errors.`)}
          </p>
        </div>
      ) : null}

      {(editsExist || errorsExist || submissionInProgress) ? null : (
        <div className="warning">
          <p>{l('You haven’t made any changes!')}</p>
        </div>
      )}

      {loadingEditPreviews ? (
        <div className="loading-message">
          {l('Loading edit previews...')}
        </div>
      ) : null}

      {editPreviews.map((editPreview) => (
        <div className="edit-list" key={editPreview.editHash}>
          <h2>{editPreview.editName}</h2>
          <div
            className="edit-details"
            dangerouslySetInnerHTML={{__html: editPreview.preview}}
          />
        </div>
      ))}

      <div className="half-width">
        {(form && onEditNoteChange && onMakeVotableChange) ? (
          <>
            <EnterEditNote
              controlled
              field={form.field.edit_note}
              hideHelp={false}
              onChange={onEditNoteChange}
            >
              <p
                className="error field-error"
                data-visible={String(missingEditNote)}
                style={{display: missingEditNote ? 'block' : 'none'}}
              >
                {l('You must provide an edit note when adding a release.')}
              </p>
              <p
                className="error field-error"
                data-visible={String(invalidEditNote)}
                id="useless-edit-note-error"
                style={{display: invalidEditNote ? 'block' : 'none'}}
              >
                {l(`Your edit note seems to have no actual content.
                    Please provide a note that will be helpful to
                    your fellow editors!`)}
              </p>
            </EnterEditNote>
            <MakeVotable
              disabled={false}
              field={form.field.make_votable}
              inputProps={{
                checked: form.field.make_votable.value,
                onChange: onMakeVotableChange,
              }}
            />
          </>
        ) : null}

        {submissionInProgress ? (
          <div className="loading-message">
            {l('Submitting edits...')}
          </div>
        ) : null}

        {submissionError ? (
          <p
            className="error"
            dangerouslySetInnerHTML={{__html: submissionError}}
          />
        ) : null}
      </div>
    </div>
  );
}

export default EditNoteTab;
