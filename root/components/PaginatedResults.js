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

type Props = {
  +children: React.Node,
  +guessSearch?: boolean,
  +pager: PagerT,
  +pageVar?: 'apps_page' | 'page' | 'tokens_page',
  +query?: string,
  +search?: boolean,
  +total?: boolean,
};

const PaginatedResults = ({
  children,
  guessSearch = false,
  pager,
  pageVar,
  query,
  search = false,
  total = false,
}: Props): React$Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);
  const paginator = (
    <Paginator
      guessSearch={guessSearch}
      pageVar={pageVar}
      pager={pager}
    />
  );

  return (
    <>
      {paginator}
      {(search || total) ? (
        <p className="pageselector-results">
          {(total || empty(query)) ? (
            texp.ln(
              'Found {n} result', 'Found {n} results',
              pager.total_entries,
              {n: formatCount($c, pager.total_entries)},
            )
          ) : (
            texp.ln(
              'Found {n} result for "{q}"',
              'Found {n} results for "{q}"',
              pager.total_entries,
              {
                n: formatCount($c, pager.total_entries),
                q: query,
              },
            )
          )}
        </p>
      ) : null}
      {children}
      {paginator}
    </>
  );
};

export default PaginatedResults;
