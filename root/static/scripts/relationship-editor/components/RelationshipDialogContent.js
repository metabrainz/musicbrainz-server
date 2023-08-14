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

import invariant from '../../../../utility/invariant.js';
import {
  formatLinkTypePhrases,
} from '../../common/components/Autocomplete2/formatters.js';
import {
  filterStaticItems,
  resetPage as resetAutocompletePage,
} from '../../common/components/Autocomplete2/reducer.js';
import {
  indexItems,
} from '../../common/components/Autocomplete2/searchItems.js';
import {
  ARTIST_GROUP_TYPES,
  ARTIST_TYPE_PERSON,
} from '../../common/constants.js';
import {
  createNonUrlRelatableEntityObject,
  createUrlObject,
} from '../../common/entity2.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import MB from '../../common/MB.js';
import bracketed from '../../common/utility/bracketed.js';
import clean from '../../common/utility/clean.js';
import {
  performReactUpdateAndMaintainFocus,
} from '../../common/utility/focusManagement.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {
  isLinkTypeOrderableByUser,
} from '../../common/utility/isLinkTypeDirectionOrderable.js';
import {
  RelationshipSourceGroupsContext,
} from '../constants.js';
import useDialogEnterKeyHandler from '../hooks/useDialogEnterKeyHandler.js';
import useRangeSelectionHandler from '../hooks/useRangeSelectionHandler.js';
import type {
  DialogAttributesStateT,
  DialogDatePeriodStateT,
  ExternalLinkAttrT,
  LinkAttributesByRootIdT,
  RelationshipDialogStateT,
  RelationshipStateT,
  TargetTypeOptionsT,
} from '../types.js';
import type {
  DialogActionT,
  DialogAttributeActionT,
  DialogEntityCreditActionT,
  DialogLinkTypeActionT,
  DialogTargetEntityActionT,
  UpdateRelationshipActionT,
} from '../types/actions.js';
import {
  findExistingRelationship,
  findTargetTypeGroups,
} from '../utility/findState.js';
import getDialogLinkTypeOptions from '../utility/getDialogLinkTypeOptions.js';
import getOpenEditsLink from '../utility/getOpenEditsLink.js';
import getRelationshipEditStatus
  from '../utility/getRelationshipEditStatus.js';
import getRelationshipKey from '../utility/getRelationshipKey.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';

import DialogAttributes, {
  createInitialState as createDialogAttributesState,
  reducer as dialogAttributesReducer,
} from './DialogAttributes.js';
import DialogButtons from './DialogButtons.js';
import DialogDatePeriod, {
  type ActionT as DialogDatePeriodActionT,
  createInitialState as createDialogDatePeriodState,
  updateDialogDatePeriodState,
} from './DialogDatePeriod.js';
import DialogLinkOrder from './DialogLinkOrder.js';
import DialogLinkType, {
  createInitialState as createDialogLinkTypeState,
  extractLinkTypeSearchTerms,
  updateDialogAttributesStateForLinkType,
  updateDialogState as updateDialogLinkTypeState,
} from './DialogLinkType.js';
import DialogPreview from './DialogPreview.js';
import DialogSourceEntity, {
  createInitialState as createDialogSourceEntityState,
  getSourceError,
  reducer as dialogSourceEntityReducer,
} from './DialogSourceEntity.js';
import DialogTargetEntity, {
  createInitialAutocompleteStateForTarget,
  createInitialState as createDialogTargetEntityState,
  getTargetError,
  isTargetSelectable,
  reducer as dialogTargetEntityReducer,
  updateTargetAutocomplete,
} from './DialogTargetEntity.js';
import DialogTargetType from './DialogTargetType.js';

export type PropsT = {
  +batchSelectionCount?: number,
  +closeDialog: () => void,
  +hasPreselectedTargetType: boolean,
  +initialRelationship: RelationshipStateT,
  +releaseHasUnloadedTracks: boolean,
  +source: RelatableEntityT,
  +sourceDispatch: (UpdateRelationshipActionT) => void,
  +targetTypeOptions: TargetTypeOptionsT | null,
  +targetTypeRef: {-current: RelatableEntityTypeT} | null,
  +title: string,
  +user: ActiveEditorT,
};

