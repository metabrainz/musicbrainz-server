/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {kebabCase} from '../../../common/utility/strings.js';
import type {
  DialogBooleanAttributeStateT,
} from '../../types.js';
import type {
  DialogBooleanAttributeActionT,
} from '../../types/actions.js';

type PropsT = {
  +dispatch: (
    rootKey: number,
    action: DialogBooleanAttributeActionT,
  ) => void,
  +state: DialogBooleanAttributeStateT,
};

export function reducer(
  state: DialogBooleanAttributeStateT,
  action: DialogBooleanAttributeActionT,
): DialogBooleanAttributeStateT {
  const newState: {...DialogBooleanAttributeStateT} = {...state};

  switch (action.type) {
    case 'toggle': {
      newState.enabled = action.enabled;
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  return newState;
}

const BooleanAttribute = (React.memo(({
  state,
  dispatch,
}: PropsT) => (
  <label>
    <input
      checked={state.enabled}
      className="boolean"
      id={kebabCase(state.type.name) + '-checkbox'}
      onChange={(event: SyntheticEvent<HTMLInputElement>) => {
        dispatch(state.key, {
          enabled: event.currentTarget.checked,
          type: 'toggle',
        });
      }}
      type="checkbox"
    />
    {' '}
    {state.type.l_name}
  </label>
)): React.AbstractComponent<PropsT>);

export default BooleanAttribute;
