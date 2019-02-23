/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

const ReportNotAvailable = () => (
  <Layout fullWidth title={l('Error')}>
    <div id="content">
      <h1>{l('Error')}</h1>

      <p>{l('We are sorry, but data for this report is not available right now.')}</p>
    </div>
  </Layout>
);

export default ReportNotAvailable;
