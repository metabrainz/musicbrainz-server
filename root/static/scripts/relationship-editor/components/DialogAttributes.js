/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';

import {compare} from '../../common/i18n.js';
import expand2react from '../../common/i18n/expand2react.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import clean from '../../common/utility/clean.js';
import {uniqueId} from '../../common/utility/numbers.js';
import {capitalize, kebabCase} from '../../common/utility/strings.js';
import type {
  DialogAttributesStateT,
  DialogAttributesT,
  DialogAttributeT,
  DialogBooleanAttributeStateT,
  DialogMultiselectAttributeStateT,
  DialogTextAttributeStateT,
  LinkAttributesByRootIdT,
} from '../types.js';
import type {
  DialogAttributeActionT,
} from '../types/actions.js';
import {
  areLinkAttributesEqual,
  compareLinkAttributes,
} from '../utility/compareRelationships.js';

import BooleanAttribute, {
  reducer as booleanAttributeReducer,
} from './DialogAttribute/BooleanAttribute.js';
import MultiselectAttribute, {
  createMultiselectAttributeValue,
  reducer as multiselectAttributeReducer,
} from './DialogAttribute/MultiselectAttribute.js';
import TextAttribute, {
  reducer as textAttributeReducer,
} from './DialogAttribute/TextAttribute.js';

type PropsT = {
  +dispatch: (DialogAttributeActionT) => void,
  +isHelpVisible: boolean,
  +state: $ReadOnly<{...DialogAttributesStateT, ...}>,
};

const DIALOG_ATTRIBUTE_ORDER = {
  checkbox: 1,
  multiselect: 3,
  text: 2,
};

function createDialogAttributesList(
  linkType: ?LinkTypeT,
  existingAttributesByRootId: LinkAttributesByRootIdT | null,
): DialogAttributesT {
  const dialogAttributes = [];

  if (linkType) {
    for (const typeId in linkType.attributes) {
      const linkTypeAttribute = linkType.attributes[+typeId];
      const rootAttributeType = linkedEntities.link_attribute_type[typeId];

      if (__DEV__) {
        invariant(
          rootAttributeType.id === rootAttributeType.root_id,
          'expected a root link attribute type, got ' + JSON.stringify({
            id: rootAttributeType.id,
            root_id: rootAttributeType.root_id,
          }),
        );
      }

      let dialogAttribute: DialogAttributeT;
      const sharedProps = {
        error: '',
        key: uniqueId(),
        max: linkTypeAttribute.max,
        min: linkTypeAttribute.min,
        type: rootAttributeType,
      };

      const existingAttributes =
        existingAttributesByRootId?.get(rootAttributeType.id);

      if (rootAttributeType.children) {
        dialogAttribute = {
          control: 'multiselect',
          linkType,
          values: existingAttributes
            ? existingAttributes.map((linkAttr) => (
              createMultiselectAttributeValue(
                rootAttributeType,
                linkAttr.type,
                linkAttr.credited_as,
              )
            ))
            : [createMultiselectAttributeValue(rootAttributeType, null)],
          ...sharedProps,
        };
      } else if (rootAttributeType.free_text) {
        if (__DEV__) {
          invariant(
            !existingAttributes || (existingAttributes.length <= 1),
            'only one free-text attribute is supported at present',
          );
        }
        const existingAttribute = existingAttributes?.length
          ? existingAttributes[0]
          : null;

        dialogAttribute = {
          control: 'text',
          textValue: (existingAttribute?.text_value) ?? '',
          ...sharedProps,
        };
      } else {
        if (__DEV__) {
          invariant(
            !existingAttributes || (existingAttributes.length <= 1),
            'only one boolean attribute is supported at present',
          );
        }

        dialogAttribute = {
          control: 'checkbox',
          enabled: (existingAttributes?.length) === 1,
          ...sharedProps,
        };
      }
      dialogAttributes.push(dialogAttribute);
    }
  }

  dialogAttributes.sort((a, b) => (
    /*
     * The make the UI a bit cleaner, group attributes with the same
     * controls together (checkboxes first, then text attributes, then
     * multiselects).
     */
    ((DIALOG_ATTRIBUTE_ORDER[a.control] ?? 0) -
      (DIALOG_ATTRIBUTE_ORDER[b.control] ?? 0)) ||
    compare(a.type.l_name ?? '', b.type.l_name ?? '')
  ));

  return dialogAttributes;
}

