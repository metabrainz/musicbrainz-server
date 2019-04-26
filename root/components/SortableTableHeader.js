/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import uriWith from '../utility/uriWith';

function printSortArrows(name, order) {
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

type Props = {|
  +$c: CatalystContextT,
  +label: string,
  +name: string,
  +order: ?string,
|};

const SortableTableHeader = ({$c, label, name, order}: Props) => (
  <>
    <a
      href={uriWith(
        $c.req.uri,
        {order: order === name ? '-' + name : name},
      )}
    >
      {label}
      {printSortArrows(name, order)}
    </a>
  </>
);

export default withCatalystContext(SortableTableHeader);
