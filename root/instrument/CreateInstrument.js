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
import InstrumentEditForm
  from '../static/scripts/instrument/components/InstrumentEditForm.js';

import type {InstrumentFormT} from './types.js';

component CreateInstrument(
  form: InstrumentFormT,
  instrumentTypes: SelectOptionsT,
) {
  return (
    <Layout fullWidth title={lp('Add instrument', 'header')}>
      <div id="content">
        <h1>{lp('Add instrument', 'header')}</h1>
        <InstrumentEditForm form={form} instrumentTypes={instrumentTypes} />
      </div>
      {manifest('instrument/components/InstrumentEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </Layout>
  );
}

export default CreateInstrument;
