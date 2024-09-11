/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import RecordingEditForm
  from '../static/scripts/recording/components/RecordingEditForm.js';

import RecordingLayout from './RecordingLayout.js';
import type {RecordingFormT} from './types.js';

component EditRecording(
  entity: RecordingT,
  form: RecordingFormT,
  usedByTracks: boolean,
) {
  return (
    <RecordingLayout
      entity={entity}
      fullWidth
      page="edit"
      title={lp('Edit recording', 'header')}
    >
      <RecordingEditForm form={form} usedByTracks={usedByTracks} />
      {manifest('recording/components/RecordingEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
      {manifest('recording/edit', {async: true})}
    </RecordingLayout>
  );
}

export default EditRecording;
