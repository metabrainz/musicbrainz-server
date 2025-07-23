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
import PossibleSpammersList
  from '../static/scripts/admin/components/PossibleSpammersList.js';

component PossibleSpammers() {
  return (
    <Layout fullWidth title="Possible spammers">
      <div id="content">
        <h1>{'Possible spammers'}</h1>
        <p>
          {'This page shows beginner editors (sorted by newest first) ' +
           'having a website or biography.'}
        </p>
        <PossibleSpammersList />
        {manifest('admin/components/PossibleSpammersList', {async: true})}
      </div>
    </Layout>
  );
}

export default PossibleSpammers;
