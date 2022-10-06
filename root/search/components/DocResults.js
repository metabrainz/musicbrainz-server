/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout/index.js';
import {GOOGLE_CUSTOM_SEARCH} from '../../static/scripts/common/DBDefs.mjs';

const DocResults = (): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Documentation Search')}>
    <div className="wikicontent" id="content">
      <h1>{l('Documentation Search')}</h1>
      <script
        async
        src={'https://cse.google.com/cse.js?cx=' + encodeURIComponent(GOOGLE_CUSTOM_SEARCH)}
        type="text/javascript"
      />
      {React.createElement(
        'gcse:search',
        {enablehistory: 'true', queryparametername: 'query'},
      )}
    </div>
  </Layout>
);

export default DocResults;
