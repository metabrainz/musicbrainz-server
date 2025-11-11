/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import InstrumentEditForm
  from '../static/scripts/instrument/components/InstrumentEditForm.js';

import InstrumentLayout from './InstrumentLayout.js';
import type {InstrumentFormT} from './types.js';

component EditInstrument(
  entity: InstrumentT,
  form: InstrumentFormT,
  instrumentTypes: SelectOptionsT,
) {
  return (
    <InstrumentLayout
      entity={entity}
      fullWidth
      page="edit"
      title={lp('Edit instrument', 'header')}
    >
      <InstrumentEditForm form={form} instrumentTypes={instrumentTypes} />
      {manifest('instrument/components/InstrumentEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </InstrumentLayout>
  );
}

export default EditInstrument;
