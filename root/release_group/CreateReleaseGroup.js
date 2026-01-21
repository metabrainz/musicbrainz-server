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
import ReleaseGroupEditForm
  from '../static/scripts/release-group/components/ReleaseGroupEditForm.js';

import type {ReleaseGroupFormT} from './types.js';

component CreateReleaseGroup(
  form: ReleaseGroupFormT,
  primaryTypeDescriptions: {+[id: string]: string},
  primaryTypes: SelectOptionsT,
  secondaryTypeDescriptions: {+[id: string]: string},
  secondaryTypes: SelectOptionsT,
) {
  return (
    <Layout fullWidth title={lp('Add release group', 'header')}>
      <div id="content">
        <h1>{lp('Add release group', 'header')}</h1>
        <ReleaseGroupEditForm
          form={form}
          primaryTypeDescriptions={primaryTypeDescriptions}
          primaryTypes={primaryTypes}
          secondaryTypeDescriptions={secondaryTypeDescriptions}
          secondaryTypes={secondaryTypes}
        />
      </div>
      {manifest(
        'release-group/components/ReleaseGroupEditForm',
        {async: true},
      )}
      {manifest('relationship-editor', {async: true})}
    </Layout>
  );
}

export default CreateReleaseGroup;
