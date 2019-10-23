/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import loopParity from '../../utility/loopParity';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import linkedEntities from '../../static/scripts/common/linkedEntities';
import SortableTableHeader from '../SortableTableHeader';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +sortable?: boolean,
};

const SeriesList = ({
  $c,
  checkboxes,
  order,
  series,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th className="checkbox-cell">
            <input type="checkbox" />
          </th>
        ) : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={lp('Series', 'singular')}
                name="name"
                order={order}
              />
            )
            : lp('Series', 'singular')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Type')}
                name="type"
                order={order}
              />
            )
            : l('Type')}
        </th>
        <th>{l('Ordering Type')}</th>
      </tr>
    </thead>
    <tbody>
      {series.map((thisSeries, index) => {
        const orderingType =
          linkedEntities.series_ordering_type[thisSeries.orderingTypeID];
        return (
          <tr className={loopParity(index)} key={thisSeries.id}>
            {$c.user_exists && checkboxes ? (
              <td>
                <input
                  name={checkboxes}
                  type="checkbox"
                  value={thisSeries.id}
                />
              </td>
            ) : null}
            <td>
              <DescriptiveLink entity={thisSeries} />
            </td>
            <td>
              {thisSeries.typeName
                ? lp_attributes(thisSeries.typeName, 'series_type')
                : null}
            </td>
            <td>
              {orderingType
                ? lp_attributes(orderingType.name, 'series_ordering_type')
                : null}
            </td>
          </tr>
        );
      })}
    </tbody>
  </table>
);

export default withCatalystContext(SeriesList);