const FONT_WEIGHT_NORMAL = {fontWeight: 'normal'};

function accumulateRelationshipLinkAttributeByRootId(
  result: LinkAttributesByRootIdT,
  linkAttribute: LinkAttrT | ExternalLinkAttrT,
) {
  const attributeType =
    linkedEntities.link_attribute_type[linkAttribute.type.gid];
  const rootId = attributeType.root_id;

  let children = result.get(rootId);
  if (children == null) {
    children = [];
    result.set(rootId, children);
  }

  children.push({
    credited_as: linkAttribute.credited_as,
    text_value: linkAttribute.text_value,
    type: attributeType,
  });
  return result;
}

function getAttributeRootIdMap(
  attributes: $ReadOnlyArray<LinkAttrT | ExternalLinkAttrT>,
): LinkAttributesByRootIdT {
  return attributes.reduce<LinkAttributesByRootIdT>(
    accumulateRelationshipLinkAttributeByRootId,
    new Map(),
  );
}

export function createInitialState(props: PropsT): RelationshipDialogStateT {
  const relationship = props.initialRelationship;
  const source = props.source;
  const backward = isRelationshipBackward(relationship, source);
  const sourceType = source.entityType;
  const targetType = backward
    ? relationship.entity0.entityType
    : relationship.entity1.entityType;
  const linkTypeOptions = getDialogLinkTypeOptions(
    source,
    targetType,
  );
  const linkType = getRelationshipLinkType(relationship) ?? (
    linkTypeOptions.length === 1
      ? linkTypeOptions[0].entity
      : null
  ) ?? null;

  return {
    attributes: createDialogAttributesState(
      linkType,
      getAttributeRootIdMap(tree.toArray(relationship.attributes)),
    ),
    backward,
    datePeriod: createDialogDatePeriodState(relationship),
    isHelpVisible: false,
    linkOrder: relationship.linkOrder,
    linkType: createDialogLinkTypeState(
      linkType,
      source,
      targetType,
      linkTypeOptions,
      getRelationshipKey(relationship),
      false,
    ),
    sourceEntity: createDialogSourceEntityState(
      props.releaseHasUnloadedTracks,
      sourceType,
      relationship,
      source,
    ),
    targetEntity: createDialogTargetEntityState(
      props.user,
      props.releaseHasUnloadedTracks,
      source,
      relationship,
      props.targetTypeOptions,
    ),
  };
}

/*
 * Possibly updates newState.backward based on the source and target
 * entities and the link type. The link direction is updated only in
 * cases where the correct value can be inferred, e.g. "member of"
 * relationships between person and group artist entities. See MBS-2604.
 */
function inferLinkDirection(
  newState: {...RelationshipDialogStateT},
  source: RelatableEntityT,
): void {
  const target = newState.targetEntity.target;
  const linkTypeId =
    newState.linkType.autocomplete.selectedItem?.entity?.id ?? null;

  if (
    source.entityType === 'artist' &&
    target.entityType === 'artist' &&
    linkTypeId !== null &&
    personGroupLinkTypeIds.has(linkTypeId)
  ) {
    const isSourcePerson = source.typeID === ARTIST_TYPE_PERSON;
    const isSourceGroup =
      source.typeID !== null && ARTIST_GROUP_TYPES.has(source.typeID);

    const isTargetPerson = target.typeID === ARTIST_TYPE_PERSON;
    const isTargetGroup =
      target.typeID !== null && ARTIST_GROUP_TYPES.has(target.typeID);


    if (isSourcePerson && isTargetGroup) {
      newState.backward = false;
    } else if (isSourceGroup && isTargetPerson) {
      newState.backward = true;
    }
  }
}

// Link types for artist-artist relationships between people and groups.
const personGroupLinkTypeIds = new Set([
  53, // collaborator
  103, // member
  305, // conductor
  855, // composer-in-residence
  895, // founder
  965, // artistic director
]);

