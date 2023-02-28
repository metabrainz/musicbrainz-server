/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../context.mjs';
import {getEditStatusClass} from '../../utility/edit.js';
import EditHeader from '../components/EditHeader.js';
import EditNotes from '../components/EditNotes.js';
import EditSummary from '../components/EditSummary.js';
import getEditDetailsElement from '../utility/getEditDetailsElement.js';

type Props = {
  +edit: $ReadOnly<{...EditT, +id: number}>,
  +index: number,
  +voter?: UnsanitizedEditorT,
};

const ListEdit = ({
  edit,
  index,
  voter,
}: Props): React.Element<'div'> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const editStatusClass = getEditStatusClass(edit);
  const detailsElement = getEditDetailsElement(edit);

  return (
    <div className="edit-list">
      <EditHeader edit={edit} isSummary voter={voter} />

      <input
        name={`enter-vote.vote.${index}.edit_id`}
        type="hidden"
        value={edit.id}
      />

      <div className={`edit-actions c ${editStatusClass}`}>
        <EditSummary edit={edit} index={index} />
      </div>

      <div className="edit-details">
        {edit.data
          ? detailsElement
          : <p>{l('An error occurred while loading this edit.')}</p>}
      </div>

      {$c.user ? (
        <>
          <EditNotes edit={edit} hide index={index} verbose={false} />
          <div className="seperator" />
        </>
      ) : null}
    </div>
  );
};

export default ListEdit;
