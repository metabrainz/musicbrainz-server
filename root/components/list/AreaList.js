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

import SortableTableHeader from '../SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +order?: string,
  +sortable?: boolean,
|};

const AreaList = ({
  $c,
  areas,
  checkboxes,
  order,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th>
            <input type="checkbox" />
          </th>
        ) : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Area')}
                name="name"
                order={order}
              />
            )
            : l('Area')}
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
      </tr>
    </thead>
    <tbody>
      {areas.map((area, index) => (
        <tr className={loopParity(index)} key={area.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={area.id}
              />
            </td>
          ) : null}
          <td>
            <DescriptiveLink entity={area} />
          </td>
          <td>
            {area.typeName
              ? lp_attributes(area.typeName, 'area_type')
              : null}
          </td>
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(AreaList);