function updateDialogStateForTargetTypeChange(
  newState: {...RelationshipDialogStateT},
  oldTargetType: RelatableEntityTypeT,
  newTargetType: RelatableEntityTypeT,
  source: RelatableEntityT,
): void {
  /*
   * This function handles updating the available link type options,
   * attributes, the direction, and the source error when the target type
   * changes. Note that it doesn't update the target entity at all, as it's
   * used from both the `update-target-entity` and `update-target-type`
   * actions; those each handle updating the target entity on their own
   * in different ways.
   */
  const sourceType = source.entityType;
  const newLinkTypeOptions = getDialogLinkTypeOptions(
    source,
    newTargetType,
  );

  indexItems(newLinkTypeOptions, extractLinkTypeSearchTerms);

  const onlyLinkType = newLinkTypeOptions.length === 1
    ? newLinkTypeOptions[0].entity
    : null;

  const oldLinkTypeAutocompleteState = newState.linkType.autocomplete;
  const newLinkTypeAutocompleteState = {
    ...oldLinkTypeAutocompleteState,
    inputValue: onlyLinkType
      ? formatLinkTypePhrases(onlyLinkType)
      : (
        oldLinkTypeAutocompleteState.selectedItem
          ? ''
          : oldLinkTypeAutocompleteState.inputValue
      ),
    recentItems: null,
    recentItemsKey: 'link_type-' + sourceType + '-' + newTargetType,
    results: newLinkTypeOptions,
    selectedItem: onlyLinkType ? {
      entity: onlyLinkType,
      id: onlyLinkType.id,
      name: l_relationships(onlyLinkType.name),
      type: 'option',
    } : null,
    staticItems: newLinkTypeOptions,
  };
  filterStaticItems<LinkTypeT>(
    newLinkTypeAutocompleteState,
    newLinkTypeAutocompleteState.inputValue,
  );
  resetAutocompletePage<LinkTypeT>(newLinkTypeAutocompleteState);

  newState.linkType = {
    ...newState.linkType,
    autocomplete: newLinkTypeAutocompleteState,
  };

  updateDialogAttributesStateForLinkType(
    newState,
    onlyLinkType,
  );

  newState.backward = sourceType > newTargetType;

  newState.sourceEntity = {
    ...newState.sourceEntity,
    error: getSourceError(source, null),
  };
}

