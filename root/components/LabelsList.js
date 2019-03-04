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
import formatLabelCode from '../utility/formatLabelCode';
import loopParity from '../utility/loopParity';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import formatDate from '../static/scripts/common/utility/formatDate';
import formatEndDate from '../static/scripts/common/utility/formatEndDate';

import RatingStars from './RatingStars';
import SortableTableHeader from './SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +checkboxes?: string,
  +labels: $ReadOnlyArray<LabelT>,
  +noAreas?: boolean,
  +noRatings?: boolean,
  +order?: string,
  +sortable?: boolean,
|};

const LabelsList = ({
  $c,
  checkboxes,
  labels,
  noAreas,
  noRatings,
  order,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th className="pos" />
        ) : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Label')}
                name="name"
                order={order}
              />
            )
            : l('Label')}
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
                label={l('Code')}
                name="code"
                order={order}
              />
            )
            : l('Code')}
        </th>
        {noAreas ? null : <th>{l('Area')}</th>}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Begin')}
                name="begin_date"
                order={order}
              />
            )
            : l('Begin')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('End')}
                name="end_date"
                order={order}
              />
            )
            : l('End')}
        </th>
        {noRatings ? null : <th>{l('Rating')}</th>}
      </tr>
    </thead>
    <tbody>
      {labels.map((label, index) => (
        <tr className={loopParity(index)} key={label.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={label.id}
              />
            </td>
          ) : null}
          <td>
            <DescriptiveLink entity={label} />
          </td>
          <td>
            {label.typeName
              ? lp_attributes(label.typeName, 'label_type')
              : null}
          </td>
          <td>
            {label.label_code ? formatLabelCode(label.label_code) : null}
          </td>
          {noAreas || !label.area ? null : (
            <td>
              <DescriptiveLink entity={label.area} />
            </td>
          )}
          <td>{formatDate(label.begin_date)}</td>
          <td>{formatEndDate(label)}</td>
          {noRatings ? null : (
            <td>
              <RatingStars entity={label} />
            </td>
          )}
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(LabelsList);
