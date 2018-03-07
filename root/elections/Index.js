/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import Layout from '../layout';
import {l} from '../static/scripts/common/i18n';
import ElectionTable from './ElectionTable';

const Index = ({elections}: {+elections: $ReadOnlyArray<AutoEditorElectionT>}) => (
  <Layout fullWidth title={l('Auto-editor elections')}>
    <h1>{l('Auto-editor elections')}</h1>
    {elections.length
      ? <ElectionTable elections={elections} />
      : <p>{l('No elections found.')}</p>}
  </Layout>
);

export default Index;