export function createInitialState(
  linkType: LinkTypeT | null,
  existingAttributesByRootId: LinkAttributesByRootIdT | null,
): DialogAttributesStateT {
  const attributesList = createDialogAttributesList(
    linkType,
    existingAttributesByRootId,
  );
  return {
    attributesList,
    resultingLinkAttributes: getLinkAttributesFromState(attributesList),
  };
}

function getLinkAttributesFromState(
  attributesList: DialogAttributesT,
): tree.ImmutableTree<LinkAttrT> | null {
  return attributesList.reduce(
    (accum, attributeState) => {
      switch (attributeState.control) {
        case 'checkbox': {
          if (attributeState.enabled) {
            const linkAttributeType = attributeState.type;
            return tree.insert(
              accum, {
                type: {
                  gid: linkAttributeType.gid,
                },
                typeID: linkAttributeType.id,
                typeName: linkAttributeType.name,
              },
              compareLinkAttributes,
            );
          }
          break;
        }
        case 'multiselect': {
          let newAccum = accum;
          for (const valueAttribute of attributeState.values) {
            if (valueAttribute.removed) {
              continue;
            }
            const linkAttributeType =
              valueAttribute.autocomplete.selectedItem?.entity;
            if (linkAttributeType) {
              newAccum = tree.insertIfNotExists(
                newAccum, {
                  credited_as: clean(valueAttribute.creditedAs),
                  type: {
                    gid: linkAttributeType.gid,
                  },
                  typeID: linkAttributeType.id,
                  typeName: linkAttributeType.name,
                },
                compareLinkAttributes,
              );
            }
          }
          return newAccum;
        }
        case 'text': {
          const linkAttributeType = attributeState.type;
          const textValue = clean(attributeState.textValue);

          if (nonEmpty(textValue)) {
            return tree.insert(
              accum, {
                text_value: textValue,
                type: {
                  gid: linkAttributeType.gid,
                },
                typeID: linkAttributeType.id,
                typeName: linkAttributeType.name,
              },
              compareLinkAttributes,
            );
          }
          break;
        }
      }
      return accum;
    },
    null,
  );
}

