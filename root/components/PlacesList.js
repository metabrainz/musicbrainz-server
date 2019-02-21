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
import loopParity from '../utility/loopParity';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import SortableTableHeader from '../components/SortableTableHeader';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod';

type Props = {|
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +places: $ReadOnlyArray<PlaceT>,
  +sortable?: boolean,
|};

const PlacesList = ({
  $c,
  checkboxes,
  order,
  places,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th style={{width: '1em'}}>
            <input type="checkbox" />
          </th>
        ) : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Place')}
                name="name"
                order={order}
              />
            )
            : l('Place')}
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
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Address')}
                name="address"
                order={order}
              />
            )
            : l('Address')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Area')}
                name="area"
                order={order}
              />
            )
            : l('Area')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Date')}
                name="date"
                order={order}
              />
            )
            : l('Date')}
        </th>
      </tr>
    </thead>
    <tbody>
      {places.map((place, index) => (
        <tr className={loopParity(index)} key={place.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={place.id}
              />
            </td>
          ) : null}
          <td>
            <EntityLink entity={place} />
          </td>
          <td>
            {place.typeName
              ? lp_attributes(place.typeName, 'place_type')
              : null}
          </td>
          <td>{place.address}</td>
          <td>
            {place.area ? <DescriptiveLink entity={place.area} /> : null}
          </td>
          <td>{formatDatePeriod(place)}</td>
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(PlacesList);
