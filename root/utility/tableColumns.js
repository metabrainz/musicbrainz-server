/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import yesNo from '../static/scripts/common/utility/yesNo';

declare type CellT = {
  +cell: {
    +value: any,
  },
  +row: {
    +original: any,
  },
};

export function defineNameColumn(
  title: string,
) {
  return {
    Cell: ({row: {original}}: CellT) => (
      <EntityLink entity={original} />
    ),
    Header: title,
    accessor: 'name',
  };
}

export const typeColumn = {
  Cell: ({cell: {value}}: CellT) => l(value),
  Header: N_l('Type'),
  accessor: 'typeName',
  id: 'type',
};

export const subscriptionColumn = {
  Cell: ({cell: {value}}: CellT) => yesNo(value),
  Header: N_l('Subscribed'),
  accessor: 'subscribed',
};

export function defineActionsColumn(
  actions: $ReadOnlyArray<[string, string]>,
) {
  return {
    Cell: ({row: {original}}: CellT) => (
      <>
        {actions.map((actionPair, index) => (
          <React.Fragment key={actionPair[1] + (index === 0 ? '-first' : '')}>
            {index === 0 ? null : ' | '}
            <EntityLink
              content={actionPair[0]}
              entity={original}
              subPath={actionPair[1]}
            />
          </React.Fragment>
        ))}
      </>
    ),
    Header: l('Actions'),
    accessor: 'id',
    className: 'actions',
    id: 'actions',
  };
}
