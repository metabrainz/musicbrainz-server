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
import WorkListEntry from '../static/scripts/common/components/WorkListEntry';

import SortableTableHeader from './SortableTableHeader';

type Props = {|
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +showRatings?: boolean,
  +sortable?: boolean,
  +works: $ReadOnlyArray<WorkT>,
|};

const WorkList = ({
  $c,
  checkboxes,
  order,
  seriesItemNumbers,
  showRatings,
  sortable,
  works,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th>
            <input type="checkbox" />
          </th>
        ) : null}
        {seriesItemNumbers ? <th style={{width: '1em'}}>{l('#')}</th> : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Work')}
                name="name"
                order={order}
              />
            )
            : l('Work')}
        </th>
        <th>{l('Writers')}</th>
        <th>{l('Artists')}</th>
        <th>{l('ISWC')}</th>
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
        <th>{l('Lyrics Languages')}</th>
        <th>{l('Attributes')}</th>
        {showRatings ? <th>{l('Rating')}</th> : null}
      </tr>
    </thead>
    <tbody>
      {works.map((work, index) => (
        <WorkListEntry
          checkboxes={checkboxes}
          index={index}
          key={work.id}
          seriesItemNumbers={seriesItemNumbers}
          showAttributes
          showIswcs
          showRatings={showRatings}
          work={work}
        />
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(WorkList);
