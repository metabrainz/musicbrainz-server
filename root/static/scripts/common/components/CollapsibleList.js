/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SidebarProperty}
  from '../../../../layout/components/sidebar/SidebarProperties';
import {bracketedText} from '../utility/bracketed';

export type BuildRowPropsT = {
  abbreviated?: boolean,
};

type Props<T> = {
  +ariaLabel: string,
  +buildRow:
    (T, ?BuildRowPropsT) => React.Element<'li' | typeof SidebarProperty>,
  +buildRowProps?: BuildRowPropsT,
  +className: string,
  +ContainerElement?: 'dl' | 'ul',
  +InnerElement?: 'p' | 'li',
  +rows: ?$ReadOnlyArray<T>,
  +showAllTitle: string,
  +showLessTitle: string,
  +toShowAfter: number,
  +toShowBefore: number,
};

const CollapsibleList = <T>({
  ariaLabel,
  buildRow,
  buildRowProps,
  className,
  ContainerElement = 'ul',
  InnerElement = 'li',
  rows,
  showAllTitle,
  showLessTitle,
  toShowAfter,
  toShowBefore,
}: Props<T>): React.MixedElement | null => {
  const [expanded, setExpanded] = React.useState<boolean>(false);

  const expand = (event: SyntheticMouseEvent<HTMLAnchorElement>) => {
    event.preventDefault();
    setExpanded(true);
  };

  const collapse = (event: SyntheticMouseEvent<HTMLAnchorElement>) => {
    event.preventDefault();
    setExpanded(false);
  };

  const containerProps = {
    'aria-label': ariaLabel,
    'className': className,
  };

  const TO_TRIGGER_COLLAPSE = toShowBefore + toShowAfter + 2;

  const tooManyRows = rows
    ? rows.length >= TO_TRIGGER_COLLAPSE
    : false;

  return (
    (rows && rows.length) ? (
      (tooManyRows && !expanded) ? (
        <ContainerElement {...containerProps}>
          {toShowBefore > 0 ? (
            rows.slice(0, toShowBefore).map(
              row => buildRow(row, buildRowProps),
            )
          ) : null}
          <InnerElement className="show-all" key="show-all">
            <a
              href="#"
              onClick={expand}
              role="button"
              title={showAllTitle}
            >
              {bracketedText(texp.l('show {n} more', {
                n: rows.length - (toShowBefore + toShowAfter),
              }))}
            </a>
          </InnerElement>
          {toShowAfter > 0 ? (
            rows.slice(-toShowAfter).map(
              row => buildRow(row, buildRowProps),
            )
          ) : null}
        </ContainerElement>
      ) : (
        <ContainerElement {...containerProps}>
          {rows.map(row => buildRow(row, buildRowProps))}
          {tooManyRows && expanded ? (
            <InnerElement className="show-less" key="show-less">
              <a
                href="#"
                onClick={collapse}
                role="button"
                title={showLessTitle}
              >
                {bracketedText(l('show less'))}
              </a>
            </InnerElement>
          ) : null}
        </ContainerElement>
      )
    ) : null
  );
};

export default CollapsibleList;
