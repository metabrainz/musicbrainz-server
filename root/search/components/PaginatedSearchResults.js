/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Element as ReactElement} from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import {l} from '../../static/scripts/common/i18n';

type Props<T> = {|
  +buildResult: (SearchResultT<T>, number) => ReactElement<'tr'>,
  +columns: $ReadOnlyArray<string>,
  +pager: PagerT,
  +query: string,
  +results: $ReadOnlyArray<SearchResultT<T>>,
|};

const PaginatedSearchResults = <T>({
  buildResult,
  columns,
  pager,
  query,
  results,
}: Props<T>) => results.length ? (
  <PaginatedResults pager={pager} query={query} search>
    <table className="tbl">
      <thead>
        <tr>
          {columns.map((name, index) => <th key={index}>{name}</th>)}
        </tr>
      </thead>
      <tbody>
        {results.map(buildResult)}
      </tbody>
    </table>
  </PaginatedResults>
) : <p>{l('No results found. Try refining your search query.')}</p>;

export default PaginatedSearchResults;
