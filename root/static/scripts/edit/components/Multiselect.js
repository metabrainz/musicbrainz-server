/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Autocomplete2 from '../../common/components/Autocomplete2.js';
import {
  default as autocompleteReducer,
} from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  EntityItemT as AutocompleteEntityItemT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';

export type MultiselectActionT<
  V: AutocompleteEntityItemT,
> =
  | {
      +type: 'add-value',
    }
  | {
      +type: 'remove-value',
      +valueKey: number,
    }
  | {
      +action: AutocompleteActionT<V>,
      +type: 'update-value-autocomplete',
      +valueKey: number,
    };

export type MultiselectValueStateT<V> = {
  +autocomplete: AutocompleteStateT<V>,
  +key: number,
  +removed: boolean,
  ...
};

export type MultiselectValuePropsT<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
> = {
  +buildExtraChildren?: ($Exact<VS>) => React.Node,
  +dispatch: (MultiselectActionT<V>) => void,
  +state: $Exact<VS>,
};

export type MultiselectStateT<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
> = {
  +max: number | null,
  +values: $ReadOnlyArray<$Exact<VS>>,
  ...
};

export type MultiselectPropsT<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
  S: MultiselectStateT<V, VS>,
> = {
  +addLabel: string,
  +buildExtraValueChildren?: ($Exact<VS>) => React.Node,
  +dispatch: (MultiselectActionT<V>) => void,
  +state: $Exact<S>,
};

export const ATTR_VALUE_LABEL_STYLE = {
  clear: 'both',
};

export function accumulateMultiselectValues<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
>(
  values: $ReadOnlyArray<$Exact<VS>>,
): $ReadOnlyArray<V> {
  return values.reduce(
    (accum, valueState) => {
      const item = valueState.autocomplete.selectedItem?.entity;
      if (item) {
        accum.push(item);
      }
      return accum;
    },
    [],
  );
}

export function updateValue<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
>(
  values: $ReadOnlyArray<$Exact<VS>>,
  valueKey: number,
  callback: ($Exact<VS>) => $Exact<VS>,
): $ReadOnlyArray<$Exact<VS>> {
  return values.map((x) => {
    if (x.key === valueKey) {
      return callback(x);
    }
    return x;
  });
}

export function runReducer<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
  S: MultiselectStateT<V, VS>,
>(
  newState: {...S, ...},
  action: MultiselectActionT<V>,
  createMultiselectValue: ({...S, ...}) => $Exact<VS>,
): void {
  switch (action.type) {
    case 'add-value': {
      newState.values = [
        // We can remove "[removed]" rows now that focus has shifted.
        ...newState.values.filter(x => !x.removed),
        createMultiselectValue(newState),
      ];
      break;
    }
    case 'remove-value': {
      newState.values = updateValue(
        newState.values,
        action.valueKey,
        (x) => ({...x, removed: true}),
      );
      break;
    }
    case 'update-value-autocomplete': {
      newState.values = updateValue(
        newState.values,
        action.valueKey,
        (x) => ({
          ...x,
          autocomplete: autocompleteReducer<V>(
            x.autocomplete,
            action.action,
          ),
        }),
      );
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }
}

type MultiselectValueComponentT = React.AbstractComponent<
  MultiselectValuePropsT<
    AutocompleteEntityItemT,
    MultiselectValueStateT<AutocompleteEntityItemT>,
  >,
  mixed,
>;

export const MultiselectValue: MultiselectValueComponentT = React.memo(<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
>({
  buildExtraChildren,
  dispatch,
  state,
}: MultiselectValuePropsT<V, VS>): React.MixedElement => {
  const autocompleteDispatch = React.useCallback(
    (action: AutocompleteActionT<V>) => {
      dispatch({
        action,
        type: 'update-value-autocomplete',
        valueKey: state.key,
      });
    },
    [dispatch, state.key],
  );

  const handleRemove = React.useCallback(() => {
    dispatch({type: 'remove-value', valueKey: state.key});
  }, [dispatch, state.key]);

  return (
    <div className="multiselect-value" key={state.key}>
      {/*
        * Removed entries are kept in the list so that focus isn't
        * lost and/or doesn't need to be shifted to an unrelated row;
        * neither situation is accessible.
        */}
      {state.removed ? null : (
        <>
          <Autocomplete2
            dispatch={autocompleteDispatch}
            state={state.autocomplete}
          />
          {buildExtraChildren ? buildExtraChildren(state) : null}
        </>
      )}
      <button
        aria-disabled={state.removed}
        className="remove-item with-label"
        onClick={handleRemove}
        type="button"
      >
        {state.removed ? l('[removed]') : l('Remove')}
      </button>
    </div>
  );
});

const Multiselect = (React.memo(<
  V: AutocompleteEntityItemT,
  VS: MultiselectValueStateT<V>,
  S: MultiselectStateT<V, VS>,
>({
  addLabel,
  buildExtraValueChildren,
  dispatch,
  state,
}: MultiselectPropsT<V, VS, S>): React.MixedElement => {
  const handleAdd = React.useCallback(() => {
    dispatch({type: 'add-value'});
  }, [dispatch]);

  const rowCount = state.values.reduce((accum, valueAttribute) => {
    return accum + (valueAttribute.removed ? 0 : 1);
  }, 0);

  // XXX: https://github.com/facebook/flow/issues/7672
  const GenericMultiselectValue = (
    // $FlowIgnore[incompatible-cast]
    MultiselectValue:
      React.AbstractComponent<
        MultiselectValuePropsT<V, VS>,
        mixed,
      >
  );

  return (
    <>
      {state.values.map(valueAttribute => (
        <GenericMultiselectValue
          buildExtraChildren={buildExtraValueChildren}
          dispatch={dispatch}
          key={valueAttribute.key}
          state={valueAttribute}
        />
      ))}
      {(state.max == null || state.max < rowCount) ? (
        <button
          className="add-item with-label"
          onClick={handleAdd}
          type="button"
        >
          {' ' + addLabel}
        </button>
      ) : null}
    </>
  );
}): React.AbstractComponent<
  MultiselectPropsT<
    AutocompleteEntityItemT,
    MultiselectValueStateT<AutocompleteEntityItemT>,
    MultiselectStateT<
      AutocompleteEntityItemT,
      MultiselectValueStateT<AutocompleteEntityItemT>,
    >,
  >,
  mixed,
>);

export default Multiselect;
