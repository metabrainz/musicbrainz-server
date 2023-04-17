/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Autocomplete2, {
  createInitialState as createInitialAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import {
  formatLinkTypePhrases,
} from '../../common/components/Autocomplete2/formatters.js';
import {
  default as autocompleteReducer,
} from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  OptionItemT as AutocompleteOptionItemT,
  PropsT as AutocompletePropsT,
} from '../../common/components/Autocomplete2/types.js';
import {PART_OF_SERIES_LINK_TYPE_IDS} from '../../common/constants.js';
import expand2react from '../../common/i18n/expand2react.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import isBlank from '../../common/utility/isBlank.js';
import {stripAttributes} from '../../edit/utility/linkPhrase.js';
import type {
  DialogAttributesStateT,
  DialogAttributeT,
  DialogLinkTypeStateT,
  LinkAttributesByRootIdT,
} from '../types.js';
import type {
  DialogLinkTypeActionT,
} from '../types/actions.js';

import {
  createInitialState as createDialogAttributesState,
} from './DialogAttributes.js';

type PropsT = {
  +dispatch: (DialogLinkTypeActionT) => void,
  +isHelpVisible: boolean,
  +source: RelatableEntityT,
  +state: DialogLinkTypeStateT,
  +targetType: RelatableEntityTypeT,
};

function getLinkTypeError(
  linkType: ?LinkTypeT,
  source: RelatableEntityT,
): React$Node {
  if (!linkType) {
    /*
     * Blank fields are handled specially in the dialog (grep
     * `hasBlankRequiredFields`).  To avoid overwhelming the user with
     * "required field" errors, we only highlight the fields red.
     */
    return '';
  } else if (!linkType.description) {
    return l(
      `Please select a subtype of the currently selected relationship
       type. The selected relationship type is only used for grouping
       subtypes.`,
    );
  } else if (linkType.deprecated) {
    return l(
      `This relationship type is deprecated and should not be used.`,
    );
  }
  if (
    source.entityType === 'series' &&
    PART_OF_SERIES_LINK_TYPE_IDS.includes(linkType.id)
  ) {
    const seriesType = source.typeID == null
      ? null
      : linkedEntities.series_type['' + source.typeID];
    if (seriesType) {
      const itemEntityTypeOfLinkType = linkType.type0 === 'series'
        ? linkType.type1
        : linkType.type0;
      if (seriesType.item_entity_type !== itemEntityTypeOfLinkType) {
        return l(
          `This relationship type is not allowed with the current
           series type.`,
        );
      }
    }
  }
  return '';
}

export function extractLinkTypeSearchTerms(
  item: AutocompleteOptionItemT<LinkTypeT>,
): Array<string> {
  const entity = item.entity;
  return [
    entity.l_name ?? '',
    stripAttributes(entity, entity.l_link_phrase ?? ''),
    stripAttributes(entity, entity.l_reverse_link_phrase ?? ''),
  ];
}

export function createInitialState(
  linkType: LinkTypeT | null,
  source: RelatableEntityT,
  targetType: RelatableEntityTypeT,
  linkTypeOptions: $ReadOnlyArray<AutocompleteOptionItemT<LinkTypeT>>,
  id: string,
  disabled?: boolean = false,
): DialogLinkTypeStateT {
  return {
    autocomplete: createInitialAutocompleteState<LinkTypeT>({
      containerClass: 'relationship-type',
      disabled,
      entityType: 'link_type',
      extractSearchTerms: extractLinkTypeSearchTerms,
      id: 'relationship-type-' + id,
      inputClass: 'relationship-type' +
        (linkType == null ? ' focus-first' : ''),
      inputValue: linkType == null ? '' : formatLinkTypePhrases(linkType),
      placeholder: l('Type or click to search'),
      recentItemsKey: 'link_type-' + source.entityType + '-' + targetType,
      required: true,
      selectedItem: linkType ? {
        entity: linkType,
        id: linkType.id,
        name: l_relationships(linkType.name),
        type: 'option',
      } : null,
      staticItems: linkTypeOptions,
    }),
    error: getLinkTypeError(linkType, source),
  };
}

