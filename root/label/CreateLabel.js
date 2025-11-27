/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import LabelEditForm
  from '../static/scripts/label/components/LabelEditForm.js';

import type {LabelFormT} from './types.js';

component CreateLabel(
  form: LabelFormT,
  labelDescriptions: {+[id: string]: string},
  labelTypes: SelectOptionsT,
) {
  return (
    <Layout fullWidth title={lp('Add label', 'header')}>
      <div id="content">
        <h1>{lp('Add label', 'header')}</h1>
        <LabelEditForm
          form={form}
          labelDescriptions={labelDescriptions}
          labelTypes={labelTypes}
        />
      </div>
      {manifest('label/components/LabelEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </Layout>
  );
}

export default CreateLabel;
