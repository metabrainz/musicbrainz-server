/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityDeletionHelp from '../components/EntityDeletionHelp.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import InstrumentLayout from './InstrumentLayout.js';

type InstrumentDeleteFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
}>;

component DeleteInstrument(
  canDelete: boolean,
  entity as instrument: InstrumentT,
  form: InstrumentDeleteFormT,
) {
  return (
    <InstrumentLayout
      entity={instrument}
      fullWidth
      page="delete"
      title="Remove instrument"
    >
      <h2>{'Remove instrument'}</h2>

      {canDelete ? (
        <>
          <EntityDeletionHelp entity={instrument} />

          <form method="post">
            <EnterEditNote field={form.field.edit_note} />
            <EnterEdit form={form} />
          </form>
        </>
      ) : (
        <p>
          {l_admin(`This instrument cannot be removed
                    because there are still relationships attributed to it.`)}
        </p>
      )}
    </InstrumentLayout>
  );
}

export default DeleteInstrument;
