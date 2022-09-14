/*
 * @flow strict-local
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
import bracketed from '../../common/utility/bracketed.js';
import clean from '../../common/utility/clean.js';
import {uniqueId} from '../../common/utility/numbers.js';
import type {
  DialogAttributeT,
  DialogAttributesT,
  DialogAttributesStateT,
  LinkAttributesByRootIdT,
} from '../types.js';
import type {
  DialogUpdateAttributeActionT,
} from '../types/actions.js';
import {
  areLinkAttributesEqual,
  compareLinkAttributeIds,
} from '../utility/compareRelationships.js';

import BooleanAttribute, {
  reducer as booleanAttributeReducer,
} from './DialogAttribute/BooleanAttribute.js';
import MultiselectAttribute, {
  reducer as multiselectAttributeReducer,
  createMultiselectAttributeValue,
} from './DialogAttribute/MultiselectAttribute.js';
import TextAttribute, {
  reducer as textAttributeReducer,
} from './DialogAttribute/TextAttribute.js';

type PropsT = {
  +dispatch: (DialogUpdateAttributeActionT) => void,
  +state: $ReadOnly<{...DialogAttributesStateT, ...}>,
};

const DIALOG_ATTRIBUTE_ORDER = {
  checkbox: 1,
  multiselect: 3,
  text: 2,
};

export function createDialogAttributesList(
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

export function getLinkAttributesFromState(
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
              compareLinkAttributeIds,
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
                compareLinkAttributeIds,
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
              compareLinkAttributeIds,
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
  action: DialogUpdateAttributeActionT,
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

const DialogAttributes = (React.memo<PropsT>(({
  dispatch,
  state,
}: PropsT): React.MixedElement | null => {
  const [
    isAttributesHelpVisible,
    setAttributesHelpVisible,
  ] = React.useState(false);

  function handleHelpClick(event: SyntheticEvent<HTMLAnchorElement>) {
    event.preventDefault();
    setAttributesHelpVisible(!isAttributesHelpVisible);
  }

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

  return state.attributesList.length ? (
    <tr>
      <td className="section">
        {l('Attributes')}
        <br />
        {bracketed(
          <a href="#" onClick={handleHelpClick}>
            {l('help')}
          </a>,
        )}
      </td>
      <td className="fields">
        {state.attributesList.map((attribute) => {
          let attributeElement;
          switch (attribute.control) {
            case 'checkbox': {
              attributeElement = (
                <BooleanAttribute
                  dispatch={booleanAttributeDispatch}
                  state={attribute}
                />
              );
              break;
            }
            case 'multiselect': {
              attributeElement = (
                <MultiselectAttribute
                  dispatch={multiselectAttributeDispatch}
                  state={attribute}
                />
              );
              break;
            }
            case 'text': {
              attributeElement = (
                <TextAttribute
                  dispatch={textAttributeDispatch}
                  state={attribute}
                />
              );
              break;
            }
          }

          return (
            <div
              className={'attribute-container ' + attribute.control}
              key={attribute.key}
            >
              {attributeElement}
              {attribute.error}
              {(
                isAttributesHelpVisible &&
                nonEmpty(attribute.type.l_description)
              ) ? (
                <div className="ar-descr">
                  {expand2react(attribute.type.l_description)}
                </div>
                ) : null}
            </div>
          );
        })}
      </td>
    </tr>
  ) : null;
}): React.AbstractComponent<PropsT>);

export default DialogAttributes;
