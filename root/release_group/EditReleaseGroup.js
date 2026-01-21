/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import ReleaseGroupEditForm
  from '../static/scripts/release-group/components/ReleaseGroupEditForm.js';

import ReleaseGroupLayout from './ReleaseGroupLayout.js';
import type {ReleaseGroupFormT} from './types.js';

component EditReleaseGroup(
  entity: ReleaseGroupT,
  form: ReleaseGroupFormT,
  primaryTypeDescriptions: {+[id: string]: string},
  primaryTypes: SelectOptionsT,
  secondaryTypeDescriptions: {+[id: string]: string},
  secondaryTypes: SelectOptionsT,
) {
  return (
    <ReleaseGroupLayout
      entity={entity}
      fullWidth
      // Useless for fullWidth display
      hasReleases={false}
      page="edit"
      title={lp('Edit release group', 'header')}
    >
      <ReleaseGroupEditForm
        form={form}
        primaryTypeDescriptions={primaryTypeDescriptions}
        primaryTypes={primaryTypes}
        secondaryTypeDescriptions={secondaryTypeDescriptions}
        secondaryTypes={secondaryTypes}
      />
      {manifest(
        'release-group/components/ReleaseGroupEditForm',
        {async: true},
      )}
      {manifest('relationship-editor', {async: true})}
    </ReleaseGroupLayout>
  );
}

export default EditReleaseGroup;
