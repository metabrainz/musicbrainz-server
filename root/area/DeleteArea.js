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

import AreaLayout from './AreaLayout.js';

type AreaDeleteFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
}>;

component DeleteArea(
  canDelete: boolean,
  entity as area: AreaT,
  form: AreaDeleteFormT,
  isReleaseCountry: boolean,
) {
  return (
    <AreaLayout
      entity={area}
      fullWidth
      page="delete"
      title="Remove area"
    >
      <h2>{'Remove area'}</h2>

      {isReleaseCountry ? (
        <p>
          {l_admin(`This area cannot be removed because it is one of the areas
                    that can be used as a release country.`)}
        </p>
      ) : canDelete ? (
        <>
          <EntityDeletionHelp entity={area} />

          <form method="post">
            <EnterEditNote field={form.field.edit_note} />
            <EnterEdit form={form} />
          </form>
        </>
      ) : (
        <p>
          {l_admin(`This area cannot be removed because it is still in use (in
                    artists, labels, places, relationships or open edits).`)}
        </p>
      )}
    </AreaLayout>
  );
}

export default DeleteArea;
