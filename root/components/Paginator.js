/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import mapRange from '../static/scripts/common/utility/mapRange.js';
import uriWith from '../utility/uriWith.js';

type PageQueryParam = 'apps_page' | 'page' | 'tokens_page';
type PageQueryObject = {[pageVar: PageQueryParam]: number, ...};

type Props = {
  +guessSearch?: boolean,
  +hash?: string,
  +pager: PagerT,
  +pageVar?: PageQueryParam,
};

function uriPage(
  uri: string,
  pageVar: PageQueryParam,
  page: number,
  hash: ?string,
) {
  /*
   * See "Flow errors on unions in computed properties" here:
   * https://medium.com/flow-type/spreads-common-errors-fixes-9701012e9d58
   */
  const params: PageQueryObject = {};
  params[pageVar] = page;
  return uriWith(uri, params) +
    (nonEmpty(hash) ? '#' + hash : '');
}

const Paginator = ({
  guessSearch = false,
  hash,
  pager,
  pageVar = 'page',
}: Props): React$Element<'nav'> | null => {
  const $c = React.useContext(SanitizedCatalystContext);

  const lastPage = pager.last_page;
  if (lastPage <= 1) {
    return null;
  }

  const firstPage = pager.first_page;
  const previousPage = pager.previous_page;
  const nextPage = pager.next_page;

  const start = (pager.current_page - 4) > 0
    ? (pager.current_page - 4) : 1;

  const end = (pager.current_page + 4) < lastPage
    ? (pager.current_page + 4) : lastPage;

  const reqUri = $c.req.uri;

  return (
    <nav>
      <ul className="pagination">
        {previousPage == null ? (
          <li key="no-previous">
            <span>{l('Previous')}</span>
          </li>
        ) : (
          <li key="previous">
            <a href={uriPage(reqUri, pageVar, previousPage, hash)}>
              {l('Previous')}
            </a>
          </li>
        )}

        <li className="separator" key="separate-previous" />

        {start > firstPage ? (
          <li key="first">
            <a href={uriPage(reqUri, pageVar, firstPage, hash)}>
              {firstPage}
            </a>
          </li>
        ) : null}

        {start > (firstPage + 1) ? (
          <li key="after-first">
            <span>{l('…')}</span>
          </li>
        ) : null}

        {mapRange(start, end, (page) => (
          (pager.current_page === page) ? (
            <li key={'number-' + page}>
              <a
                className="sel"
                href={uriPage(reqUri, pageVar, page, hash)}
              >
                <strong>{page}</strong>
              </a>
            </li>
          ) : (
            <li key={'number-' + page}>
              <a href={uriPage(reqUri, pageVar, page, hash)}>
                {page}
              </a>
            </li>
          )
        ))}

        {end < (lastPage - 1) ? (
          <li key="before-last">
            <span>{l('…')}</span>
          </li>
        ) : null}

        {end < lastPage ? (
          <li key="last">
            <a href={uriPage(reqUri, pageVar, lastPage, hash)}>
              {lastPage}
            </a>
          </li>
        ) : null}

        {guessSearch ? (
          <li key="guess">
            <span>{l('…')}</span>
          </li>
        ) : null}

        <li className="separator" key="separate-next">
          {nextPage == null ? (
            <li key="no-next">
              <span>{l('Next')}</span>
            </li>
          ) : (
            <li key="next">
              <a href={uriPage(reqUri, pageVar, nextPage, hash)}>
                {l('Next')}
              </a>
            </li>
          )}
        </li>
      </ul>
    </nav>
  );
};

export default Paginator;
