/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity.js';
import expand2react from '../i18n/expand2react.js';

import DescriptiveLink from './DescriptiveLink.js';

type InstrumentListRowProps = {
  +checkboxes?: string,
  +instrument: InstrumentT,
};

type InstrumentListEntryProps = {
  +checkboxes?: string,
  +index: number,
  +instrument: InstrumentT,
  +score?: number,
};

const InstrumentListRow = ({
  checkboxes,
  instrument,
}: InstrumentListRowProps) => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <>
      {$c.user && nonEmpty(checkboxes) ? (
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
        {nonEmpty(instrument.typeName)
          ? lp_attributes(instrument.typeName, 'instrument_type')
          : null}
      </td>
      <td>
        {instrument.description
          ? expand2react(l_instrument_descriptions(instrument.description))
          : null}
      </td>
    </>
  );
};

const InstrumentListEntry = ({
  checkboxes,
  index,
  instrument,
  score,
}: InstrumentListEntryProps): React.Element<'tr'> => (
  <tr className={loopParity(index)} data-score={score ?? null}>
    <InstrumentListRow
      checkboxes={checkboxes}
      instrument={instrument}
    />
  </tr>
);

export default InstrumentListEntry;
