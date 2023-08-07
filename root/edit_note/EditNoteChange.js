/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import nonEmpty from '../static/scripts/common/utility/nonEmpty.js';
import DiffSide from '../static/scripts/edit/components/edit/DiffSide.js';
import {DELETE, INSERT} from '../static/scripts/edit/utility/editDiff.js';

type EditNoteChangeProps = {
  +change: EditNoteChangeT,
  +noteUrl: string,
};

const EditNoteChange = ({
  change,
  noteUrl,
}: EditNoteChangeProps): React$MixedElement => {
  const editor = linkedEntities.editor[change.change_editor_id];

  return (
    <Layout fullWidth title="Edit note change">
      <h2>{'Edit note change'}</h2>
      <h3>{'Changing editor'}</h3>
      <EditorLink editor={editor} />
      <h3>{'Type'}</h3>
      <p>{change.status}</p>
      <div className="note-diff">
        <h3>{'Old note'}</h3>
        <p>
          <DiffSide
            filter={DELETE}
            newText={change.new_note ?? ''}
            oldText={change.old_note ?? ''}
            split="\s+"
          />
        </p>
        <h3>{'New note'}</h3>
        {change.status === 'deleted' ? (
          <p className="small">{'This note was deleted.'}</p>
        ) : (
          <p>
            <DiffSide
              filter={INSERT}
              newText={change.new_note ?? ''}
              oldText={change.old_note ?? ''}
              split="\s+"
            />
          </p>
        )}
      </div>
      <h3>{'Change reason'}</h3>
      {nonEmpty(change.reason)
        ? <p>{change.reason}</p>
        : <p className="small">{'No reason entered.'}</p>}
      <p className="small">
        <a href={`/edit-note/${change.edit_note_id}/changes`}>
          {'See all changes for this edit note'}
        </a>
        {' / '}
        <a href={noteUrl}>
          {'Go to the edit note'}
        </a>
      </p>
    </Layout>
  );
};

export default EditNoteChange;
