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
  filterStaticItems,
  resetPage as resetAutocompletePage,
} from '../../common/components/Autocomplete2/reducer.js';
import {
  indexItems,
} from '../../common/components/Autocomplete2/searchItems.js';
import {
  createNonUrlCoreEntityObject,
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
  partialDateFromField,
  reducer as dateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import {
  createCompoundField,
  createField,
} from '../../edit/utility/createField.js';
import {
  RelationshipSourceGroupsContext,
} from '../constants.js';
import useRangeSelectionHandler from '../hooks/useRangeSelectionHandler.js';
import type {
  DialogAttributesStateT,
  ExternalLinkAttrT,
  LinkAttributesByRootIdT,
  RelationshipDialogStateT,
  RelationshipStateT,
  TargetTypeOptionsT,
} from '../types.js';
import type {
  DialogActionT,
  UpdateRelationshipActionT,
} from '../types/actions.js';
import {
  findExistingRelationship,
  findTargetTypeGroups,
} from '../utility/findState.js';
import getDialogLinkTypeOptions from '../utility/getDialogLinkTypeOptions.js';
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
import DialogDatePeriod from './DialogDatePeriod.js';
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
  reducer as dialogTargetEntityReducer,
  updateTargetAutocomplete,
} from './DialogTargetEntity.js';
import DialogTargetType from './DialogTargetType.js';

export type PropsT = {
  +batchSelectionCount?: number,
  +closeDialog: () => void,
  +initialRelationship: RelationshipStateT,
  +source: CoreEntityT,
  +sourceDispatch: (UpdateRelationshipActionT) => void,
  +targetTypeOptions: TargetTypeOptionsT | null,
  +targetTypeRef: {-current: CoreEntityTypeT} | null,
  +title: string,
  +user: ActiveEditorT,
};

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
  const beginDate = relationship.begin_date;
  const endDate = relationship.end_date;
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
    datePeriodField: createCompoundField('period', {
      begin_date: createCompoundField(
        'period.begin_date',
        {
          day: createField(
            'period.begin_date.day',
            (beginDate?.day ?? null),
          ),
          month: createField(
            'period.begin_date.month',
            (beginDate?.month ?? null),
          ),
          year: createField(
            'period.begin_date.year',
            (beginDate?.year ?? null),
          ),
        },
      ),
      end_date: createCompoundField(
        'period.end_date',
        {
          day: createField(
            'period.end_date.day',
            (endDate?.day ?? null),
          ),
          month: createField(
            'period.end_date.month',
            (endDate?.month ?? null),
          ),
          year: createField(
            'period.end_date.year',
            (endDate?.year ?? null),
          ),
        },
      ),
      ended: createField('period.ended', relationship.ended),
    }),
    linkOrder: relationship.linkOrder,
    linkType: createDialogLinkTypeState(
      linkType,
      source,
      targetType,
      linkTypeOptions,
      getRelationshipKey(relationship),
    ),
    resultingDatePeriod: {
      begin_date: relationship.begin_date,
      end_date: relationship.end_date,
      ended: relationship.ended,
    },
    sourceEntity: createDialogSourceEntityState(
      sourceType,
      relationship,
      source,
    ),
    targetEntity: createDialogTargetEntityState(
      props.user,
      source,
      relationship,
      props.targetTypeOptions,
    ),
  };
}

function updateDialogStateForTargetTypeChange(
  newState: {...RelationshipDialogStateT},
  oldTargetType: CoreEntityTypeT,
  newTargetType: CoreEntityTypeT,
  source: CoreEntityT,
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
      ? onlyLinkType.name
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
          createNonUrlCoreEntityObject(newTargetType);

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
      const subAction = action.action;
      const oldDatePeriodField = state.datePeriodField;
      const newDatePeriodField = dateRangeFieldsetReducer(
        newState.datePeriodField,
        subAction,
      );
      newState.datePeriodField = newDatePeriodField;

      const newBeginDate = newDatePeriodField.field.begin_date;
      const newEndDate = newDatePeriodField.field.end_date;
      const newEnded = newDatePeriodField.field.ended.value;

      const beginDateChanged =
        oldDatePeriodField.field.begin_date.field !== newBeginDate.field;
      const endDateChanged =
        oldDatePeriodField.field.end_date.field !== newEndDate.field;
      const endedChanged =
        oldDatePeriodField.field.ended.value !== newEnded;

      if (
        (
          beginDateChanged ||
          endDateChanged ||
          endedChanged
        ) &&
        !(
          newBeginDate.errors.length ||
          newBeginDate.pendingErrors?.length ||
          newEndDate.errors.length ||
          newEndDate.pendingErrors?.length
        )
      ) {
        newState.resultingDatePeriod = {
          begin_date: beginDateChanged
            ? partialDateFromField(newBeginDate)
            : state.resultingDatePeriod.begin_date,
          end_date: endDateChanged
            ? partialDateFromField(newEndDate)
            : state.resultingDatePeriod.end_date,
          ended: newEnded,
        };
      }
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
  +datePeriodField: DatePeriodFieldT,
  +dispatch: (DialogActionT) => void,
};

