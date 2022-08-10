/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import uriWith from '../utility/uriWith.js';

function printSortArrows(name: string, order: ?string) {
  if (order === name) {
    return ' ▴';
  } else if (order === '-' + name) {
    return ' ▾';
  }
  return (
    <>
      {' '}
      <span style={{opacity: 0.4}}>{'▴/▾'}</span>
    </>
  );
}

type Props = {
  +label: string,
  +name: string,
  +order: ?string,
};

const SortableTableHeader = ({
  label,
  name,
  order,
}: Props): React.MixedElement => (
  <CatalystContext.Consumer>
    {$c => (
      <a
        href={uriWith(
          $c.req.uri,
          {order: order === name ? '-' + name : name},
        )}
      >
        {label}
        {printSortArrows(name, order)}
      </a>
    )}
  </CatalystContext.Consumer>
);

export default SortableTableHeader;
