/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {range} from 'lodash';
import React from 'react';

import {withCatalystContext} from '../context';
import uriWith from '../utility/uriWith';

type Props = {
  +$c: CatalystContextT,
  +guessSearch?: boolean,
  +pager: PagerT,
  +pageVar?: string,
};

const Paginator = ({
  $c,
  guessSearch = false,
  pager,
  pageVar = 'page',
}: Props) => {
  if (pager.last_page <= 1) {
    return null;
  }

  const start = (pager.current_page - 4) > 0
    ? (pager.current_page - 4) : 1;

  const end = (pager.current_page + 4) < pager.last_page
    ? (pager.current_page + 4) : pager.last_page;

  const reqUri = $c.req.uri;

  return (
    <nav>
      <ul className="pagination">
        {pager.previous_page ? (
          <li key="previous">
            <a href={uriWith(reqUri, {page: pager.previous_page})}>
              {l('Previous')}
            </a>
          </li>
        ) : (
          <li key="no-previous">
            <span>{l('Previous')}</span>
          </li>
        )}

        <li className="separator" key="separate-previous" />

        {start > pager.first_page ? (
          <li key="first">
            <a href={uriWith(reqUri, {page: pager.first_page})}>
              {pager.first_page}
            </a>
          </li>
        ) : null}

        {start > (pager.first_page + 1) ? (
          <li key="after-first">
            <span>{l('…')}</span>
          </li>
        ) : null}

        {range(start, end + 1).map(page => (
          (pager.current_page === page) ? (
            <li key={"number-" + page}>
              <a className="sel" href={uriWith(reqUri, {[pageVar]: page})}>
                <strong>{page}</strong>
              </a>
            </li>
          ) : (
            <li key={"number-" + page}>
              <a href={uriWith(reqUri, {[pageVar]: page})}>{page}</a>
            </li>
          )
        ))}

        {end < (pager.last_page - 1) ? (
          <li key="before-last">
            <span>{l('…')}</span>
          </li>
        ) : null}

        {end < pager.last_page ? (
          <li key="last">
            <a href={uriWith(reqUri, {page: pager.last_page})}>
              {pager.last_page}
            </a>
          </li>
        ) : null}

        {guessSearch ? (
          <li key="guess">
            <span>{l('…')}</span>
          </li>
        ) : null}

        <li className="separator" key="separate-next">
          {pager.next_page ? (
            <li key="next">
              <a href={uriWith(reqUri, {page: pager.next_page})}>{l('Next')}</a>
            </li>
          ) : (
            <li key="no-next">
              <span>{l('Next')}</span>
            </li>
          )}
        </li>
      </ul>
    </nav>
  );
};

export default withCatalystContext(Paginator);
