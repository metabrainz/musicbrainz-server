/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import AreaEditForm
  from '../static/scripts/area/components/AreaEditForm.js';

import AreaLayout from './AreaLayout.js';
import {type AreaFormT} from './types.js';

component EditArea(
  entity: AreaT,
  areaDescriptions: {+[id: string]: string},
  areaTypes: SelectOptionsT,
  form: AreaFormT,
) {
  return (
    <AreaLayout
      entity={entity}
      fullWidth
      page="edit"
      title={lp('Edit area', 'header')}
    >
        <AreaEditForm
          areaDescriptions={areaDescriptions}
          areaTypes={areaTypes}
          form={form}
        />
        {manifest('area/components/AreaEditForm', {async: true})}
        {manifest('relationship-editor', {async: true})}
    </AreaLayout>
  );
}

export default EditArea;
