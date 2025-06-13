/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {
  DialogTextAttributeStateT,
} from '../../types.js';
import type {
  DialogTextAttributeActionT,
} from '../../types/actions.js';

export function reducer(
  state: DialogTextAttributeStateT,
  action: DialogTextAttributeActionT,
): DialogTextAttributeStateT {
  const newState: {...DialogTextAttributeStateT} = {...state};

  switch (action.type) {
    case 'set-text-value': {
      newState.textValue = action.textValue;
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  return newState;
}

component _TextAttribute(
  dispatch: (
    rootKey: number,
    action: DialogTextAttributeActionT,
  ) => void,
  inputId: string,
  state: DialogTextAttributeStateT,
) {
  return (
    <input
      id={inputId}
      onChange={(event) => {
        dispatch(state.key, {
          textValue: event.currentTarget.value,
          type: 'set-text-value',
        });
      }}
      type="text"
      value={state.textValue}
    />
  );
}

const TextAttribute:
  component(...React.PropsOf<_TextAttribute>) =
  React.memo(_TextAttribute);

export default TextAttribute;
