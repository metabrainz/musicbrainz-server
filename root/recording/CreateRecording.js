/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import RecordingEditForm
  from '../static/scripts/recording/components/RecordingEditForm.js';

import type {RecordingFormT} from './types.js';

component CreateRecording(form: RecordingFormT, usedByTracks: boolean) {
  return (
    <Layout fullWidth title={lp('Add recording', 'header')}>
      <div id="content">
        <h1>{lp('Add recording', 'header')}</h1>
        <RecordingEditForm form={form} usedByTracks={usedByTracks} />
      </div>
      {manifest('recording/components/RecordingEditForm', {async: 'async'})}
      {manifest('relationship-editor', {async: 'async'})}
    </Layout>
  );
}

export default CreateRecording;
