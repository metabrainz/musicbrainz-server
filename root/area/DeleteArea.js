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
import type {AreaDeleteFormT} from './types.js';

type Props = {
  +canDelete: boolean,
  +entity: AreaT,
  +form: AreaDeleteFormT,
  +isReleaseCountry: boolean,
};

const DeleteArea = ({
  canDelete,
  entity: area,
  form,
  isReleaseCountry,
}: Props): React$Element<typeof AreaLayout> => (
  <AreaLayout
    entity={area}
    fullWidth
    page="delete"
    title={l('Remove Area')}
  >
    <h2>{l('Remove Area')}</h2>

    {isReleaseCountry ? (
      <p>
        {l(`This area cannot be removed because it is one of the areas
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
        {l(`This area cannot be removed because it is still in use
            (in artists, labels, places, relationships or open edits).`)}
      </p>
    )}
  </AreaLayout>
);

export default DeleteArea;
