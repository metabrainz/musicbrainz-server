/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import {type SearchResultT} from '../types';

type Props<T> = {
  +buildResult: (SearchResultT<T>, number) => React.Node,
  +columns: React.Node,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
};

const PaginatedSearchResults = <T>({
  buildResult,
  columns,
  pager,
  query,
  results,
}: Props<T>): React.Element<typeof PaginatedResults | 'p'> => {
  return results.length ? (
    <PaginatedResults pager={pager} query={query} search>
      <table className="tbl">
        <thead>
          <tr>
            {columns}
          </tr>
        </thead>
        <tbody>
          {results.map(buildResult)}
        </tbody>
      </table>
    </PaginatedResults>
  ) : <p>{l('No results found. Try refining your search query.')}</p>;
};

export default PaginatedSearchResults;
