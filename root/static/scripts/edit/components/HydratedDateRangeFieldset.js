/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DateRangeFieldset, {reducer} from './DateRangeFieldset.js';

type PropsT = {
  +children?: React.Node,
  +disabled: boolean,
  +endedLabel?: string,
  +initialField: DatePeriodFieldT,
};

component _HydratedDateRangeFieldset(
  children?: React.Node,
  disabled: boolean = false,
  endedLabel?: string,
  initialField: DatePeriodFieldT,
  beginAreaIdField?: FieldT<string>,
  beginAreaField?: AreaFieldT,
  endAreaIdField?: FieldT<string>,
  endAreaField?: AreaFieldT,
) {
  const [field, dispatch] = React.useReducer(reducer, initialField);
  return (
    <DateRangeFieldset
      beginAreaField={beginAreaField}
      beginAreaIdField={beginAreaIdField}
      disabled={disabled}
      dispatch={dispatch}
      endAreaField={endAreaField}
      endAreaIdField={endAreaIdField}
      endedLabel={endedLabel}
      field={field}
    >
      {children}
    </DateRangeFieldset>
  );
}

const HydratedDateRangeFieldset: component(...PropsT) = hydrate<PropsT>(
  'div.date-range-fieldset',
  _HydratedDateRangeFieldset,
);

export default HydratedDateRangeFieldset;
