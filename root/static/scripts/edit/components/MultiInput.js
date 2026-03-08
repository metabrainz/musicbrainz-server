/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export type MultiInputActionT =
  | {
      +type: 'add-value',
    }
  | {
      +key: number,
      +type: 'remove-value',
    }
  | {
      +key: number,
      +type: 'update-value',
      +value: string,
    };

export type MultiInputValueStateT = {
  +key: number,
  +removed: boolean,
  +value: string,
  ...
};

export type MultiInputValuePropsT<
  VS: MultiInputValueStateT,
> = {
  +buildExtraChildren?: (VS) => React.Node,
  +dispatch: (MultiInputActionT) => void,
  +state: VS,
};

export type MultiInputStateT<VS: MultiInputValueStateT> = {
  +max: number | null,
  +values: $ReadOnlyArray<$Exact<VS>>,
  ...
};

export function accumulateMultiInputValues(
  values: $ReadOnlyArray<MultiInputValueStateT>,
): $ReadOnlyArray<string> {
  return values
    .filter(x => !x.removed)
    .map(x => x.value);
}

export function updateValue<
  VS: MultiInputValueStateT,
>(
  values: $ReadOnlyArray<$Exact<VS>>,
  key: number,
  callback: ($Exact<VS>) => $Exact<VS>,
): $ReadOnlyArray<$Exact<VS>> {
  return values.map((x) => {
    if (x.key === key) {
      return callback(x);
    }
    return x;
  });
}

export function runReducer<
  VS: MultiInputValueStateT,
  S: MultiInputStateT<VS>,
>(
  newState: {...S, ...},
  action: MultiInputActionT,
  createMultiInputValue: ({...S, ...}) => $Exact<VS>,
): void {
  match (action) {
    {type: 'add-value'} => {
      newState.values = [
        // We can remove "[removed]" rows now that focus has shifted.
        ...newState.values.filter(x => !x.removed),
        createMultiInputValue(newState),
      ];
    }
    {type: 'remove-value', const key} => {
      newState.values = updateValue<VS>(
        newState.values,
        key,
        (x) => ({...x, removed: true}),
      );
    }
    {type: 'update-value', const key, const value} => {
      newState.values = updateValue<VS>(
        newState.values,
        key,
        (x) => ({...x, value}),
      );
    }
  }
}

component _MultiInputValue<
  VS: MultiInputValueStateT,
>(...props: MultiInputValuePropsT<VS>) {
  const {
    buildExtraChildren,
    dispatch,
    state,
  } = props;

  const handleRemove = React.useCallback(() => {
    dispatch({key: state.key, type: 'remove-value'});
  }, [dispatch, state.key]);

  const handleChange =
    React.useCallback((event: SyntheticEvent<HTMLInputElement>) => {
      dispatch({
        key: state.key,
        type: 'update-value',
        value: event.currentTarget.value,
      });
    }, [dispatch, state.key]);

  return (
    <div className="MultiInput-value" key={state.key}>
      {/*
        * Removed entries are kept in the list so that focus isn't
        * lost and/or doesn't need to be shifted to an unrelated row;
        * neither situation is accessible.
        */}
      {state.removed ? lp('[removed]', 'generic row') : (
        <>
          <input onChange={handleChange} value={state.value} />
          {buildExtraChildren ? buildExtraChildren(state) : null}
        </>
      )}
      <button
        aria-disabled={state.removed}
        className="remove-item icon"
        onClick={handleRemove}
        title={l('Remove')}
        type="button"
      />
    </div>
  );
}

export const MultiInputValue: typeof _MultiInputValue =
  // $FlowExpectedError[incompatible-type]
  React.memo(_MultiInputValue);

component _MultiInput<
  VS: MultiInputValueStateT,
  S: MultiInputStateT<VS>,
>(
  addLabel: string,
  buildExtraValueChildren?: (VS) => React.Node,
  dispatch: (MultiInputActionT) => void,
  state: S,
) {
  const handleAdd = React.useCallback(() => {
    dispatch({type: 'add-value'});
  }, [dispatch]);

  const rowCount = state.values.reduce((accum, valueAttribute) => {
    return accum + (valueAttribute.removed ? 0 : 1);
  }, 0);

  return (
    <>
      {state.values.map(valueAttribute => (
        <MultiInputValue
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
}

const MultiInput: typeof _MultiInput =
  // $FlowExpectedError[incompatible-type]
  React.memo(_MultiInput);

export default MultiInput;
