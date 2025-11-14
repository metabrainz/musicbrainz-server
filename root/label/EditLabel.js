/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import LabelEditForm
  from '../static/scripts/label/components/LabelEditForm.js';

import LabelLayout from './LabelLayout.js';
import type {LabelFormT} from './types.js';

component EditLabel(
  entity: LabelT,
  form: LabelFormT,
  labelDescriptions: {+[id: string]: string},
  labelTypes: SelectOptionsT,
) {
  return (
    <LabelLayout
      entity={entity}
      fullWidth
      page="edit"
      title={lp('Edit label', 'header')}
    >
        <LabelEditForm
          form={form}
          labelDescriptions={labelDescriptions}
          labelTypes={labelTypes}
        />
      {manifest('label/components/LabelEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </LabelLayout>
  );
}

export default EditLabel;
