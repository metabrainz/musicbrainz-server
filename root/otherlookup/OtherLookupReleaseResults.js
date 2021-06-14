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
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<ReleaseT>,
};

const OtherLookupReleaseResults = ({
  results,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Search Results')}>
    <h1>{l('Search Results')}</h1>
    {results.length ? (
      <ReleaseList
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
