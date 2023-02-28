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
import {default as autocompleteReducer}
  from '../../common/components/Autocomplete2/reducer.js';
import type {
  OptionItemT,
  PropsT as AutocompletePropsT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';
import {
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  ENTITY_NAMES,
  PART_OF_SERIES_LINK_TYPE_GIDS,
} from '../../common/constants.js';
import {
  createNonUrlCoreEntityObject,
} from '../../common/entity2.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import type {
  DialogTargetEntityStateT,
  RelationshipStateT,
  TargetTypeOptionsT,
} from '../types.js';
import type {
  DialogTargetEntityActionT,
  UpdateTargetEntityAutocompleteActionT,
} from '../types/actions.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';

import DialogEntityCredit, {
  createInitialState as createDialogEntityCreditState,
  reducer as dialogEntityCreditReducer,
} from './DialogEntityCredit.js';

type PropsT = {
  +allowedTypes: TargetTypeOptionsT | null,
  +backward: boolean,
  +dispatch: (DialogTargetEntityActionT) => void,
  +linkType: ?LinkTypeT,
  +source: CoreEntityT,
  +state: DialogTargetEntityStateT,
};

const INCORRECT_SERIES_ENTITY_MESSAGES = {
  artist: N_l('The series you’ve selected is for artists.'),
  event: N_l('The series you’ve selected is for events.'),
  recording: N_l('The series you’ve selected is for recordings.'),
  release: N_l('The series you’ve selected is for releases.'),
  release_group: N_l('The series you’ve selected is for release groups.'),
  work: N_l('The series you’ve selected is for works.'),
};

export function isTargetSelectable(target: ?CoreEntityT): boolean %checks {
  return target != null && (
    // `target` is placeholder entity in cases where only a name is set.
    isDatabaseRowId(target.id) ||
    (
      target.entityType === 'work' &&
      target._fromBatchCreateWorksDialog === true
    )
  );
}

export function getTargetError(
  target: ?CoreEntityT,
  source: CoreEntityT,
  linkType: ?LinkTypeT,
): string {
  if (!isTargetSelectable(target)) {
    /*
     * Blank fields are handled specially in the dialog (grep
     * `hasBlankRequiredFields`).  To avoid overwhelming the user with
     * "required field" errors, we only highlight the fields red.
     */
    return '';
  }

  if (
    source.entityType === target.entityType &&
    source.id === target.id
  ) {
    return l('Entities in a relationship cannot be the same.');
  }

  if (target.entityType === 'series') {
    const seriesTypeId = target.typeID;
    invariant(
      seriesTypeId != null,
      'Existing series must have a type set',
    );
    const seriesType = linkedEntities.series_type[String(seriesTypeId)];
    const seriesItemType = seriesType.item_entity_type;
    if (
      linkType &&
      PART_OF_SERIES_LINK_TYPE_GIDS.includes(linkType.gid) &&
      seriesItemType !== source.entityType
    ) {
      return INCORRECT_SERIES_ENTITY_MESSAGES[seriesItemType]();
    }
  }

  return '';
}

const returnFalse = () => false;

export function createInitialAutocompleteStateForTarget(
  target: NonUrlCoreEntityT,
  relationshipId: number,
  allowedTypes: TargetTypeOptionsT | null,
): AutocompleteStateT<NonUrlCoreEntityT> {
  const selectedEntity = isTargetSelectable(target) ? target : null;
  return createInitialAutocompleteState<NonUrlCoreEntityT>({
    canChangeType: allowedTypes ? (newType) => (
      allowedTypes.some(option => option.value === newType)
    ) : returnFalse,
    containerClass: 'relationship-target',
    entityType: target.entityType,
    id: 'relationship-target-' + String(relationshipId),
    inputChangeHook: selectNewWork,
    inputClass: 'relationship-target focus-first',
    inputValue: target.name,
    required: true,
    selectedItem: selectedEntity ? {
      entity: selectedEntity,
      id: selectedEntity.id,
      name: selectedEntity.name,
      type: 'option',
    } : null,
  });
}

export function createInitialState(
  user: ActiveEditorT,
  releaseHasUnloadedTracks: boolean,
  source: CoreEntityT,
  initialRelationship: RelationshipStateT,
  allowedTypes: TargetTypeOptionsT | null,
): DialogTargetEntityStateT {
  const backward = isRelationshipBackward(initialRelationship, source);
  const target = backward
    ? initialRelationship.entity0
    : initialRelationship.entity1;

  let autocomplete = null;
  if (target.entityType !== 'url') {
    autocomplete = createInitialAutocompleteStateForTarget(
      target,
      initialRelationship.id,
      allowedTypes,
    );
  }

  return {
    ...createDialogEntityCreditState(
      backward
        ? initialRelationship.entity0_credit
        : initialRelationship.entity1_credit,
      releaseHasUnloadedTracks,
    ),
    allowedTypes,
    autocomplete,
    error: getTargetError(
      target,
      source,
      getRelationshipLinkType(initialRelationship),
    ),
    relationshipId: initialRelationship.id,
    target,
    targetType: target.entityType,
  };
}

