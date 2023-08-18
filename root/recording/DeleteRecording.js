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

import RecordingLayout from './RecordingLayout.js';
import type {RecordingDeleteFormT} from './types.js';

type Props = {
  +canDelete: boolean,
  +entity: RecordingWithArtistCreditT,
  +form: RecordingDeleteFormT,
  +isReleaseCountry: boolean,
};

const DeleteRecording = ({
  canDelete,
  entity: recording,
  form,
}: Props): React$Element<typeof RecordingLayout> => (
  <RecordingLayout
    entity={recording}
    fullWidth
    page="delete"
    title={l('Remove Recording')}
  >
    <h2>{l('Remove Recording')}</h2>

    {canDelete ? (
      <>
        <EntityDeletionHelp entity={recording}>
          <p>
            {exp.l(
              `Please make sure you’re not removing a legitimate
               {doc_standalone|standalone recording}.`,
              {doc_standalone: '/doc/Standalone_Recording'},
            )}
          </p>
        </EntityDeletionHelp>

        <form method="post">
          <EnterEditNote field={form.field.edit_note} />
          <EnterEdit form={form} />
        </form>
      </>
    ) : (
      <p>
        {l(`This recording cannot be removed
            because it is still used on releases.`)}
      </p>
    )}
  </RecordingLayout>
);

export default DeleteRecording;
