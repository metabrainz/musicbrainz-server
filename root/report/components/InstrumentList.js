/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportInstrumentT} from '../types';
import formatUserDate from '../../utility/formatUserDate';

type Props = {
  +items: $ReadOnlyArray<ReportInstrumentT>,
  +pager: PagerT,
};

const InstrumentList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const $c = React.useContext(CatalystContext);

  return (
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
          {items.map((item, index) => {
            const instrument = item.instrument;
            return (
              <tr className={loopParity(index)} key={item.instrument_id}>
                {instrument ? (
                  <>
                    <td>
                      <EntityLink entity={instrument} />
                    </td>
                    <td>
                      {nonEmpty(instrument.typeName)
                        ? lp_attributes(
                          instrument.typeName, 'instrument_type',
                        )
                        : l('Unclassified instrument')}
                    </td>
                    <td>
                      {nonEmpty(instrument.last_updated)
                        ? formatUserDate($c, instrument.last_updated)
                        : null}
                    </td>
                  </>
                ) : (
                  <td colSpan="3">
                    {l('This instrument no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default InstrumentList;