const NEW_WORK_HASH = /#new-work-(-[0-9]+)\s*$/;

function selectNewWork(
  newInputValue: string,
  state: AutocompleteStateT<NonUrlCoreEntityT>,
  selectItem: (OptionItemT<NonUrlCoreEntityT>) => boolean,
): boolean {
  const match = newInputValue.match(NEW_WORK_HASH);
  if (match) {
    const newWorkId = match[1];
    const newWork = linkedEntities.work[+newWorkId];
    if (newWork) {
      return selectItem({
        entity: newWork,
        id: newWork.id,
        name: newWork.name,
        type: 'option',
      });
    }
  }
  return false;
}

export function updateTargetAutocomplete(
  newState: {...DialogTargetEntityStateT},
  action: UpdateTargetEntityAutocompleteActionT,
): void {
  invariant(newState.autocomplete);

  newState.autocomplete = autocompleteReducer<NonUrlCoreEntityT>(
    newState.autocomplete,
    action.action,
  );

  newState.error = getTargetError(
    newState.autocomplete.selectedItem?.entity,
    action.source,
    action.linkType,
  );
}

// eslint-disable-next-line consistent-return
export function reducer(
  state: DialogTargetEntityStateT,
  action: DialogTargetEntityActionT,
): DialogTargetEntityStateT {
  switch (action.type) {
    case 'update-autocomplete': {
      const newState: {...DialogTargetEntityStateT} = {...state};

      updateTargetAutocomplete(newState, action);

      const autocomplete = newState.autocomplete;

      /*:: invariant(autocomplete); */
      /*:: invariant(newState.targetType !== 'url'); */

      newState.targetType = autocomplete.entityType;

      const newTarget = (autocomplete.selectedItem?.entity) ||
        createNonUrlCoreEntityObject(newState.targetType, {
          name: autocomplete.inputValue,
        });

      if (
        state.target.entityType !== newTarget.entityType ||
        state.target.id !== newTarget.id ||
        state.target.name !== newTarget.name
      ) {
        newState.target = newTarget;
      }

      return newState;
    }
    case 'update-credit': {
      return dialogEntityCreditReducer(
        state,
        action.action,
      );
    }
    case 'update-url-text': {
      invariant(state.targetType === 'url');

      const newState: {...DialogTargetEntityStateT} = {...state};

      invariant(newState.target.entityType === 'url');

      const newTarget = {...newState.target};
      const url = action.text;
      newTarget.name = url;
      newState.target = newTarget;

      return newState;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }
}

// XXX Until Flow supports https://github.com/facebook/flow/issues/7672
const TargetAutocomplete:
  React$AbstractComponent<AutocompletePropsT<NonUrlCoreEntityT>, void> =
  // $FlowIgnore[incompatible-type]
  Autocomplete2;

const DialogTargetEntity = (React.memo<PropsT>((
  props: PropsT,
): React.MixedElement => {
  const {
    backward,
    dispatch,
    linkType,
    source,
    state,
  } = props;

  const autocomplete = state.autocomplete;
  const targetType = state.targetType;

  if (__DEV__) {
    if (autocomplete) {
      invariant(autocomplete.entityType === targetType);
    }
  }

  const autocompleteDispatch = React.useCallback((action) => {
    dispatch({
      action,
      linkType,
      source,
      type: 'update-autocomplete',
    });
  }, [dispatch, linkType, source]);

  function handleUrlTextChange(event: SyntheticEvent<HTMLInputElement>) {
    dispatch({
      text: event.currentTarget.value,
      type: 'update-url-text',
    });
  }

  const creditDispatch = React.useCallback((action) => {
    dispatch({action, type: 'update-credit'});
  }, [dispatch]);

  const showTargetCredit = !!(
    ENTITIES_WITH_RELATIONSHIP_CREDITS[targetType] &&
    autocomplete?.selectedItem?.entity
  );

  return (
    <tr>
      <td className="required section">
        {ENTITY_NAMES[targetType]()}
      </td>
      <td className="fields">
        {targetType === 'url' ? (
          <input
            onChange={handleUrlTextChange}
            type="text"
            value={state.target.name}
          />
        ) : autocomplete ? (
          <TargetAutocomplete
            dispatch={autocompleteDispatch}
            state={autocomplete}
          />
        ) : null}

        <div className="error">
          {state.error}
        </div>

        {showTargetCredit ? (
          <DialogEntityCredit
            backward={backward}
            dispatch={creditDispatch}
            entityName={state.target.name}
            forEntity="target"
            linkType={linkType}
            state={state}
            targetType={source.entityType}
          />
        ) : null}
      </td>
    </tr>
  );
}): React.AbstractComponent<PropsT>);

export default DialogTargetEntity;
