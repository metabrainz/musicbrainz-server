/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportInstrumentT} from '../types';
import formatUserDate from '../../utility/formatUserDate';
import {withCatalystContext} from '../../context';

const InstrumentList = ({
  $c,
  items,
  pager,
}: {
  $c: CatalystContextT,
  items: $ReadOnlyArray<ReportInstrumentT>,
  pager: PagerT,
}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Instrument')}</th>
          <th>{l('Type')}</th>
          <th>{l('Last updated')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.instrument.gid}>
            <td>
              <EntityLink entity={item.instrument} />
            </td>
            <td>{item.instrument.typeName ? lp_attributes(item.instrument.typeName, 'instrument_type') : l('Unclassified instrument')}</td>
            <td>
              {item.instrument.last_updated
                ? formatUserDate($c.user, item.instrument.last_updated)
                : null
              }
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default withCatalystContext(InstrumentList);
