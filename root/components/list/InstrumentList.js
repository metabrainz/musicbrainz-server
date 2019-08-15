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
import InstrumentListEntry
  from '../../static/scripts/common/components/InstrumentListEntry';
import SortableTableHeader from '../SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instruments: $ReadOnlyArray<InstrumentT>,
  +order?: string,
  +sortable?: boolean,
|};

const InstrumentList = ({
  $c,
  checkboxes,
  instruments,
  order,
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
                label={l('Instrument')}
                name="name"
                order={order}
              />
            )
            : l('Instrument')}
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
        <th>{l('Description')}</th>
      </tr>
    </thead>
    <tbody>
      {instruments.map((instrument, index) => (
        <InstrumentListEntry
          checkboxes={checkboxes}
          index={index}
          instrument={instrument}
          key={instrument.id}
        />
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(InstrumentList);
