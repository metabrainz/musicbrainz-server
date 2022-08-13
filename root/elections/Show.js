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

import ElectionDetails from './ElectionDetails.js';
import ElectionVotes from './ElectionVotes.js';
import ElectionVoting from './ElectionVoting.js';

type Props = {
  +election: AutoEditorElectionT,
};

const Show = ({election}: Props): React.Element<typeof Layout> | null => {
  if (!election) {
    return null;
  }
  const title = texp.l('Auto-editor election #{no}', {no: election.id});
  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>
      <p>
        <a href="/elections">{l('Back to elections')}</a>
      </p>
      <ElectionDetails election={election} />
      <h2>{l('Voting')}</h2>
      <ElectionVoting election={election} />
      <h2>{l('Votes cast')}</h2>
      <ElectionVotes election={election} />
    </Layout>
  );
};

export default Show;
