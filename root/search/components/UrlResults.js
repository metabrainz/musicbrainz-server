/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import Table from '../../components/Table.js';
import {defineLinkColumn} from '../../utility/tableColumns.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import ResultsLayout from './ResultsLayout.js';

const UrlResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<UrlT>):
React.Element<typeof ResultsLayout> => {
  const columns = React.useMemo(
    () => {
      const nameColumn = defineLinkColumn<SearchResultT<UrlT>>({
        columnName: 'url',
        getContent: result => result.entity?.name ?? '',
        getHref: result => result.entity?.name ?? '',
        title: l('URL'),
      });
      const urlEntityColumn = defineLinkColumn<SearchResultT<UrlT>>({
        columnName: 'url_entity',
        getContent: result => result.entity?.gid ?? '',
        getHref: result => result.entity?.gid
          ? '/url/' + result.entity.gid
          : '',
        title: l('URL Entity'),
      });

      return [
        nameColumn,
        urlEntityColumn,
      ];
    },
    [],
  );

  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      {results.length ? (
        <PaginatedResults pager={pager} query={query}>
          <Table columns={columns} data={results} />
        </PaginatedResults>
      ) : (
        <p>
          {l('No results found. Try refining your search query.')}
        </p>
      )}
    </ResultsLayout>
  );
};

export default UrlResults;