export function reducer(
  state: RelationshipDialogStateT,
  action: DialogActionT,
): RelationshipDialogStateT {
  const newState: {...RelationshipDialogStateT} = {...state};

  switch (action.type) {
    case 'change-direction': {
      newState.backward = !state.backward;
      break;
    }

    /*
     * This action is not used internally, and only implemented for
     * userscripts.
     */
    case 'set-attributes': {
      newState.attributes = createDialogAttributesState(
        (state.linkType.autocomplete.selectedItem?.entity) ?? null,
        getAttributeRootIdMap(action.attributes),
      );
      break;
    }

    case 'toggle-help': {
      newState.isHelpVisible = !state.isHelpVisible;
      break;
    }

    case 'update-source-entity': {
      newState.sourceEntity =
        dialogSourceEntityReducer(newState.sourceEntity, action.action);
      break;
    }

    case 'update-target-entity': {
      newState.targetEntity =
        dialogTargetEntityReducer(newState.targetEntity, action.action);

      const oldTargetType = state.targetEntity.targetType;
      const newTargetType = newState.targetEntity.targetType;

      if (oldTargetType !== newTargetType) {
        updateDialogStateForTargetTypeChange(
          newState,
          oldTargetType,
          newTargetType,
          action.source,
        );
      }

      /*
       * Avoid unnecessary calls when update-target-entity actions are
       * mysteriously dispatched even when the target didn't change, e.g.
       * a null-to-null update when clicking the artist selector.
       */
      const oldTargetGid = state.targetEntity.target.gid;
      const newTargetGid = newState.targetEntity.target.gid;
      if (oldTargetGid !== newTargetGid) {
        inferLinkDirection(newState, action.source);
      }

      break;
    }

    case 'update-target-type': {
      const newTargetState = {...newState.targetEntity};

      const oldTargetType = newTargetState.targetType;
      const newTargetType = action.targetType;

      newTargetState.targetType = newTargetType;

      updateDialogStateForTargetTypeChange(
        newState,
        oldTargetType,
        newTargetType,
        action.source,
      );

      if (
        oldTargetType === 'url' &&
        newTargetType !== 'url'
      ) {
        const newPlaceholderTarget =
          createNonUrlRelatableEntityObject(newTargetType);

        newTargetState.autocomplete = createInitialAutocompleteStateForTarget(
          newPlaceholderTarget,
          newTargetState.relationshipId,
          newTargetState.allowedTypes,
        );
        newTargetState.target = newPlaceholderTarget;
        newTargetState.error = getTargetError(
          newPlaceholderTarget,
          action.source,
          null,
        );
      } else if (
        newTargetType === 'url' &&
        oldTargetType !== 'url'
      ) {
        newTargetState.autocomplete = null;
        newTargetState.target = createUrlObject();
        newTargetState.error = '';
      } else if (newTargetType !== 'url') {
        updateTargetAutocomplete(newTargetState, {
          action: {
            entityType: newTargetType,
            type: 'change-entity-type',
          },
          linkType: null,
          source: action.source,
          type: 'update-autocomplete',
        });
      }

      newTargetState.creditedAs = '';

      newState.targetEntity = newTargetState;
      break;
    }

    case 'update-link-order': {
      newState.linkOrder = action.newLinkOrder;
      break;
    }

    case 'update-link-type': {
      const linkTypeChanged = updateDialogLinkTypeState(
        state,
        newState,
        action,
      );

      if (linkTypeChanged) {
        newState.sourceEntity = {
          ...newState.sourceEntity,
          error: getSourceError(action.source, null),
        };
        inferLinkDirection(newState, action.source);
      }

      break;
    }

    case 'update-attribute': {
      newState.attributes = dialogAttributesReducer(
        newState.attributes,
        action.action,
      );
      break;
    }

    case 'update-date-period': {
      newState.datePeriod = updateDialogDatePeriodState(
        newState.datePeriod,
        action.action,
      );
      break;
    }

    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  return newState;
}

type AttributesSectionPropsT = {
  +attributesState: DialogAttributesStateT,
  +canEditDates: boolean,
  +datePeriod: DialogDatePeriodStateT,
  +dispatch: (DialogActionT) => void,
  +isHelpVisible: boolean,
};

const AttributesSection = (React.memo<AttributesSectionPropsT>(({
  attributesState,
  canEditDates,
  datePeriod,
  dispatch,
  isHelpVisible,
}) => {
  const attributesDispatch = React.useCallback((
    action: DialogAttributeActionT,
  ) => {
    dispatch({action, type: 'update-attribute'});
  }, [dispatch]);

  const dateDispatch = React.useCallback((
    action: DialogDatePeriodActionT,
  ) => {
    dispatch({action, type: 'update-date-period'});
  }, [dispatch]);

  const booleanRangeSelectionHandler =
    useRangeSelectionHandler('boolean');

  return (attributesState.attributesList.length || canEditDates) ? (
    <>
      <h2>
        <div className="heading-line" />
        <span className="heading-text">
          {l('Attributes')}
        </span>
      </h2>
      <table className="relationship-details">
        <tbody onClick={booleanRangeSelectionHandler}>
          {attributesState.attributesList.length ? (
            <DialogAttributes
              dispatch={attributesDispatch}
              isHelpVisible={isHelpVisible}
              state={attributesState}
            />
          ) : null}
          {canEditDates ? (
            <DialogDatePeriod
              dispatch={dateDispatch}
              isHelpVisible={isHelpVisible}
              state={datePeriod}
            />
          ) : null}
        </tbody>
      </table>
    </>
  ) : null;
}): React$AbstractComponent<AttributesSectionPropsT, mixed>);

const RelationshipDialogContent = (React.memo<PropsT>((
  props: PropsT,
): React$MixedElement => {
  const {
    batchSelectionCount,
    closeDialog,
    hasPreselectedTargetType,
    initialRelationship,
    sourceDispatch,
    source,
    targetTypeOptions,
    targetTypeRef,
    title,
  } = props;

  const [state, dispatch] = React.useReducer(
    reducer,
    props,
    createInitialState,
  );

  // Expose internal state for userscripts.
  React.useEffect(() => {
    // $FlowIgnore[prop-missing]
    MB.relationshipEditor.relationshipDialogDispatch = dispatch;
    // $FlowIgnore[prop-missing]
    MB.relationshipEditor.relationshipDialogState = state;

    return () => {
      // $FlowIgnore[prop-missing]
      MB.relationshipEditor.relationshipDialogDispatch = null;
      // $FlowIgnore[prop-missing]
      MB.relationshipEditor.relationshipDialogState = null;
    };
  }, [dispatch, state]);

  const backward = state.backward;
  const linkTypeState = state.linkType;
  const selectedLinkType = linkTypeState.autocomplete.selectedItem?.entity;
  const sourceEntityState = state.sourceEntity;
  const targetEntityState = state.targetEntity;
  const selectedTargetEntity = targetEntityState.target;
  const targetType = targetEntityState.targetType;
  const datePeriodField = state.datePeriod.field;
  const attributesList = state.attributes.attributesList;

  const hasBlankRequiredFields = (
    linkTypeState.autocomplete.selectedItem == null ||
    !isTargetSelectable(targetEntityState.autocomplete?.selectedItem?.entity)
  );

  const hasErrors = !!(
    nonEmpty(linkTypeState.error) ||
    nonEmpty(sourceEntityState.error) ||
    targetEntityState.error ||
    attributesList.some(x => x.error) ||
    datePeriodField.errors?.length ||
    datePeriodField.field.begin_date.errors?.length ||
    datePeriodField.field.end_date.errors?.length
  );

  const hasPendingDateErrors = !!(
    datePeriodField.pendingErrors?.length ||
    datePeriodField.field.begin_date.pendingErrors?.length ||
    datePeriodField.field.end_date.pendingErrors?.length
  );

  React.useEffect(() => {
    /*
     * Save the currently-selected target type so that it can be
     * pre-selected in the future.
     */
    if (targetTypeRef) {
      targetTypeRef.current = targetType;
    }
  }, [targetTypeRef, targetType]);

  /*
   * `newRelationshipState` memoizes the complete relationship to be added.
   * If there are errors or incomplete data, it's null.
   */
  const newRelationshipState = React.useMemo(() => {
    if (hasBlankRequiredFields || hasErrors) {
      return null;
    }

    if (selectedTargetEntity) {
      invariant(
        selectedTargetEntity.entityType === targetType,
        'The selected entity does not have type ' +
        JSON.stringify(targetType),
      );
    }

    const linkTypeId = selectedLinkType ? selectedLinkType.id : null;
    const targetId = selectedTargetEntity ? selectedTargetEntity.id : null;

    if (linkTypeId == null || targetId == null) {
      return null;
    }

    const sourceCredit = clean(sourceEntityState.creditedAs);
    const targetCredit = clean(targetEntityState.creditedAs);
    let entity0Credit = '';
    let entity1Credit = '';
    if (backward) {
      entity0Credit = targetCredit;
      entity1Credit = sourceCredit;
    } else {
      entity1Credit = targetCredit;
      entity0Credit = sourceCredit;
    }

    const newRelationship: {...RelationshipStateT} = {
      ...initialRelationship,
      _lineage: initialRelationship._lineage.length
        ? [...initialRelationship._lineage, 'edited']
        : ['added'],
      ...state.datePeriod.result,
      attributes: state.attributes.resultingLinkAttributes,
      entity0_credit: entity0Credit,
      entity1_credit: entity1Credit,
      linkOrder: state.linkOrder,
      linkTypeID: linkTypeId,
    };

    newRelationship.entity0 = backward ? selectedTargetEntity : source;
    newRelationship.entity1 = backward ? source : selectedTargetEntity;
    newRelationship._status = getRelationshipEditStatus(
      newRelationship,
    );

    return newRelationship;
  }, [
    backward,
    hasBlankRequiredFields,
    hasErrors,
    initialRelationship,
    selectedLinkType,
    selectedTargetEntity,
    source,
    state.attributes.resultingLinkAttributes,
    state.linkOrder,
    state.datePeriod.result,
    sourceEntityState.creditedAs,
    targetEntityState.creditedAs,
    targetType,
  ]);

  const sourceGroupsContext =
    React.useContext(RelationshipSourceGroupsContext);

  const relationshipAlreadyExists = React.useMemo(() => {
    if (newRelationshipState) {
      for (const contextProp of ['pending', 'existing']) {
        const existingRelationship = findExistingRelationship(
          findTargetTypeGroups(
            sourceGroupsContext[contextProp],
            source,
          ),
          newRelationshipState,
          source,
        );
        if (
          existingRelationship &&
          existingRelationship.id !== newRelationshipState.id
        ) {
          return true;
        }
      }
    }
    return false;
  }, [
    sourceGroupsContext,
    newRelationshipState,
    source,
  ]);

  const formDivRef = React.useRef<HTMLDivElement | null>(null);

  const closeDialogWithEvent = React.useCallback((
    eventType: 'accept' | 'cancel',
  ) => {
    const formDiv = formDivRef.current;
    if (formDiv) {
      const event =
        new Event('mb-close-relationship-dialog', {bubbles: true});
      // $FlowIgnore[prop-missing]
      event.closeEventType = eventType;
      // $FlowIgnore[prop-missing]
      event.dialogState = state;
      formDiv.dispatchEvent(event);
    }
    closeDialog();
  }, [closeDialog, state]);

  const acceptDialog = React.useCallback(() => {
    if (!(
      newRelationshipState &&
      selectedLinkType &&
      selectedTargetEntity &&
      !relationshipAlreadyExists
    )) {
      return;
    }

    if (hasPendingDateErrors) {
      dispatch({
        action: {
          action: {type: 'show-pending-errors'},
          type: 'update-begin-date',
        },
        type: 'update-date-period',
      });
      dispatch({
        action: {
          action: {type: 'show-pending-errors'},
          type: 'update-end-date',
        },
        type: 'update-date-period',
      });
      return;
    }

    invariant(
      backward
        ? (selectedLinkType.type0 === selectedTargetEntity.entityType &&
            selectedLinkType.type1 === source.entityType)
        : (selectedLinkType.type0 === source.entityType &&
            selectedLinkType.type1 === selectedTargetEntity.entityType),
      'The selected link type is invalid for these entity types',
    );

    const doAccept = function () {
      sourceDispatch({
        batchSelectionCount,
        creditsToChangeForSource: sourceEntityState.creditsToChange,
        creditsToChangeForTarget: targetEntityState.creditsToChange,
        newRelationshipState,
        oldRelationshipState: initialRelationship,
        sourceEntity: source,
        type: 'update-relationship-state',
      });
      closeDialogWithEvent('accept');
    };

    if (isDatabaseRowId(initialRelationship.id)) {
      performReactUpdateAndMaintainFocus(
        'edit-relationship-' + getRelationshipKey(initialRelationship),
        doAccept,
      );
    } else {
      doAccept();
    }
  }, [
    backward,
    batchSelectionCount,
    hasPendingDateErrors,
    relationshipAlreadyExists,
    selectedLinkType,
    selectedTargetEntity,
    source,
    sourceDispatch,
    sourceEntityState.creditsToChange,
    targetEntityState.creditsToChange,
    initialRelationship,
    newRelationshipState,
    closeDialogWithEvent,
  ]);

  const cancelDialog = React.useCallback(() => {
    closeDialogWithEvent('cancel');
  }, [closeDialogWithEvent]);

  const sourceEntityDispatch = React.useCallback((
    action: DialogEntityCreditActionT,
  ) => {
    dispatch({action, type: 'update-source-entity'});
  }, [dispatch]);

  const targetEntityDispatch = React.useCallback((
    action: DialogTargetEntityActionT,
  ) => {
    dispatch({
      action,
      source,
      type: 'update-target-entity',
    });
  }, [dispatch, source]);

  const linkTypeDispatch = React.useCallback((
    action: DialogLinkTypeActionT,
  ) => {
    dispatch({action, source, type: 'update-link-type'});
  }, [dispatch, source]);

  const openEditsLink = (
    initialRelationship._original &&
    initialRelationship?.editsPending
  ) ? getOpenEditsLink(initialRelationship._original) : null;

  const handleHelpClick = React.useCallback((
    event: SyntheticEvent<HTMLAnchorElement>,
  ) => {
    event.preventDefault();
    dispatch({
      type: 'toggle-help',
    });
  }, [dispatch]);

  const handleKeyDown = useDialogEnterKeyHandler(acceptDialog);

  const canEditDates = selectedLinkType != null &&
    selectedLinkType.has_dates;

  return (
    <div
      className="form"
      onKeyDown={handleKeyDown}
      ref={formDivRef}
    >
      <div className="dialog-titlebar">
        <h1>
          {title}
        </h1>
        <div className="buttons-right">
          <span style={FONT_WEIGHT_NORMAL}>
            {bracketed(
              <a href="#" onClick={handleHelpClick}>
                {l('help')}
              </a>,
            )}
          </span>
        </div>
      </div>

      {batchSelectionCount == null ? null : (
        <p>
          {getBatchSelectionMessage(source.entityType)}
        </p>
      )}

      {openEditsLink == null ? null : (
        <p className="msg warning">
          {exp.l(
            `Warning: This relationship has pending edits. {show|Click here}
             to view these edits and make sure they do not conflict with
             your own.`,
            {
              show: {
                href: openEditsLink,
                target: '_blank',
              },
            },
          )}
        </p>
      )}
      <table className="relationship-details">
        <tbody>
          <DialogSourceEntity
            backward={backward}
            batchSelectionCount={batchSelectionCount}
            dispatch={sourceEntityDispatch}
            linkType={selectedLinkType}
            source={source}
            state={sourceEntityState}
            targetType={targetType}
          />
          <DialogTargetType
            dispatch={dispatch}
            hasPreselectedTargetType={hasPreselectedTargetType}
            options={targetTypeOptions}
            source={source}
            targetType={targetEntityState.targetType}
          />
        </tbody>
      </table>
      <h2>
        <div className="heading-line" />
        <span className="heading-text">
          {l('Relationship')}
        </span>
      </h2>
      <table className="relationship-details">
        <tbody>
          <DialogLinkType
            dispatch={linkTypeDispatch}
            isHelpVisible={state.isHelpVisible}
            source={source}
            state={linkTypeState}
            targetType={targetEntityState.targetType}
          />
          <DialogTargetEntity
            allowedTypes={targetTypeOptions}
            backward={backward}
            dispatch={targetEntityDispatch}
            linkType={selectedLinkType}
            source={source}
            state={targetEntityState}
          />
          {(
            selectedLinkType &&
            isLinkTypeOrderableByUser(selectedLinkType.id, source, backward)
          ) ? (
            <DialogLinkOrder
              dispatch={dispatch}
              linkOrder={state.linkOrder}
            />
            ) : null}
        </tbody>
      </table>
      <AttributesSection
        attributesState={state.attributes}
        canEditDates={canEditDates}
        datePeriod={state.datePeriod}
        dispatch={dispatch}
        isHelpVisible={state.isHelpVisible}
      />
      {source ? (
        <DialogPreview
          backward={backward}
          batchSelectionCount={batchSelectionCount}
          dispatch={dispatch}
          newRelationship={newRelationshipState}
          oldRelationship={initialRelationship._original}
          source={source}
        />
      ) : null}
      {relationshipAlreadyExists ? (
        <p className="error">
          {l('This relationship already exists.')}
        </p>
      ) : null}
      <DialogButtons
        isDoneDisabled={(
          hasBlankRequiredFields ||
          hasErrors ||
          hasPendingDateErrors ||
          relationshipAlreadyExists
        )}
        onCancel={cancelDialog}
        onDone={acceptDialog}
      />
    </div>
  );
}): React$AbstractComponent<PropsT, mixed>);

function getBatchSelectionMessage(sourceType: RelatableEntityTypeT) {
  switch (sourceType) {
    case 'recording': {
      return l('This will add a relationship to all checked recordings.');
    }
    case 'work': {
      return l('This will add a relationship to all checked works.');
    }
  }
  return '';
}

export default RelationshipDialogContent;