export function reducer(
  state: DialogAttributesStateT,
  action: DialogAttributeActionT,
): DialogAttributesStateT {
  const newState: {...DialogAttributesStateT} = {...state};
  let updateResultingLinkAttributes = true;

  switch (action.type) {
    case 'update-boolean-attribute': {
      newState.attributesList = newState.attributesList.map((x) => {
        if (x.key === action.rootKey) {
          invariant(x.control === 'checkbox');
          return booleanAttributeReducer(x, action.action);
        }
        return x;
      });
      break;
    }
    case 'update-multiselect-attribute': {
      const subAction = action.action;
      if (subAction.type === 'update-value-autocomplete') {
        const autocompleteAction = subAction.action;
        if (
          autocompleteAction.type !== 'type-value' &&
          autocompleteAction.type !== 'select-item'
        ) {
          updateResultingLinkAttributes = false;
        }
      }
      newState.attributesList = newState.attributesList.map((x) => {
        if (x.key === action.rootKey) {
          invariant(x.control === 'multiselect');
          return multiselectAttributeReducer(x, subAction);
        }
        return x;
      });
      break;
    }
    case 'update-text-attribute': {
      newState.attributesList = newState.attributesList.map((x) => {
        if (x.key === action.rootKey) {
          invariant(x.control === 'text');
          return textAttributeReducer(x, action.action);
        }
        return x;
      });
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  if (updateResultingLinkAttributes) {
    const newResultingLinkAttributes = getLinkAttributesFromState(
      newState.attributesList,
    );
    if (
      !areLinkAttributesEqual(
        newState.resultingLinkAttributes,
        newResultingLinkAttributes,
      )
    ) {
      newState.resultingLinkAttributes = newResultingLinkAttributes;
    }
  }

  return newState;
}

const wrapAttributeElement = (
  attribute:
    | DialogBooleanAttributeStateT
    | DialogMultiselectAttributeStateT
    | DialogTextAttributeStateT,
  attributeElement: React.MixedElement,
  isHelpVisible: boolean,
): React.MixedElement => (
  <div
    className={
      'attribute-container ' +
      attribute.control + ' ' +
      kebabCase(attribute.type.name)
    }
    key={attribute.key}
  >
    {attributeElement}
    {attribute.error}
    {(
      isHelpVisible &&
      nonEmpty(attribute.type.l_description)
    ) ? (
      <div className="ar-descr">
        {expand2react(attribute.type.l_description)}
      </div>
      ) : null}
  </div>
);

const DialogAttributes = (React.memo<PropsT>(({
  dispatch,
  isHelpVisible,
  state,
}: PropsT): React.MixedElement | null => {
  const booleanAttributeDispatch = React.useCallback((rootKey, action) => {
    dispatch({
      action,
      rootKey,
      type: 'update-boolean-attribute',
    });
  }, [dispatch]);

  const multiselectAttributeDispatch = React.useCallback(
    (rootKey, action) => {
      dispatch({
        action,
        rootKey,
        type: 'update-multiselect-attribute',
      });
    },
    [dispatch],
  );

  const textAttributeDispatch = React.useCallback((rootKey, action) => {
    dispatch({
      action,
      rootKey,
      type: 'update-text-attribute',
    });
  }, [dispatch]);

  const attributesByControl: {
    checkbox: Array<[DialogBooleanAttributeStateT, React.MixedElement]>,
    multiselect: Array<[
      DialogMultiselectAttributeStateT,
      React.MixedElement,
    ]>,
    text: Array<[DialogTextAttributeStateT, React.MixedElement]>,
  } = {
    checkbox: [],
    multiselect: [],
    text: [],
  };

  for (const attribute of state.attributesList) {
    switch (attribute.control) {
      case 'checkbox': {
        attributesByControl.checkbox.push([
          attribute,
          wrapAttributeElement(
            attribute,
            <BooleanAttribute
              dispatch={booleanAttributeDispatch}
              state={attribute}
            />,
            isHelpVisible,
          ),
        ]);
        break;
      }
      case 'multiselect': {
        attributesByControl.multiselect.push([
          attribute,
          wrapAttributeElement(
            attribute,
            <MultiselectAttribute
              dispatch={multiselectAttributeDispatch}
              state={attribute}
            />,
            isHelpVisible,
          ),
        ]);
        break;
      }
      case 'text': {
        const inputId = 'text-attribute-' + String(attribute.type.id);
        attributesByControl.text.push([
          attribute,
          wrapAttributeElement(
            attribute,
            <TextAttribute
              dispatch={textAttributeDispatch}
              inputId={inputId}
              state={attribute}
            />,
            isHelpVisible,
          ),
        ]);
        break;
      }
    }
  }

  return (
    <>
      {attributesByControl.checkbox.map((
        [state, checkboxDiv],
      ) => (
        <tr key={state.type.id}>
          <td className="section" />
          <td className="fields">
            {checkboxDiv}
          </td>
        </tr>
      ))}
      {attributesByControl.text.map(([state, textDiv]) => (
        <tr key={state.type.id}>
          <td className="section">
            <label htmlFor={'text-attribute-' + String(state.type.id)}>
              {capitalize(state.type.l_name ?? state.type.name)}
            </label>
          </td>
          <td className="fields">
            {textDiv}
          </td>
        </tr>
      ))}
      {attributesByControl.multiselect.map(([state, multiselectDiv]) => (
        <tr key={state.type.id}>
          <td className="section">
            {capitalize(state.type.l_name ?? state.type.name)}
          </td>
          <td className="fields">
            {multiselectDiv}
          </td>
        </tr>
      ))}
    </>
  );
}): React.AbstractComponent<PropsT>);

export default DialogAttributes;
