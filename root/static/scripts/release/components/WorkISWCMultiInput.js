/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {uniqueId} from '../../common/utility/numbers.js';
import {
  accumulateMultiInputValues,
} from '../../edit/components/MultiInput.js';
import MultiInput, {
  type MultiInputActionT,
  runReducer as runMulitInputReducer,
} from '../../edit/components/MultiInput.js';
import {
  type MultiInputISWCStateT,
  type MultiInputISWCValueStateT,
} from '../../relationship-editor/types.js';

export function createInitialState(
  initialISWCs: $ReadOnlyArray<IswcT>,
): MultiInputISWCStateT {
  return {
    max: null,
    values: initialISWCs.length
      ? initialISWCs.map(createISWCValue)
      : [createEmptyISWCValue()],
  };
}


function createISWCValue(
  iswc: IswcT | null,
): MultiInputISWCValueStateT {
  return {
    key: uniqueId(),
    removed: false,
    value: iswc?.iswc ?? '',
  };
}

function createEmptyISWCValue(): MultiInputISWCValueStateT {
  return createISWCValue(null);
}

export function runReducer(
  newState: {...MultiInputISWCStateT, ...},
  action: MultiInputActionT,
): void {
  return runMulitInputReducer(
    newState,
    action,
    createEmptyISWCValue,
  );
}

export function accumulateValues(
  values: $ReadOnlyArray<MultiInputISWCValueStateT>,
  workId: number,
): $ReadOnlyArray<IswcT> {
  return accumulateMultiInputValues(values).map(value => ({
    editsPending: false,
    entityType: 'iswc',
    id: uniqueId(),
    iswc: value,
    work_id: workId,
  }));
}

component _WorkISWCMultiInput(
  dispatch: (MultiInputActionT) => void,
  state: MultiInputISWCStateT,
) {
  return (
    <tr>
      <td className="section">
        {addColonText(l('ISWCs'))}
      </td>
      <td className="iswcs">
        <MultiInput
          addLabel={l('Add ISWC')}
          dispatch={dispatch}
          state={state}
        />
      </td>
    </tr>
  );
}

const WorkISWCMultiInput: typeof _WorkISWCMultiInput =
  // $FlowExpectedError[incompatible-type]
  React.memo(_WorkISWCMultiInput);

export default WorkISWCMultiInput;
