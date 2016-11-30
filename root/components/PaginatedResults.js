/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import {ln} from '../static/scripts/common/i18n';
import Frag from './Frag';
import Paginator from './Paginator';
import type {Node as ReactNode} from 'react';

type Props = {|
  +children: ReactNode,
  +pager: PagerT,
  +query: string,
  +search?: boolean,
  +total?: boolean,
|};

const PaginatedResults = ({
  children,
  pager,
  query,
  search = false,
  total = false,
}: Props) => {
  const paginator = <Paginator pager={pager} />;
  return (
    <Frag>
      {paginator}
      {(search || total) ? (
        <p className="pageselector-results">
          {(total || !query) ? (
            ln('Found {n} result', 'Found {n} results',
              pager.total_entries,
              {n: Number(pager.total_entries).toLocaleString()})
          ) : (
            ln('Found {n} result for "{q}"', 'Found {n} results for "{q}"',
              pager.total_entries,
              {n: Number(pager.total_entries).toLocaleString(), q: query})
          )}
        </p>
      ) : null}
      {children}
      {paginator}
    </Frag>
  );
};

export default PaginatedResults;
