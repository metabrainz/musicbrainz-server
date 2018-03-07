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
import ElectionDetails from './ElectionDetails';
import ElectionVotes from './ElectionVotes';
import ElectionVoting from './ElectionVoting';

const Show = ({election}: {+election: AutoEditorElectionT}) => {
  const user = $c.user;
  const title = l('Auto-editor election #{no}', {no: election.id});
  return (
    <Layout fullWidth title={title}>
      <h1>{title}</h1>
      <p>
        <a href="/elections">{l('Back to elections')}</a>
      </p>
      <ElectionDetails election={election} user={user} />
      <h2>{l('Voting')}</h2>
      <ElectionVoting election={election} user={user} />
      <h2>{l('Votes cast')}</h2>
      <ElectionVotes election={election} user={user} />
    </Layout>
  );
};

export default Show;
