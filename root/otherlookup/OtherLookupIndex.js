/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

import OtherLookupForm from './OtherLookupForm.js';
import type {OtherLookupFormT} from './types.js';

component OtherLookupIndex(form: OtherLookupFormT) {
  return (
    <Layout fullWidth title={l('Other lookups')}>
      <div className="content">
        <h1>{l('Other lookups')}</h1>
        <OtherLookupForm form={form} />
      </div>
    </Layout>
  );
}

export default OtherLookupIndex;