const AttributesSection = (React.memo<AttributesSectionPropsT>(({
  attributesState,
  canEditDates,
  datePeriodField,
  dispatch,
}) => {
  const attributesDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-attribute'});
  }, [dispatch]);

  const dateDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-date-period'});
  }, [dispatch]);

  const handleAttributesHelpClick = React.useCallback((
    event: SyntheticEvent<HTMLAnchorElement>,
  ) => {
    event.preventDefault();
    attributesDispatch({
      type: 'set-help-visible',
      isHelpVisible: !attributesState.isHelpVisible,
    });
  }, [
    attributesDispatch,
    attributesState.isHelpVisible,
  ]);

  const booleanRangeSelectionHandler =
    useRangeSelectionHandler('boolean');

  return (attributesState.attributesList.length || canEditDates) ? (
    <>
      <h2>
        <div className="heading-line" />
        <span className="heading-text">
          {l('Attributes')}
          {' '}
          {bracketed(
            <a href="#" onClick={handleAttributesHelpClick}>
              {l('help')}
            </a>,
          )}
        </span>
      </h2>
      <table className="relationship-details">
        <tbody onClick={booleanRangeSelectionHandler}>
          {attributesState.attributesList.length ? (
            <DialogAttributes
              dispatch={attributesDispatch}
              state={attributesState}
            />
          ) : null}
          {canEditDates ? (
            <DialogDatePeriod
              dispatch={dateDispatch}
              state={datePeriodField}
            />
          ) : null}
        </tbody>
      </table>
    </>
  ) : null;
}): React.AbstractComponent<AttributesSectionPropsT, mixed>);

const RelationshipDialogContent = (React.memo<PropsT>((
  props: PropsT,
): React.MixedElement => {
  const {
    batchSelectionCount,
    closeDialog,
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
  const datePeriodField = state.datePeriodField;
  const attributesList = state.attributes.attributesList;

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
    if (hasErrors) {
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
    if (targetCredit !== selectedTargetEntity.name) {
      if (backward) {
        entity0Credit = targetCredit;
      } else {
        entity1Credit = targetCredit;
      }
    }
    if (sourceCredit !== source.name) {
      if (backward) {
        entity1Credit = sourceCredit;
      } else {
        entity0Credit = sourceCredit;
      }
    }

    const newRelationship: {...RelationshipStateT} = {
      ...initialRelationship,
      ...state.resultingDatePeriod,
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
    hasErrors,
    initialRelationship,
    selectedLinkType,
    selectedTargetEntity,
    source,
    state.attributes.resultingLinkAttributes,
    state.linkOrder,
    state.resultingDatePeriod,
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

  const sourceEntityDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-source-entity'});
  }, [dispatch]);

  const targetEntityDispatch = React.useCallback((action) => {
    dispatch({
      action,
      source,
      type: 'update-target-entity',
    });
  }, [dispatch, source]);

  const linkTypeDispatch = React.useCallback((action) => {
    dispatch({action, source, type: 'update-link-type'});
  }, [dispatch, source]);

  const openEditsLink = (
    initialRelationship._original &&
    initialRelationship?.editsPending
  ) ? getOpenEditsLink(initialRelationship._original) : null;

  const handleKeyDown = React.useCallback((event) => {
    if (
      event.keyCode === 13 &&
      !event.isDefaultPrevented() &&
      /*
       * MBS-12619: Hitting <Enter> on a button should click the button
       * rather than accept the dialog.
       */
      !(event.target instanceof HTMLButtonElement)
    ) {
      // Prevent a click event on the ButtonPopover.
      event.preventDefault();
      // This will return focus to the button.
      acceptDialog();
    }
  }, [acceptDialog]);

  const canEditDates = selectedLinkType != null &&
    selectedLinkType.has_dates;

  return (
    <div
      className="form"
      onKeyDown={handleKeyDown}
      ref={formDivRef}
    >
      <h1>{title}</h1>

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
            source={source}
            state={linkTypeState}
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
        datePeriodField={state.datePeriodField}
        dispatch={dispatch}
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
          hasErrors ||
          hasPendingDateErrors ||
          relationshipAlreadyExists
        )}
        onCancel={cancelDialog}
        onDone={acceptDialog}
      />
    </div>
  );
}): React.AbstractComponent<PropsT>);

function getBatchSelectionMessage(sourceType: CoreEntityTypeT) {
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

function getOpenEditsLink(relationship: RelationshipStateT) {
  const entity0 = relationship.entity0;
  const entity1 = relationship.entity1;

  if (!isDatabaseRowId(entity0.id) || !isDatabaseRowId(entity1.id)) {
    return null;
  }

  return (
    '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
    `&conditions.0.field=${encodeURIComponent(entity0.entityType)}` +
    '&conditions.0.operator=%3D' +
    `&conditions.0.name=${encodeURIComponent(entity0.name)}` +
    `&conditions.0.args.0=${encodeURIComponent(String(entity0.id))}` +
    `&conditions.1.field=${encodeURIComponent(entity1.entityType)}` +
    '&conditions.1.operator=%3D' +
    `&conditions.1.name=${encodeURIComponent(entity1.name)}` +
    `&conditions.1.args.0=${encodeURIComponent(String(entity1.id))}` +
    '&conditions.2.field=type' +
    '&conditions.2.operator=%3D&conditions.2.args=90%2C233' +
    '&conditions.2.args=91&conditions.2.args=92' +
    '&conditions.3.field=status&conditions.3.operator=%3D' +
    '&conditions.3.args=1&field=Please+choose+a+condition'
  );
}

export default RelationshipDialogContent;
