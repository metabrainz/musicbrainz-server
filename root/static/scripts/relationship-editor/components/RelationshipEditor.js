/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// $FlowIgnore[untyped-import]
import {captureException} from '@sentry/browser';
import deepFreeze from 'deep-freeze-strict';
import * as React from 'react';
import * as tree from 'weight-balanced-tree';
import {ValueExistsError} from 'weight-balanced-tree/errors';
import {
  onConflictKeepTreeValue,
  onConflictUseGivenValue,
} from 'weight-balanced-tree/update';

import {decompactEntityJson} from '../../../../utility/compactEntityJson.js';
import {INSTRUMENT_ROOT_ID, VOCAL_ROOT_ID} from '../../common/constants.js';
import MB from '../../common/MB.js';
import {
  getCatalystContext,
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import coerceToError from '../../common/utility/coerceToError.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {uniqueNegativeId} from '../../common/utility/numbers.js';
import {hasSessionStorage} from '../../common/utility/storage.js';
import reducerWithErrorHandling
  from '../../edit/utility/reducerWithErrorHandling.js';
import {
  REL_STATUS_ADD,
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
  RelationshipSourceGroupsContext,
} from '../constants.js';
import type {
  RelationshipEditorStateT,
  RelationshipSourceGroupsT,
  RelationshipStateT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';
import type {
  RelationshipEditorActionT,
} from '../types/actions.js';
import {
  cloneRelationshipEditorState,
  cloneRelationshipState,
} from '../utility/cloneState.js';
import {
  compareLinkAttributeIds,
} from '../utility/compareRelationships.js';
import {
  findTargetTypeGroups,
} from '../utility/findState.js';
import getRelationshipEditStatus
  from '../utility/getRelationshipEditStatus.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import getRelationshipStateId from '../utility/getRelationshipStateId.js';
import getRelationshipTarget from '../utility/getRelationshipTarget.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';
import mergeRelationship from '../utility/mergeRelationship.js';
import moveRelationship from '../utility/moveRelationship.js';
import prepareHtmlFormSubmission
  from '../utility/prepareHtmlFormSubmission.js';
import relationshipsAreIdentical
  from '../utility/relationshipsAreIdentical.js';
import splitRelationshipByAttributes
  from '../utility/splitRelationshipByAttributes.js';
import updateEntityCredits from '../utility/updateEntityCredits.js';
import type {RelationshipUpdateT} from '../utility/updateRelationships.js';
import updateRelationships, {
  ADD_RELATIONSHIP,
  REMOVE_RELATIONSHIP,
} from '../utility/updateRelationships.js';

import RelationshipTargetTypeGroups from './RelationshipTargetTypeGroups.js';

// Export modules that userscripts may need access to.

// $FlowIgnore[prop-missing]
MB.relationshipEditor.getRelationshipStateId = getRelationshipStateId;
MB.tree = tree;

export type PropsT = {
  +dispatch: (RelationshipEditorActionT) => void,
  +formName: string,
  +state: RelationshipEditorStateT,
};

export type InitialStateArgsT = {
  +formName: string,
  +seededRelationships: ?$ReadOnlyArray<SeededRelationshipT>,
};

export function* getInitialRelationshipUpdates(
  relationships:
    | $ReadOnlyArray<RelationshipT>
    | $ReadOnlyArray<SeededRelationshipT>,
  source: CoreEntityT,
): Generator<RelationshipUpdateT, void, void> {
  for (const relationshipData of relationships) {
    if (relationshipData.target_type === 'url') {
      continue;
    }

    const backward = relationshipData.backward;

    let target = relationshipData.target;
    /*
     * Make sure all seeded placeholder targets have unique IDs. These default
     * to '0' on the server, and '0' is also used for the source entity in
     * creation forms. That conflict can cause strange things to happen if
     * the source and target entity types are the same; see e.g. MBS-12850.
     */
    if (!isDatabaseRowId(target.id)) {
      target = ({...target, id: uniqueNegativeId()}: CoreEntityT);
    }

    const isExistingRelationship = isDatabaseRowId(relationshipData.id);

    const relationshipState: RelationshipStateT = {
      _lineage: [isExistingRelationship ? 'loaded from database' : 'seeded'],
      _original: null,
      _status: isExistingRelationship
        ? REL_STATUS_NOOP
        : REL_STATUS_ADD,
      attributes: tree.fromDistinctAscArray(
        relationshipData.attributes.slice(0).sort(compareLinkAttributeIds),
      ),
      begin_date: relationshipData.begin_date,
      editsPending: relationshipData.editsPending,
      end_date: relationshipData.end_date,
      ended: relationshipData.ended,
      entity0: backward ? target : source,
      entity0_credit: relationshipData.entity0_credit,
      entity1: backward ? source : target,
      entity1_credit: relationshipData.entity1_credit,
      id: getRelationshipStateId(relationshipData),
      linkOrder: relationshipData.linkOrder,
      linkTypeID: relationshipData.linkTypeID,
    };

    if (isDatabaseRowId(relationshipData.id)) {
      /*
       * Writing here is sound because the object was just created.
       * (This is needed to create a self-reference.)
       */
      // $FlowIgnore[cannot-write]
      relationshipState._original = relationshipState;
    }

    yield {
      onConflict: onConflictKeepTreeValue,
      relationship: relationshipState,
      type: ADD_RELATIONSHIP,
    };

    if (target.relationships) {
      yield *getInitialRelationshipUpdates(
        target.relationships,
        target,
      );
    }
  }
}

export function createInitialState(
  args: InitialStateArgsT,
): RelationshipEditorStateT {
  const {seededRelationships} = args;

  const source = getSourceEntityDataForRelationshipEditor();

  invariant(
    source.entityType !== 'release',
    'Cannot initialize the mini relationship editor with a release',
  );

  const newState: {...RelationshipEditorStateT} = {
    dialogLocation: null,
    entity: source,
    existingRelationshipsBySource: null,
    reducerError: null,
    relationshipsBySource: null,
  };

  if (source.relationships) {
    updateRelationships(
      newState,
      getInitialRelationshipUpdates(source.relationships, source),
    );
  }

  newState.existingRelationshipsBySource = newState.relationshipsBySource;

  if (seededRelationships) {
    updateRelationships(
      newState,
      getInitialRelationshipUpdates(seededRelationships, source),
    );
  }

  return newState;
}

export function loadOrCreateInitialState(
  args: InitialStateArgsT,
): RelationshipEditorStateT {
  const $c = getCatalystContext();
  if (hasSessionStorage && $c.req.method === 'POST') {
    const submission = sessionStorage.getItem('relationshipEditorState');
    if (nonEmpty(submission)) {
      try {
        // $FlowIgnore[unclear-type]
        return (decompactEntityJson(JSON.parse(submission)): any);
      } catch (e) {
        captureException(e);
      } finally {
        /*
         * XXX React seems to double-invoke `loadOrCreateInitialState` in
         * development, so delay the sessionStorage removal.
         */
        setTimeout(() => {
          sessionStorage.removeItem('relationshipEditorState');
        }, 1000);
      }
    }
  }
  return createInitialState(args);
}

export function* getUpdatesForAcceptedRelationship(
  rootState: {
    +existingRelationshipsBySource: RelationshipSourceGroupsT,
    +relationshipsBySource: RelationshipSourceGroupsT,
    ...
  },
  newRelationshipState: RelationshipStateT,
  source: CoreEntityT,
): Generator<RelationshipUpdateT, void, void> {
  const mergeAndYieldUpdates = function* (
    relationshipState: RelationshipStateT,
  ): Generator<RelationshipUpdateT, void, void> {
    const mergeUpdates = mergeRelationship(
      findTargetTypeGroups(
        rootState.relationshipsBySource,
        source,
      ),
      findTargetTypeGroups(
        rootState.existingRelationshipsBySource,
        source,
      ),
      relationshipState,
      source,
    );
    if (mergeUpdates) {
      yield *mergeUpdates;
    } else {
      yield {
        onConflict: onConflictKeepTreeValue,
        relationship: relationshipState,
        type: ADD_RELATIONSHIP,
      };
    }
  };

  const linkType = getRelationshipLinkType(
    newRelationshipState,
  );
  /*:: invariant(linkType); */

  if (
    linkType.attributes[INSTRUMENT_ROOT_ID] != null ||
    linkType.attributes[VOCAL_ROOT_ID] != null
  ) {
    const splitRelationships = splitRelationshipByAttributes(
      newRelationshipState,
    );
    for (const relationshipState of splitRelationships) {
      yield *mergeAndYieldUpdates(relationshipState);
    }
  } else {
    yield *mergeAndYieldUpdates(newRelationshipState);
  }
}

export const reducer: ((
  state: RelationshipEditorStateT,
  action: RelationshipEditorActionT,
) => RelationshipEditorStateT) = reducerWithErrorHandling((
  state,
  action,
): RelationshipEditorStateT => {
  const writableState: {...RelationshipEditorStateT} =
    cloneRelationshipEditorState(state);
  runReducer(writableState, action);
  if (__DEV__) {
    deepFreeze(writableState);
  }
  return writableState;
});

export function runReducer(
  writableState:
    | {...RelationshipEditorStateT}
    | {...ReleaseRelationshipEditorStateT},
  action: RelationshipEditorActionT,
): void {
  switch (action.type) {
    case 'move-relationship-down': {
      moveRelationship(
        writableState,
        action.relationship,
        action.source,
        true,
      );
      break;
    }

    case 'move-relationship-up': {
      moveRelationship(
        writableState,
        action.relationship,
        action.source,
        false,
      );
      break;
    }

    case 'remove-relationship': {
      const {relationship} = action;

      const updates: Array<RelationshipUpdateT> = [
        {
          relationship,
          throwIfNotExists: true,
          type: REMOVE_RELATIONSHIP,
        },
      ];

      if (relationship._original) {
        const newRelationshipState =
          cloneRelationshipState(relationship._original);
        newRelationshipState._lineage = [
          ...newRelationshipState._lineage,
          'removed',
        ];
        // Clicking the `x` again undoes the removal.
        newRelationshipState._status =
          relationship._status === REL_STATUS_REMOVE
            ? REL_STATUS_NOOP
            : REL_STATUS_REMOVE;
        updates.push({
          onConflict: onConflictUseGivenValue,
          relationship: newRelationshipState,
          type: ADD_RELATIONSHIP,
        });
      }

      updateRelationships(writableState, updates);
      break;
    }

    case 'toggle-ordering': {
      const {
        hasOrdering,
        linkPhraseGroup,
      } = action;

      const updates: Array<RelationshipUpdateT> = [];
      let nextLogicalLinkOrder = 1;

      for (
        const relationship of
        tree.iterate(linkPhraseGroup.relationships)
      ) {
        const newRelationship = cloneRelationshipState(relationship);

        newRelationship._lineage = [
          ...newRelationship._lineage,
          'toggled ordering',
        ];
        newRelationship.linkOrder =
          hasOrdering ? (nextLogicalLinkOrder++) : 0;
        newRelationship._status = getRelationshipEditStatus(
          newRelationship,
        );

        updates.push(
          {
            relationship,
            throwIfNotExists: true,
            type: REMOVE_RELATIONSHIP,
          },
          {
            onConflict: onConflictUseGivenValue,
            relationship: newRelationship,
            type: ADD_RELATIONSHIP,
          },
        );
      }

      updateRelationships(writableState, updates);
      break;
    }

    case 'update-dialog-location': {
      writableState.dialogLocation = action.location;
      break;
    }

    case 'update-entity': {
      invariant(
        writableState.entity.entityType === action.entityType,
        'Cannot change the relationship editor entity type',
      );
      // $FlowIgnore[cannot-spread-indexer]
      writableState.entity = {
        ...writableState.entity,
        ...action.changes,
      };
      break;
    }

    case 'update-relationship-state': {
      const {
        creditsToChangeForSource,
        creditsToChangeForTarget,
        newRelationshipState,
        oldRelationshipState,
        sourceEntity,
      } = action;

      const relationshipStateChanged = (
        oldRelationshipState != null &&
        !relationshipsAreIdentical(
          oldRelationshipState,
          newRelationshipState,
        )
      );

      if (
        oldRelationshipState == null ||
        relationshipStateChanged ||
        creditsToChangeForSource ||
        creditsToChangeForTarget
      ) {
        const targetEntity = getRelationshipTarget(
          newRelationshipState,
          sourceEntity,
        );
        const updates: Array<RelationshipUpdateT> = [];

        if (
          oldRelationshipState != null &&
          relationshipStateChanged
        ) {
          /*
           * The old relationship state must be removed first in a separate
           * `updateRelationships` call, because its presence affects other
           * functions that act on the current state, like
           * `mergeRelationship`.
           */
          updateRelationships(
            writableState,
            [
              {
                relationship: oldRelationshipState,
                throwIfNotExists: false,
                type: REMOVE_RELATIONSHIP,
              },
            ],
          );
        }

        if (
          oldRelationshipState == null ||
          relationshipStateChanged
        ) {
          updates.push(...getUpdatesForAcceptedRelationship(
            writableState,
            newRelationshipState,
            sourceEntity,
          ));
        }

        /*
         * `updateEntityCredits` only uses `newRelationshipState` to obtain
         * the entity credits, link type, and direction, so it's fine and
         * intended that we don't invoke it for each "split" relationship
         * from `getUpdatesForAcceptedRelationship`.
         */
        if (creditsToChangeForSource) {
          updates.push(...updateEntityCredits(
            writableState.relationshipsBySource,
            newRelationshipState,
            creditsToChangeForSource,
            sourceEntity,
            isRelationshipBackward(newRelationshipState, sourceEntity)
              ? newRelationshipState.entity1_credit
              : newRelationshipState.entity0_credit,
          ));
        }

        if (creditsToChangeForTarget) {
          updates.push(...updateEntityCredits(
            writableState.relationshipsBySource,
            newRelationshipState,
            creditsToChangeForTarget,
            targetEntity,
            isRelationshipBackward(newRelationshipState, targetEntity)
              ? newRelationshipState.entity1_credit
              : newRelationshipState.entity0_credit,
          ));
        }

        try {
          updateRelationships(writableState, updates);
        } catch (error) {
          if (error instanceof ValueExistsError) {
            alert(l('This relationship already exists.'));
          } else {
            throw error;
          }
        }
      }

      break;
    }

    default: {
      /*:: exhaustive(action); */
    }
  }
}

type ErrorMessagePropsT = {
  +error: string,
};

export const ErrorMessage:
  React.AbstractComponent<ErrorMessagePropsT, mixed> =
  React.memo<ErrorMessagePropsT>(({
    error,
  }: ErrorMessagePropsT): React.MixedElement => (
    <div className="error">
      <strong className="error">
        {l('Oops, something went wrong!')}
      </strong>
      <br />
      <pre style={{whiteSpace: 'pre-wrap'}}>
        {error}
      </pre>
    </div>
  ));

const RelationshipEditor = (
  props: PropsT,
): React$Element<'fieldset'> | null => {
  const {
    dispatch,
    formName,
    state,
  } = props;

  const reducerError = state.reducerError;

  const submissionInProgress = React.useRef(false);

  const [
    prepareSubmissionError,
    setPrepareSubmissionError,
  ] = React.useState<Error | null>(null);

  const error = reducerError ?? prepareSubmissionError;

  React.useEffect(() => {
    const handleSubmission = (event: Event) => {
      if (!submissionInProgress.current) {
        submissionInProgress.current = true;
        try {
          prepareHtmlFormSubmission(formName, state);
        } catch (error) {
          event.preventDefault();

          captureException(error);

          setPrepareSubmissionError(coerceToError(error));
        }
      }
    };

    document.addEventListener('submit', handleSubmission);

    return () => {
      document.removeEventListener('submit', handleSubmission);
    };
  });

  // Expose internal state for userscripts.
  React.useEffect(() => {
    // $FlowIgnore[prop-missing]
    MB.relationshipEditor.dispatch = dispatch;
    // $FlowIgnore[prop-missing]
    MB.relationshipEditor.state = state;

    return () => {
      // $FlowIgnore[prop-missing]
      MB.relationshipEditor.dispatch = null;
      // $FlowIgnore[prop-missing]
      MB.relationshipEditor.state = null;
    };
  }, [dispatch, state]);

  const sourceGroupsContext = React.useMemo(() => ({
    existing: state.existingRelationshipsBySource,
    pending: state.relationshipsBySource,
  }), [
    state.existingRelationshipsBySource,
    state.relationshipsBySource,
  ]);

  return (
    <fieldset id="relationship-editor">
      {error ? (
        <ErrorMessage error={error.stack} />
      ) : null}

      <legend>
        {l('Relationships')}
      </legend>

      <RelationshipSourceGroupsContext.Provider value={sourceGroupsContext}>
        <RelationshipTargetTypeGroups
          dialogLocation={state.dialogLocation}
          dispatch={dispatch}
          releaseHasUnloadedTracks={false}
          source={state.entity}
          targetTypeGroups={findTargetTypeGroups(
            state.relationshipsBySource,
            state.entity,
          )}
          track={null}
        />
      </RelationshipSourceGroupsContext.Provider>
    </fieldset>
  );
};

export default RelationshipEditor;
