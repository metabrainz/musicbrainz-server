/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EditLink from '../../static/scripts/common/components/EditLink.js';
import {getEditHeaderClass} from '../../utility/edit.js';

import EditNote from './EditNote.js';

type PropsT = {
  +edit: GenericEditWithIdT,
  +editNote: EditNoteT,
  +showEditControls?: boolean,
};

const EditNoteListEntry = ({
  edit,
  editNote,
  showEditControls,
}: PropsT): React$Element<'div'> => {
  const editTitle = texp.l(
    'Edit #{id} - {name}',
    {id: edit.id, name: l(edit.edit_name)},
  );

  return (
    <div className="edit-list">
      <div className={getEditHeaderClass(edit)}>
        <h2>
          <EditLink content={editTitle} edit={edit} />
        </h2>
      </div>
      <EditNote
        edit={edit}
        editNote={editNote}
        index={0}
        showEditControls={showEditControls}
      />
    </div>
  );
};

export default EditNoteListEntry;
