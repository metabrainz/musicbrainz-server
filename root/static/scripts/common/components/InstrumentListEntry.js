/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../../context';
import loopParity from '../../../../utility/loopParity';
import expand2react from '../i18n/expand2react';

import DescriptiveLink from './DescriptiveLink';

type InstrumentListRowProps = {|
  +buildExtraDataCells?: (
    $c: CatalystContextT,
    entity: CoreEntityT,
  ) => AnyReactElem | null,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instrument: InstrumentT,
|};

type InstrumentListEntryProps = {|
  +buildExtraDataCells?: (
    $c: CatalystContextT,
    entity: CoreEntityT,
  ) => AnyReactElem | null,
  +checkboxes?: string,
  +index: number,
  +instrument: InstrumentT,
  +score?: number,
|};

const InstrumentListRow = withCatalystContext(({
  $c,
  buildExtraDataCells,
  checkboxes,
  instrument,
}: InstrumentListRowProps) => (
  <>
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
        ? expand2react(l_instrument_descriptions(instrument.description))
        : null}
    </td>
    {buildExtraDataCells
      ? buildExtraDataCells($c, instrument)
      : null}
  </>
));

const InstrumentListEntry = ({
  buildExtraDataCells,
  checkboxes,
  index,
  instrument,
  score,
}: InstrumentListEntryProps) => (
  <tr className={loopParity(index)} data-score={score || null}>
    <InstrumentListRow
      checkboxes={checkboxes}
      instrument={instrument}
    />
  </tr>
);

export default InstrumentListEntry;
