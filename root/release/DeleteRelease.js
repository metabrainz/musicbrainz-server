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

import ReleaseLayout from './ReleaseLayout.js';
import type {ReleaseDeleteFormT} from './types.js';

type Props = {
  +entity: ReleaseT,
  +form: ReleaseDeleteFormT,
};

const DeleteRelease = ({
  entity: release,
  form,
}: Props): React$Element<typeof ReleaseLayout> => (
  <ReleaseLayout
    entity={release}
    fullWidth
    page="delete"
    title={l('Remove Release')}
  >
    <h2>{l('Remove Release')}</h2>

    <EntityDeletionHelp entity={release} />

    <form method="post">
      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </form>

  </ReleaseLayout>
);

export default DeleteRelease;
