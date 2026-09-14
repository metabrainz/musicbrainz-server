/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {formatCount} from '../statistics/utilities.js';

import Paginator from './Paginator.js';

component PaginatedResults(
  children: React.Node,
  guessSearch: boolean = false,
  pager: PagerT,
  pageVar?: 'apps_page' | 'page' | 'tokens_page',
  query?: string,
  uncappedTotalHits?: number = 0,
  search: boolean = false,
  total: boolean = false,
) {
  const $c = React.useContext(CatalystContext);
  const paginator = (
    <Paginator
      guessSearch={guessSearch}
      pager={pager}
      pageVar={pageVar}
    />
  );
  const isLastCappedPage =
    uncappedTotalHits > pager.total_entries &&
    pager.current_page === pager.last_page;
  const totalCount = Math.max(pager.total_entries, uncappedTotalHits);

  return (
    <>
      {paginator}
      {(search || total) ? (
        <p className="pageselector-results">
          {(total || empty(query)) ? (
            texp.ln(
              'Found {n} result',
              'Found {n} results',
              totalCount,
              {n: formatCount($c, totalCount)},
            )
          ) : (
            texp.ln(
              'Found {n} result for "{q}"',
              'Found {n} results for "{q}"',
              totalCount,
              {
                n: formatCount($c, totalCount),
                q: query,
              },
            )
          )}
        </p>
      ) : null}
      {isLastCappedPage ? (
        <p>
          {texp.l(
            `Only the first {n} results can be returned.
             If you cannot find what you are looking for,
             please try a more precise search.`,
            {n: pager.total_entries},
          )}
        </p>
      ) : null}
      {children}
      {paginator}
    </>
  );
}

export default PaginatedResults;
