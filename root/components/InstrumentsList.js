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
import expand2react from '../static/scripts/common/i18n/expand2react';

import SortableTableHeader from './SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instruments: $ReadOnlyArray<InstrumentT>,
  +order?: string,
  +sortable?: boolean,
|};

const InstrumentsList = ({
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
          <th style={{width: '1em'}}>
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
        <tr className={loopParity(index)} key={instrument.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={instrument.id}
              />
            </td>
          ) : null}
          <td>
            <DescriptiveLink entity={instrument} />
          </td>
          <td>
            {instrument.typeName
              ? lp_attributes(instrument.typeName, 'instrument_type')
              : null}
          </td>
          <td>
            {instrument.description
              ? expand2react(
                l_instrument_descriptions(instrument.description),
              )
              : null}
          </td>
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(InstrumentsList);
