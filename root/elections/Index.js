/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

import ElectionTable from './ElectionTable/index.js';

component Index(elections: $ReadOnlyArray<AutoEditorElectionT>) {
  return (
    <Layout fullWidth title={l('Auto-editor elections')}>
      <h1>{l('Auto-editor elections')}</h1>
      {elections.length
        ? <ElectionTable elections={elections} />
        : <p>{l('No elections found.')}</p>}
    </Layout>
  );
}

export default Index;
