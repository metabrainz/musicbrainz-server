/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Autocomplete2, {
  createInitialState as createAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import {
  default as autocompleteReducer,
} from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  OptionItemT as AutocompleteOptionItemT,
  OptionItemT,
} from '../../common/components/Autocomplete2/types.js';
import {compare} from '../../common/i18n.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {groupBy} from '../../common/utility/arrays.js';
import {uniqueId} from '../../common/utility/numbers.js';
import Multiselect, {
  runReducer as runMultiselectReducer,
  updateValue as updateMultiselectValue,
} from '../../edit/components/Multiselect.js';
import type {
  MultiselectWorkAttributeStateT,
  MultiselectWorkAttributeValueStateT,
} from '../../relationship-editor/types.js';
import type {
  WorkAttributeMultiselectActionT,
} from '../../relationship-editor/types/actions.js';

function buildStaticItems<E, T: {...OptionTreeT<E>, ...}>(
  options: $ReadOnlyArray<T>,
  localizeName: (string) => string,
  getName: T => string = x => x.name,
): $ReadOnlyArray<OptionItemT<T>> {
  const optionsByParentId = groupBy(options, option => option.parent_id);

  const compareChildren = (a: T, b: T) => {
    return (
      (a.child_order - b.child_order) ||
      compare(localizeName(getName(a)), localizeName(getName(b)))
    );
  };

  const getOptionsByParentId = (
    parentId: number | null,
    level: number,
  ): $ReadOnlyArray<OptionItemT<T>> => {
    const options = optionsByParentId.get(parentId);
    if (!options) {
      return [];
    }
    options.sort(compareChildren);
    return options.flatMap((option) => {
      const children = getOptionsByParentId(option.id, level + 1);
      return [
        {
          disabled: children.length > 0,
          entity: option,
          id: option.id,
          level,
          name: getName(option),
          type: 'option' as const,
        },
        ...children,
      ];
    });
  };

  return getOptionsByParentId(null, 0);
}

export function createInitialState(
  initialWorkAttributes?: $ReadOnlyArray<WorkAttributeT>,
): MultiselectWorkAttributeStateT {
  const workAttributeTypes =
    Object.values(linkedEntities.work_attribute_type);

  const workAttributeTypesAllowedValues =
    Object.values(linkedEntities.work_attribute_type_allowed_value);

  const newState = {
    max: null,
    staticTypeItems: buildStaticItems(workAttributeTypes, l),
    staticValueItems:
      buildStaticItems(workAttributeTypesAllowedValues, l, x => x.value),
    values: ([]: Array<MultiselectWorkAttributeValueStateT>),
  };
  if (initialWorkAttributes?.length) {
    for (const workAttribute of initialWorkAttributes) {
      const valueId = workAttribute.value_id;
      const allowedValue = valueId == null
        ? undefined
        : linkedEntities.work_attribute_type_allowed_value[valueId];

      newState.values.push(
        createSelectedWorkAttributeValue(
          newState.staticTypeItems,
          newState.staticValueItems,
          linkedEntities.work_attribute_type[workAttribute.typeID],
          workAttribute.value,
          allowedValue,
        ),
      );
    }
  } else {
    newState.values.push(createEmptyWorkAttributeValue(newState));
  }
  return newState;
}

