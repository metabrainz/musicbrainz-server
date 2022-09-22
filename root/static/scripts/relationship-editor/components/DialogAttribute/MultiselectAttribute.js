/*
 * @flow strict-local
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

const addAttributeLabels = {
  [INSTRUMENT_ROOT_ID]: N_l('Add instrument'),
  [VOCAL_ROOT_ID]: N_l('Add vocal'),
};

type PropsT = {
  +dispatch: (
    rootKey: number,
    action: DialogMultiselectAttributeActionT,
  ) => void,
  +state: DialogMultiselectAttributeStateT,
};

function _createLinkAttributeTypeOptions(
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
  attr.children?.forEach(child => (
    void _createLinkAttributeTypeOptions(child, level + 1, result)
  ));
}

/*
 * Flattens a root attribute type plus its children into a single list
 * for the autocomplete component. Sets a `level` property on each item
 * which is used by the autocomplete for visual indentation.
 */
const linkAttributeTypeOptionsCache = new Map();
const createLinkAttributeTypeOptions = (
  rootAttributeType: LinkAttrTypeT,
) => {
  const rootId = rootAttributeType.id;
  let options = linkAttributeTypeOptionsCache.get(rootId);
  if (options) {
    return options;
  }
  options = [];
  _createLinkAttributeTypeOptions(rootAttributeType, -1, options);
  linkAttributeTypeOptionsCache.set(rootId, options);
  return options;
};

const ATTR_VALUE_LABEL_STYLE = {
  clear: 'both',
};

function extractLinkAttributeTypeSearchTerms(
  item: OptionItemT<LinkAttrTypeT>,
): Array<string> {
  return [item.entity.l_name ?? ''];
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
      labelStyle: ATTR_VALUE_LABEL_STYLE,
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
      newState.values = updateMultiselectValue(
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
      if (
        action.type === 'add-value' ||
        action.type === 'update-value-autocomplete'
      ) {
        // Don't allow more than one attribute of the same type.
        const selectedAttributeIds = new Set();
        for (const value of newState.values) {
          const attributeId = value.autocomplete.selectedItem?.entity?.id;
          if (attributeId != null) {
            if (selectedAttributeIds.has(attributeId)) {
              newState.values = state.values;
              break;
            } else {
              selectedAttributeIds.add(attributeId);
            }
          }
        }
      }
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

const MultiselectAttribute = (React.memo<PropsT>(({
  state,
  dispatch,
}: PropsT): React.MixedElement => {
  const linkTypeAttributeType = state.type;
  const addLabel = addAttributeLabels[linkTypeAttributeType.id];

  const multiselectDispatch = React.useCallback((action) => {
    dispatch(state.key, action);
  }, [dispatch, state.key]);

  const buildExtraValueChildren = React.useCallback((valueState) => {
    const attributeType = valueState.autocomplete.selectedItem?.entity;

    const handleCreditChange = (event: SyntheticEvent<HTMLInputElement>) => {
      multiselectDispatch({
        creditedAs: event.currentTarget.value,
        type: 'set-value-credit',
        valueKey: valueState.key,
      });
    };

    return (
      <div className="credit-section">
        <label className="credit-field">
          {l('Credited as:')}
          <br />
          <input
            className="attribute-credit"
            disabled={!attributeType?.creditable}
            onChange={handleCreditChange}
            placeholder={attributeType?.name}
            type="text"
            value={valueState.creditedAs ?? ''}
          />
        </label>
      </div>
    );
  }, [multiselectDispatch]);

  // XXX: https://github.com/facebook/flow/issues/7672
  const LinkAttrTypeMultiselect = (
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
      addLabel={addLabel ? addLabel() : ''}
      buildExtraValueChildren={buildExtraValueChildren}
      dispatch={multiselectDispatch}
      state={state}
    />
  );
}): React.AbstractComponent<PropsT, mixed>);

export default MultiselectAttribute;
