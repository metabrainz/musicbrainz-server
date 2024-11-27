/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  createInitialState as createAutocompleteState,
} from '../../../common/components/Autocomplete2.js';
import type {
  OptionItemT,
} from '../../../common/components/Autocomplete2/types.js';
import {
  INSTRUMENT_ROOT_ID,
  VOCAL_ROOT_ID,
} from '../../../common/constants.js';
import localizeLinkAttributeTypeName
  from '../../../common/i18n/localizeLinkAttributeTypeName.js';
import {uniqueId} from '../../../common/utility/numbers.js';
import Multiselect, {
  type MultiselectPropsT,
  type MultiselectValuePropsT,
  buildValues as buildMultiselectValues,
  runReducer as runMultiselectReducer,
  updateValue as updateMultiselectValue,
} from '../../../edit/components/Multiselect.js';
import type {
  DialogMultiselectAttributeStateT,
  DialogMultiselectAttributeValueStateT,
} from '../../types.js';
import type {
  DialogMultiselectAttributeActionT,
} from '../../types/actions.js';

function addAttributeLabel(attributeTypeId: ?number): string {
  switch (attributeTypeId) {
    case INSTRUMENT_ROOT_ID:
      return lp('Add instrument', 'interactive');
    case VOCAL_ROOT_ID:
      return l('Add vocal');
    default:
      return lp('Add another', 'relationship attribute');
  }
}

export function _createLinkAttributeTypeOptions(
  attr: LinkAttrTypeT,
  level: number = 0,
  result: Array<OptionItemT<LinkAttrTypeT>> = [],
) {
  if (level >= 0) {
    result.push({
      entity: attr,
      id: attr.id,
      level,
      name: attr.name,
      type: 'option',
    });
  }
  attr.children?.forEach(child => {
    _createLinkAttributeTypeOptions(child, level + 1, result);
  });
}

/*
 * Flattens a root attribute type plus its children into a single list
 * for the autocomplete component. Sets a `level` property on each item
 * which is used by the autocomplete for visual indentation.
 */
const linkAttributeTypeOptionsCache = new Map<
  number,
  $ReadOnlyArray<OptionItemT<LinkAttrTypeT>>,
>();
export function createLinkAttributeTypeOptions(
  rootAttributeType: LinkAttrTypeT,
): $ReadOnlyArray<OptionItemT<LinkAttrTypeT>> {
  const rootId = rootAttributeType.id;
  let options = linkAttributeTypeOptionsCache.get(rootId);
  if (options) {
    return options;
  }
  options = [];
  _createLinkAttributeTypeOptions(rootAttributeType, -1, options);
  linkAttributeTypeOptionsCache.set(rootId, options);
  return options;
}

export function extractLinkAttributeTypeSearchTerms(
  item: OptionItemT<LinkAttrTypeT>,
): Array<string> {
  return [
    item.entity.l_name ?? '',
    ...(item.entity.instrument_aliases ?? []),
  ];
}

export function createMultiselectAttributeValue(
  rootAttribute: LinkAttrTypeT,
  selectedAttribute: LinkAttrTypeT | null,
  creditedAs?: string = '',
): DialogMultiselectAttributeValueStateT {
  const key = uniqueId();
  return {
    autocomplete: createAutocompleteState<LinkAttrTypeT>({
      entityType: 'link_attribute_type',
      extractSearchTerms: extractLinkAttributeTypeSearchTerms,
      id: 'attribute-' + String(key),
      placeholder: localizeLinkAttributeTypeName(rootAttribute),
      recentItemsKey: 'link_attribute_type-' + rootAttribute.name,
      selectedItem: selectedAttribute ? {
        entity: selectedAttribute,
        id: selectedAttribute.id,
        name: localizeLinkAttributeTypeName(selectedAttribute),
        type: 'option',
      } : null,
      staticItems: createLinkAttributeTypeOptions(rootAttribute),
    }),
    control: 'multiselect-value',
    creditedAs,
    key,
    removed: false,
  };
}

export function reducer(
  state: DialogMultiselectAttributeStateT,
  action: DialogMultiselectAttributeActionT,
): DialogMultiselectAttributeStateT {
  const newState = {...state};

  switch (action.type) {
    case 'set-value-credit': {
      newState.values = updateMultiselectValue<
        LinkAttrTypeT,
        DialogMultiselectAttributeValueStateT,
      >(
        newState.values,
        action.valueKey,
        (x) => ({...x, creditedAs: action.creditedAs}),
      );
      break;
    }
    default: {
      runMultiselectReducer<
        LinkAttrTypeT,
        DialogMultiselectAttributeValueStateT,
        DialogMultiselectAttributeStateT,
      >(
        newState,
        action,
        () => createMultiselectAttributeValue(state.type, null),
      );
    }
  }

  const rootInfo = newState.linkType.attributes[newState.type.id];
  if (
    rootInfo.min != null &&
    rootInfo.min > 0 &&
    rootInfo.min > newState.values.filter(x => !x.removed).length
  ) {
    newState.error = l('This attribute is required.');
  } else {
    newState.error = '';
  }

  return newState;
}

component MultiselectAttributeComponent(
  dispatch: (
    rootKey: number,
    action: DialogMultiselectAttributeActionT,
  ) => void,
  state: DialogMultiselectAttributeStateT,
) {
  const linkTypeAttributeType = state.type;
  const addLabel = addAttributeLabel(linkTypeAttributeType.id);

  const multiselectDispatch = React.useCallback((
    action: DialogMultiselectAttributeActionT,
  ) => {
    dispatch(state.key, action);
  }, [dispatch, state.key]);

  const buildValues: MultiselectValuePropsT<
    LinkAttrTypeT,
    DialogMultiselectAttributeValueStateT,
  > = buildMultiselectValues;

  const buildExtraValueChildren = React.useCallback((
    valueState: DialogMultiselectAttributeValueStateT,
  ) => {
    const attributeType = valueState.autocomplete.selectedItem?.entity;

    const handleCreditChange = (event: SyntheticEvent<HTMLInputElement>) => {
      multiselectDispatch({
        creditedAs: event.currentTarget.value,
        type: 'set-value-credit',
        valueKey: valueState.key,
      });
    };

    return (
      <input
        aria-label={l('Credited as')}
        className="attribute-credit"
        disabled={!(
          attributeType
            ? attributeType.creditable
            : state.type.creditable
        )}
        onChange={handleCreditChange}
        placeholder={l('Credited as')}
        type="text"
        value={valueState.creditedAs ?? ''}
      />
    );
  }, [
    multiselectDispatch,
    state.type.creditable,
  ]);

  // XXX: https://github.com/facebook/flow/issues/7672
  const LinkAttrTypeMultiselect = (
    // eslint-disable-next-line ft-flow/enforce-suppression-code
    // $FlowIgnore
    Multiselect:
      React.AbstractComponent<
        MultiselectPropsT<
          LinkAttrTypeT,
          DialogMultiselectAttributeValueStateT,
          DialogMultiselectAttributeStateT,
        >,
        mixed,
      >
  );

  return (
    <LinkAttrTypeMultiselect
      addLabel={addLabel}
      buildExtraValueChildren={buildExtraValueChildren}
      buildValues={buildValues}
      dispatch={multiselectDispatch}
      state={state}
    />
  );
}

type MultiselectAttributeMemoT =
  React.AbstractComponent<React.PropsOf<MultiselectAttributeComponent>>;

const MultiselectAttribute: MultiselectAttributeMemoT =
  React.memo(MultiselectAttributeComponent);

export default MultiselectAttribute;