export function createSelectedWorkAttributeValue(
  staticTypeItems:
    $ReadOnlyArray<AutocompleteOptionItemT<WorkAttributeTypeT>>,
  staticValueItems:
    $ReadOnlyArray<AutocompleteOptionItemT<WorkAttributeTypeAllowedValueT>>,
  selectedWorkAttributeType?: WorkAttributeTypeT,
  selectedWorkAttributeValue?: string,
  selectedWorkAttributeAllowedValue?: WorkAttributeTypeAllowedValueT,
): MultiselectWorkAttributeValueStateT {
  const key = uniqueId();
  const [textValue, autocompleteValue] = (() => {
    if (selectedWorkAttributeType?.free_text) {
      return [selectedWorkAttributeValue ?? '', null];
    }
    const autocompleteState =
      createAutocompleteState<WorkAttributeTypeAllowedValueT>({
        entityType: 'work_attribute_type_allowed_value',
        id: 'work-attribute-type-allowed-value-' + String(uniqueId()),
        placeholder: l('Search for an attribute value'),
        selectedItem: selectedWorkAttributeAllowedValue ? {
          entity: selectedWorkAttributeAllowedValue,
          id: selectedWorkAttributeAllowedValue.id,
          name: selectedWorkAttributeAllowedValue.value,
          type: 'option',
        } : null,
        staticItems: staticValueItems,
      });
    return [null, autocompleteState];
  })();
  return {
    autocomplete: createAutocompleteState < WorkAttributeTypeT >({
      entityType: 'work_attribute_type',
      id: 'work-attribute-type-' + String(key),
      placeholder: l('Search for an attribute type'),
      selectedItem: selectedWorkAttributeType ? {
        entity: selectedWorkAttributeType,
        id: selectedWorkAttributeType.id,
        name: selectedWorkAttributeType.name,
        type: 'option',
      } : null,
      staticItems: staticTypeItems,
    }),
    autocompleteValue,
    key,
    removed: false,
    textValue,
  };
}

export function createEmptyWorkAttributeValue(
  newState: $ReadOnly<{...MultiselectWorkAttributeStateT, ...}>,
): MultiselectWorkAttributeValueStateT {
  return createSelectedWorkAttributeValue(
    newState.staticTypeItems,
    newState.staticValueItems,
  );
}

export function runReducer(
  newState: {...MultiselectWorkAttributeStateT},
  action: WorkAttributeMultiselectActionT,
): void {
  match(action) {
    { type: 'set-value-text', const textValue, const valueKey } => {
      newState.values = updateMultiselectValue <
        WorkAttributeTypeT,
        MultiselectWorkAttributeValueStateT,
      >(
        newState.values,
        valueKey,
          (x) => ({...x, textValue}),
      );
    }
    {
      type: 'update-value-autocomplete',
      const autocompleteAction,
      const valueKey
    } => {
      newState.values = updateMultiselectValue <
        WorkAttributeTypeT,
        MultiselectWorkAttributeValueStateT,
      >(
        newState.values,
        valueKey,
          (x) => ({
            ...x,
            autocompleteValue:
              x.autocompleteValue
                ? autocompleteReducer(x.autocompleteValue, autocompleteAction)
                : null,
          }),
      );
    }
    _ as action => {
      return runMultiselectReducer(
        newState,
        action,
        createEmptyWorkAttributeValue,
      );
    }
  }
}

component _WorkAttributeMultiselect(
  dispatch: (WorkAttributeMultiselectActionT) => void,
  state: MultiselectWorkAttributeStateT,
) {
  const buildExtraValueChildren = React.useCallback((
    valueState: MultiselectWorkAttributeValueStateT,
  ) => {
    const attributeType = valueState.autocomplete.selectedItem?.entity;

    const handleValueChange = (event: SyntheticEvent<HTMLInputElement>) => {
      dispatch({
        textValue: event.currentTarget.value,
        type: 'set-value-text',
        valueKey: valueState.key,
      });
    };

    const autocompleteDispatch =
    (action: AutocompleteActionT<WorkAttributeTypeAllowedValueT>) => {
      dispatch({
        autocompleteAction: action,
        type: 'update-value-autocomplete',
        valueKey: valueState.key,
      });
    };

    if (attributeType?.free_text) {
      return (
<input
  className="attribute-value"
  onChange={handleValueChange}
  type="text"
  value={valueState.textValue ?? ''}
/>
      );
    } else if (attributeType && valueState.autocompleteValue) {
      return (
<Autocomplete2
  // eslint-disable-next-line react/jsx-no-bind
  dispatch={autocompleteDispatch}
  state={valueState.autocompleteValue}
/>
      );
    }
    return null;
  }, [
    dispatch,
  ]);

  return (
    <tr>
      <td>
        <Multiselect
          addLabel={l('Add work attribute')}
          buildExtraValueChildren={buildExtraValueChildren}
          dispatch={dispatch}
          state={state}
        />
      </td>
    </tr>
  );
}

const WorkAttributeMultiselect: typeof _WorkAttributeMultiselect =
  // $FlowExpectedError[incompatible-type]
  React.memo(_WorkAttributeMultiselect);

export default WorkAttributeMultiselect;
