/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';

import ElectionTable from './ElectionTable/index.js';

type Props = {
  +$c: CatalystContextT,
  +elections: $ReadOnlyArray<AutoEditorElectionT>,
};

const Index = ({$c, elections}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Auto-editor elections')}>
    <h1>{l('Auto-editor elections')}</h1>
    {elections.length
      ? <ElectionTable $c={$c} elections={elections} />
      : <p>{l('No elections found.')}</p>}
  </Layout>
);

export default Index;
