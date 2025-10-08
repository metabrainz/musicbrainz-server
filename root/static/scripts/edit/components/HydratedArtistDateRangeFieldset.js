/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import Autocomplete2, {
  createInitialState as createInitialAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import autocompleteReducer
  from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';
import {createAreaObject} from '../../common/entity2.js';

import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  type StateT as DateRangeFieldsetStateT,
  runReducer as runDateRangeFieldsetReducer,
} from './DateRangeFieldset.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

type PropsT = {
  +beginArea: AreaFieldT,
  +children?: React.Node,
  +disabled: boolean,
  +endArea: AreaFieldT,
  +endedLabel?: string,
  +initialDate: DatePeriodFieldT,
};

type StateT = {
  +beginArea: AutocompleteStateT<AreaT>,
  +date: DateRangeFieldsetStateT,
  +endArea: AutocompleteStateT<AreaT>,
};

type ActionT =
  | {
      +action: DateRangeFieldsetActionT,
      +type: 'update-date-period',
    }
  | {+action: AutocompleteActionT<AreaT>, +type: 'update-begin-area'}
  | {+action: AutocompleteActionT<AreaT>, +type: 'update-end-area'};

function createAreaState(
  label: string,
  field: AreaFieldT,
): AutocompleteStateT<AreaT> {
  const name = field.field.name.value;
  const id = parseInt(field.field.id.value ?? '0', 10);
  return createInitialAutocompleteState({
    entityType: 'area',
    htmlName: field.html_name,
    id: 'id-' + field.html_name,
    inputClass: 'with-button',
    inputValue: name,
    label,
    selectedItem: id ? {
      entity: createAreaObject({
        gid: field.field.gid.value ?? '',
        id,
        name,
      }),
      id,
      name,
      type: 'option',
    } : null,
    showLabel: true,
  });
}

type CreateInitialStatePropsT = {
  +beginArea: AreaFieldT,
  +endArea: AreaFieldT,
  +initialDate: DatePeriodFieldT,
};

function createInitialState({
  beginArea,
  endArea,
  initialDate,
}: CreateInitialStatePropsT): StateT {
  return {
    beginArea: createAreaState(l('Begin area'), beginArea),
    date: initialDate,
    endArea: createAreaState(l('End area'), endArea),
  };
}

function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  const ctx = mutate(state);
  match (action) {
    {type: 'update-begin-area', const action} => {
      ctx.set(
        'beginArea',
        autocompleteReducer(state.beginArea, action),
      );
    }
    {type: 'update-end-area', const action} => {
      ctx.set(
        'endArea',
        autocompleteReducer(state.endArea, action),
      );
    }
    {type: 'update-date-period', const action} => {
      runDateRangeFieldsetReducer(ctx.get('date'), action);
    }
  }
  return ctx.final();
}

component _HydratedArtistDateRangeFieldset(
  children?: React.Node,
  disabled: boolean = false,
  endedLabel?: string,
  initialDate: DatePeriodFieldT,
  beginArea: AreaFieldT,
  endArea: AreaFieldT,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    {
      beginArea,
      endArea,
      initialDate,
    },
    createInitialState,
  );

  const beginAreaDispatch = React.useCallback((
    action: AutocompleteActionT<AreaT>,
  ) => {
    dispatch({action, type: 'update-begin-area'});
  }, [dispatch]);

  const endAreaDispatch = React.useCallback((
    action: AutocompleteActionT<AreaT>,
  ) => {
    dispatch({action, type: 'update-end-area'});
  }, [dispatch]);

  const dateDispatch = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-period'});
  }, [dispatch]);

  return (
    <DateRangeFieldset
      beginArea={
        <FormRow>
          <Autocomplete2
            dispatch={beginAreaDispatch}
            state={state.beginArea}
          />
          <input
            name={`${beginArea.html_name}_id`}
            type="hidden"
            value={state.beginArea.selectedItem
              ? String(state.beginArea.selectedItem.entity.id)
              : ''}
          />
          <FieldErrors field={beginArea} />
        </FormRow>
      }
      disabled={disabled}
      dispatch={dateDispatch}
      endArea={
        <FormRow>
          <Autocomplete2
            dispatch={endAreaDispatch}
            state={state.endArea}
          />
          <input
            name={`${endArea.html_name}_id`}
            type="hidden"
            value={state.endArea.selectedItem
              ? String(state.endArea.selectedItem.entity.id)
              : ''}
          />
          <FieldErrors field={endArea} />
        </FormRow>
      }
      endedLabel={endedLabel}
      field={state.date}
    >
      {children}
    </DateRangeFieldset>
  );
}

const HydratedArtistDateRangeFieldset: component(...PropsT) = hydrate<PropsT>(
  'div.date-range-fieldset',
  _HydratedArtistDateRangeFieldset,
);

export default HydratedArtistDateRangeFieldset;