function reducer(
  state: DialogLinkTypeStateT,
  action: DialogLinkTypeActionT,
): DialogLinkTypeStateT {
  const newState: {...DialogLinkTypeStateT} = {...state};

  switch (action.type) {
    case 'update-autocomplete': {
      newState.autocomplete = autocompleteReducer(
        state.autocomplete,
        action.action,
      );

      const linkType = newState.autocomplete.selectedItem?.entity;

      newState.error = getLinkTypeError(linkType, action.source);
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  return newState;
}

type PartialDialogStateT = {
  +attributes: DialogAttributesStateT,
  +linkType: DialogLinkTypeStateT,
  ...
};

export function updateDialogState(
  oldState: PartialDialogStateT,
  newState: {...PartialDialogStateT, ...},
  action: {
    +action: DialogLinkTypeActionT,
    +source: RelatableEntityT,
    +type: 'update-link-type',
  },
): boolean {
  newState.linkType =
    reducer(newState.linkType, action.action);

  const oldLinkType = oldState.linkType.autocomplete.selectedItem?.entity;
  const newLinkType = newState.linkType.autocomplete.selectedItem?.entity;

  if (oldLinkType !== newLinkType) {
    updateDialogAttributesStateForLinkType(newState, newLinkType ?? null);
    return true;
  }

  return false;
}

export function updateDialogAttributesStateForLinkType(
  newState: {...PartialDialogStateT, ...},
  newLinkType: LinkTypeT | null,
): void {
  newState.attributes = createDialogAttributesState(
    newLinkType ?? null,
    newState.attributes.attributesList
      .reduce<LinkAttributesByRootIdT>(
        accumulateDialogAttributeByRootId,
        new Map(),
      ),
  );
}

function accumulateDialogAttributeByRootId(
  result: LinkAttributesByRootIdT,
  dialogAttribute: DialogAttributeT,
) {
  const root = dialogAttribute.type;
  const rootId = root.id;

  invariant(rootId === root.root_id);

  let children = result.get(rootId);
  if (children == null) {
    children = [];
    result.set(rootId, children);
  }

  switch (dialogAttribute.control) {
    case 'multiselect': {
      for (const valueAttribute of dialogAttribute.values) {
        if (valueAttribute.removed) {
          continue;
        }
        children.push({
          credited_as: valueAttribute.creditedAs,
          type: (valueAttribute.autocomplete.selectedItem?.entity) ?? null,
        });
      }
      break;
    }
    case 'checkbox': {
      if (dialogAttribute.enabled) {
        children.push({
          type: dialogAttribute.type,
        });
      }
      break;
    }
    case 'text': {
      if (!isBlank(dialogAttribute.textValue)) {
        children.push({
          text_value: dialogAttribute.textValue,
          type: dialogAttribute.type,
        });
      }
      break;
    }
  }

  return result;
}

// XXX Until Flow supports https://github.com/facebook/flow/issues/7672
const LinkTypeAutocomplete:
  React$AbstractComponent<AutocompletePropsT<LinkTypeT>, void> =
  // $FlowIgnore
  Autocomplete2;

const DialogLinkType = (React.memo<PropsT>(({
  dispatch,
  isHelpVisible,
  source,
  state,
  targetType,
}: PropsT): React$Element<'tr'> => {
  const {
    autocomplete,
    error,
  } = state;

  const autocompleteDispatch = React.useCallback((
    action: AutocompleteActionT<LinkTypeT>,
  ) => {
    dispatch({
      action,
      source,
      type: 'update-autocomplete',
    });
  }, [dispatch, source]);

  const linkType = autocomplete.selectedItem?.entity;

  return (
    <tr>
      <td className="required section">
        {l('Relationship type')}
      </td>
      <td className="fields">
        <LinkTypeAutocomplete
          dispatch={autocompleteDispatch}
          state={autocomplete}
        />
        <div aria-atomic="true" className="error" role="alert">
          {error}
        </div>
        {isHelpVisible ? (
          <div className="ar-descr">
            {linkType === undefined ? (
              <>
                {exp.l(
                  `Please select a relationship type.
                   ({url|more documentation})`,
                  {
                    url: {
                      href: '/relationships/' +
                       [source.entityType, targetType].sort().join('-'),
                      target: '_blank',
                    },
                  },
                )}
              </>
            ) : (
              <>
                {exp.l('{description} ({url|more documentation})', {
                  description: expand2react(linkType?.l_description ?? ''),
                  url: {
                    href: '/relationship/' + linkType.gid,
                    target: '_blank',
                  },
                })}
              </>
            )}
          </div>
        ) : null}
      </td>
    </tr>
  );
}): React$AbstractComponent<PropsT, mixed>);

export default DialogLinkType;
