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
import AreaEditForm
  from '../static/scripts/area/components/AreaEditForm.js';

import type {AreaFormT} from './types.js';

component CreateArea(
  areaDescriptions: {+[id: string]: string},
  areaTypes: SelectOptionsT,
  form: AreaFormT,
) {
  return (
    <Layout fullWidth title={lp('Add area', 'header')}>
      <div id="content">
        <h1>{lp('Add area', 'header')}</h1>
        <AreaEditForm
          areaDescriptions={areaDescriptions}
          areaTypes={areaTypes}
          form={form}
        />
      </div>
      {manifest('area/components/AreaEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </Layout>
  );
}

export default CreateArea;
