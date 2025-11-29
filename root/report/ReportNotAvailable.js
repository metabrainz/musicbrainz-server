/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

component ReportNotAvailable() {
  return (
    <Layout fullWidth title={l_reports('Error')}>
      <div id="content">
        <h1>{l_reports('Error')}</h1>

        <p>
          {l_reports(`We are sorry, but data for this report is not available
                      right now.`)}
        </p>
      </div>
    </Layout>
  );
}

export default ReportNotAvailable;
