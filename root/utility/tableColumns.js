/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import EntityLink from '../static/scripts/common/components/EntityLink';
import yesNo from '../static/scripts/common/utility/yesNo';

export function defineNameColumn(
  title: string,
): ColumnOptions<CoreEntityT | CollectionT, string> {
  return {
    Cell: ({row: {original}}) => (
      <EntityLink entity={original} />
    ),
    Header: title,
    accessor: 'name',
  };
}

export const typeColumn: ColumnOptions<CollectionT, string> = {
  Cell: ({cell: {value}}) => l(value),
  Header: N_l('Type'),
  accessor: 'typeName',
  id: 'type',
};

export const subscriptionColumn:
  ColumnOptions<{+subscribed: boolean, ...}, boolean> = {
    Cell: ({cell: {value}}) => yesNo(value),
    Header: N_l('Subscribed'),
    accessor: 'subscribed',
  };

export function defineActionsColumn(
  actions: $ReadOnlyArray<[string, string]>,
): ColumnOptions<CoreEntityT | CollectionT, number> {
  return {
    Cell: ({row: {original}}) => (
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
