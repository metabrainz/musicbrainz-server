/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import ReleaseList from '../components/list/ReleaseList';

type Props = {
  +$c: CatalystContextT,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<ReleaseT>,
};

const OtherLookupReleaseResults = ({
  $c,
  results,
}: Props): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Search Results')}>
    <h1>{l('Search Results')}</h1>
    {results.length ? (
      <ReleaseList
        $c={$c}
        releases={results}
        showLanguages
        showStatus
        showType
      />
    ) : (
      <p>{l('No results found.')}</p>
    )}
  </Layout>
);

export default OtherLookupReleaseResults;
