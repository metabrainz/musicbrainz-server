/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
// $FlowIgnore[missing-export]
import {flushSync} from 'react-dom';
import * as tree from 'weight-balanced-tree';
import {
  onConflictThrowError,
  onConflictUseGivenValue,
} from 'weight-balanced-tree/update';

import hydrate from '../../../../utility/hydrate.js';
import {expect} from '../../../../utility/invariant.js';
import {
  EMPTY_PARTIAL_DATE,
  RECORDING_OF_LINK_TYPE_ID,
  SERIES_ORDERING_TYPE_MANUAL,
  WS_EDIT_RESPONSE_OK,
} from '../../common/constants.js';
import {
  EDIT_RELATIONSHIP_CREATE,
  EDIT_RELATIONSHIP_DELETE,
  EDIT_RELATIONSHIP_EDIT,
  EDIT_RELATIONSHIPS_REORDER,
  EDIT_WORK_CREATE,
} from '../../common/constants/editTypes.js';
import {createWorkObject} from '../../common/entity2.js';
import linkedEntities, {
  mergeLinkedEntities,
} from '../../common/linkedEntities.mjs';
import MB from '../../common/MB.js';
import areDatesEqual from '../../common/utility/areDatesEqual.js';
import {bracketedText} from '../../common/utility/bracketed.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import clean from '../../common/utility/clean.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import isDateEmpty from '../../common/utility/isDateEmpty.js';
import {uniqueNegativeId} from '../../common/utility/numbers.js';
import setMapDefault from '../../common/utility/setMapDefault.js';
import sleep from '../../common/utility/sleep.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import {
  withLoadedTypeInfoForRelationshipEditor,
} from '../../edit/components/withLoadedTypeInfo.js';
import {createField} from '../../edit/utility/createField.js';
import reducerWithErrorHandling
  from '../../edit/utility/reducerWithErrorHandling.js';
import {
  getInitialRelationshipUpdates,
  getUpdatesForAcceptedRelationship,
  runReducer as runRelationshipEditorReducer,
} from '../../relationship-editor/components/RelationshipEditor.js';
import RelationshipTargetTypeGroups
  // eslint-disable-next-line max-len
  from '../../relationship-editor/components/RelationshipTargetTypeGroups.js';
import {
  REL_STATUS_ADD,
  REL_STATUS_EDIT,
  REL_STATUS_NOOP,
  REL_STATUS_REMOVE,
  RelationshipSourceGroupsContext,
} from '../../relationship-editor/constants.js';
import type {
  MediumRecordingStateTreeT,
  MediumStateTreeT,
  RelationshipDialogLocationT,
  RelationshipSourceGroupsT,
  RelationshipStateT,
  RelationshipTargetTypeGroupsT,
  ReleaseRelationshipEditorStateT,
  ReleaseWithMediumsAndReleaseGroupT,
} from '../../relationship-editor/types.js';
import type {
  ReleaseRelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';
import {
  cloneRelationshipState,
  cloneReleaseRelationshipEditorState,
} from '../../relationship-editor/utility/cloneState.js';
import {
  compareRecordings,
  compareWorks,
} from '../../relationship-editor/utility/comparators.js';
import {
  compareLinkAttributeIds,
} from '../../relationship-editor/utility/compareRelationships.js';
import {
  compareTargetTypeWithGroup,
  findTargetTypeGroups,
  iterateRelationshipsInTargetTypeGroup,
  iterateRelationshipsInTargetTypeGroups,
} from '../../relationship-editor/utility/findState.js';
import getRelationshipEditStatus
  from '../../relationship-editor/utility/getRelationshipEditStatus.js';
import getRelationshipKey
  from '../../relationship-editor/utility/getRelationshipKey.js';
import getRelationshipLinkType
  from '../../relationship-editor/utility/getRelationshipLinkType.js';
import isRelationshipBackward
  from '../../relationship-editor/utility/isRelationshipBackward.js';
import updateRecordingStates, {
  compareMediumWithMediumStateTuple,
  compareRecordingIdWithRecordingState,
} from '../../relationship-editor/utility/updateRecordingStates.js';
import updateRelationships, {
  ADD_RELATIONSHIP,
  REMOVE_RELATIONSHIP,
} from '../../relationship-editor/utility/updateRelationships.js';
import updateWorkStates
  from '../../relationship-editor/utility/updateWorkStates.js';
import type {LoadedTracksMapT} from '../types.js';

import MediumRelationshipEditor from './MediumRelationshipEditor.js';
import {ToggleAllMediumsButtons} from './MediumToolbox.js';
import RelationshipEditorBatchTools from './RelationshipEditorBatchTools.js';
import {
  createInitialLazyReleaseState,
  getMediumTracks,
  isMediumExpanded,
  runLazyReleaseReducer,
  useUnloadedTracksMap,
} from './TracklistAndCredits.js';

const createArray = <T>(): Array<T> => [];
const createMap = <K, V>(): Map<K, V> => new Map();

function addTracksToState(
  writableRootState: {...ReleaseRelationshipEditorStateT},
  tracks: $ReadOnlyArray<TrackWithRecordingT>,
  medium: MediumWithRecordingsT,
): void {
  const recordingsWithNoRelationships = [];
  for (const track of tracks) {
    const recording = track.recording;
    setMapDefault(
      writableRootState.mediumsByRecordingId,
      recording.id,
      createArray,
    ).push(medium);
    if (recording.relationships?.length) {
      updateRelationships(
        writableRootState,
        getInitialRelationshipUpdates(
          recording.relationships,
          recording,
        ),
      );
    } else {
      recordingsWithNoRelationships.push(recording);
    }
  }
  if (recordingsWithNoRelationships.length) {
    updateRecordingStates(
      writableRootState,
      recordingsWithNoRelationships,
      (emptyRecordingState) => emptyRecordingState,
    );
  }
}

function compareMediumStateTuples(
  a: [MediumWithRecordingsT, MediumRecordingStateTreeT],
  b: [MediumWithRecordingsT, MediumRecordingStateTreeT],
): number {
  return a[0].position - b[0].position;
}

export function createInitialState(): ReleaseRelationshipEditorStateT {
  const release: ReleaseWithMediumsAndReleaseGroupT =
    // $FlowIgnore[unclear-type]
    (getSourceEntityDataForRelationshipEditor(): any);

  const newState: {...ReleaseRelationshipEditorStateT} = {
    ...createInitialLazyReleaseState(),
    dialogLocation: null,
    editNoteField: createField('', ''),
    enterEditForm: {
      field: {
        make_votable: createField('make_votable', false),
      },
      has_errors: false,
      name: '',
      type: 'form',
    },
    entity: release,
    existingRelationshipsBySource: null,
    mediums: null,
    mediumsByRecordingId: new Map(),
    reducerError: null,
    relationshipsBySource: null,
    selectedRecordings: null,
    selectedWorks: null,
    submissionError: null,
    submissionInProgress: false,
    workRecordings: null,
  };

  if (release.mediums) {
    for (const medium of release.mediums) {
      newState.mediums = tree.insertOrThrowIfExists(
        newState.mediums,
        [medium, null],
        compareMediumStateTuples,
      );

      const tracks = medium.tracks;
      if (tracks) {
        addTracksToState(newState, tracks, medium);
      }
    }
  }

  if (release.relationships) {
    updateRelationships(
      newState,
      getInitialRelationshipUpdates(
        release.relationships,
        release,
      ),
    );
  }

  const releaseGroup = release.releaseGroup;
  if (releaseGroup.relationships) {
    updateRelationships(
      newState,
      getInitialRelationshipUpdates(
        releaseGroup.relationships,
        releaseGroup,
      ),
    );
  }

  newState.existingRelationshipsBySource = newState.relationshipsBySource;

  return newState;
}

async function wsJsEditSubmission(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  state: ReleaseRelationshipEditorStateT,
  edits:
    | Array<[Array<RelationshipStateT>, WsJsEditRelationshipT]>
    | Array<[Array<RelationshipStateT>, WsJsEditWorkCreateT]>,
): Promise<WsJsEditResponseT | null> {
  if (!edits.length) {
    return {edits: []};
  }
  const submissionData = {
    editNote: state.editNoteField.value,
    edits: edits.map(([/* relationships */, wsJsEdit]) => wsJsEdit),
    makeVotable: state.enterEditForm.field.make_votable.value,
  };
  await sleep(500);
  const resp: Response = await fetch('/ws/js/edit/create', {
    body: JSON.stringify(submissionData),
    headers: {
      'Accept': 'application/json; charset=utf-8',
      'Content-Type': 'application/json; charset=utf-8',
    },
    method: 'POST',
  });
  const respJson = await resp.json();
  if (!resp.ok) {
    const error = (
      (
        respJson != null && typeof respJson === 'object'
      ) ? String(respJson.error) : ''
    ) || 'unknown error';
    dispatch({
      error,
      type: 'stop-submission',
    });
    alert(l('An error occurred:') + ' ' + error);
    return null;
  }
  dispatch({
    edits,
    responseData: respJson,
    type: 'update-submitted-relationships',
  });
  return respJson;
}

async function submitWorkEdits(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  state: ReleaseRelationshipEditorStateT,
): Promise<void> {
  const seenWorks = new Set();

  function getWorkEditsForEntity(
    targetTypeGroups: RelationshipTargetTypeGroupsT,
    edits: Array<[Array<RelationshipStateT>, WsJsEditWorkCreateT]>,
  ): void {
    const workTargetGroup = tree.find(
      targetTypeGroups,
      'work',
      compareTargetTypeWithGroup,
      null,
    );
    if (!workTargetGroup) {
      return;
    }
    for (
      const relationship of
      iterateRelationshipsInTargetTypeGroup(workTargetGroup)
    ) {
      if (relationship._status !== REL_STATUS_ADD) {
        continue;
      }
      const recording = relationship.entity0;
      const work = relationship.entity1;
      invariant(
        recording.entityType === 'recording' &&
        work.entityType === 'work',
      );
      if (
        !isDatabaseRowId(work.id) &&
        work._fromBatchCreateWorksDialog === true
      ) {
        if (seenWorks.has(work.id)) {
          continue;
        }
        seenWorks.add(work.id);
        const workEditData: WsJsEditWorkCreateT = {
          comment: '',
          edit_type: EDIT_WORK_CREATE,
          languages: work.languages.map(x => x.language.id),
          name: work.name,
          type_id: work.typeID,
        };
        edits.push([[relationship], workEditData]);
      }
    }
  }

  const workEdits = [];

  for (const [/* position */, mediumState] of tree.iterate(state.mediums)) {
    for (const recordingState of tree.iterate(mediumState)) {
      getWorkEditsForEntity(recordingState.targetTypeGroups, workEdits);
    }
  }

  if (workEdits.length) {
    await wsJsEditSubmission(dispatch, state, workEdits);
  }
}

async function submitRelationshipEdits(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  state: ReleaseRelationshipEditorStateT,
): Promise<void> {
  const seenRelationships = new Map();
  let editCount = 0;

  function linkAttributeEditData(
    attr: LinkAttrT,
    removed: boolean,
  ): WsJsRelationshipAttributeT {
    const linkAttributeType =
      linkedEntities.link_attribute_type[attr.typeID];
    const editData: {...WsJsRelationshipAttributeT} = {
      type: {gid: attr.type.gid},
    };
    if (linkAttributeType.creditable && attr.credited_as != null) {
      editData.credited_as = clean(attr.credited_as);
    }
    if (linkAttributeType.free_text && attr.text_value != null) {
      editData.text_value = clean(attr.text_value);
    }
    if (removed) {
      editData.removed = true;
    }
    return editData;
  }

  function entityEditData(
    entity: CoreEntityT,
  ): WsJsRelationshipEntityT {
    if (entity.entityType === 'url') {
      const editData: {
        entityType: 'url',
        gid?: string,
        name: string,
      } = {
        entityType: entity.entityType,
        name: entity.name,
      };
      if (entity.gid) {
        editData.gid = entity.gid;
      }
      return editData;
    } else if (entity.entityType === 'work') {
      invariant(
        entity._fromBatchCreateWorksDialog !== true &&
        isDatabaseRowId(entity.id),
      );
    }
    return {
      entityType: (entity.entityType: NonUrlCoreEntityTypeT),
      gid: entity.gid,
      name: entity.name,
    };
  }

  function getRelationshipEditsForEntity(
    targetTypeGroups: RelationshipTargetTypeGroupsT,
  ): Array<[Array<RelationshipStateT>, WsJsEditRelationshipT]> {
    const edits = [];
    const reorderedRelationships: Map<
      number,
      Map<
        number,
        Array<{
          +link_order: number,
          +relationship: RelationshipStateT,
        }>,
      >,
    > = new Map();
    for (
      const relationship of
      iterateRelationshipsInTargetTypeGroups(targetTypeGroups)
    ) {
      const relationshipKey = getRelationshipKey(relationship);
      const seenRelationship = seenRelationships.get(relationshipKey);
      if (seenRelationship) {
        /*
         * It's normal to come across the same relationship twice if a
         * recording or work is reused.  But they should always reference
         * the same object.  If not, then we either didn't sync the state
         * correctly or we reused a new relationship ID.
         */
        invariant(
          seenRelationship === relationship,
          'Two relationships with the same key',
        );
        continue;
      }
      seenRelationships.set(relationshipKey, relationship);

      const {
        entity0,
        entity1,
        linkTypeID: linkTypeId,
      } = relationship;

      invariant(linkTypeId != null);

      const linkType = linkedEntities.link_type[linkTypeId];
      const entity0Credit = clean(relationship.entity0_credit);
      const entity1Credit = clean(relationship.entity1_credit);

      switch (relationship._status) {
        case REL_STATUS_ADD: {
          const editData: {...WsJsEditRelationshipCreateT} = {
            attributes: tree.toArray(relationship.attributes).map(
              (attr) => linkAttributeEditData(attr, false),
            ),
            edit_type: EDIT_RELATIONSHIP_CREATE,
            entities: [
              entityEditData(entity0),
              entityEditData(entity1),
            ],
            entity0_credit: entity0Credit,
            entity1_credit: entity1Credit,
            linkTypeID: linkTypeId,
          };
          if (linkType.has_dates) {
            if (relationship.begin_date) {
              editData.begin_date = relationship.begin_date;
            }
            if (relationship.end_date) {
              editData.end_date = relationship.end_date;
            }
            editData.ended = isDateEmpty(relationship.end_date)
              ? relationship.ended
              : true;
          }
          if (relationship.linkOrder != null) {
            editData.linkOrder = relationship.linkOrder;
          }
          edits.push([
            [relationship],
            (editData: WsJsEditRelationshipCreateT),
          ]);
          break;
        }
        case REL_STATUS_EDIT: {
          const origRelationship = relationship._original;

          invariant(origRelationship);

          const editData: {...WsJsEditRelationshipEditT} = {
            edit_type: EDIT_RELATIONSHIP_EDIT,
            id: relationship.id,
            linkTypeID: linkTypeId,
          };

          if (
            entity0.id !== origRelationship.entity0.id ||
            entity1.id !== origRelationship.entity1.id
          ) {
            editData.entities = [
              entityEditData(entity0),
              entityEditData(entity1),
            ];
          }

          if (entity0Credit !== clean(origRelationship.entity0_credit)) {
            editData.entity0_credit = entity0Credit;
          }

          if (entity1Credit !== clean(origRelationship.entity1_credit)) {
            editData.entity1_credit = entity1Credit;
          }

          const changedAttributes = [];
          for (const attr of tree.iterate(relationship.attributes)) {
            const attrData = linkAttributeEditData(attr, false);

            const origAttr = tree.find(
              origRelationship.attributes,
              attr,
              compareLinkAttributeIds,
              null,
            );

            if (origAttr) {
              const origAttrData = linkAttributeEditData(origAttr, false);
              if (
                attrData.credited_as !== origAttrData.credited_as ||
                attrData.text_value !== origAttrData.text_value
              ) {
                changedAttributes.push(attrData);
              }
            } else {
              changedAttributes.push(attrData);
            }
          }

          changedAttributes.push(
            ...tree.toArray(
              tree.difference(
                origRelationship.attributes,
                relationship.attributes,
                compareLinkAttributeIds,
              ),
            ).map((attr) => linkAttributeEditData(attr, true)),
          );

          if (changedAttributes.length) {
            editData.attributes = changedAttributes;
          }

          if (linkType.has_dates) {
            if (
              !areDatesEqual(
                relationship.begin_date,
                origRelationship.begin_date,
              )
            ) {
              editData.begin_date =
                relationship.begin_date ?? EMPTY_PARTIAL_DATE;
            }
            if (
              !areDatesEqual(
                relationship.end_date,
                origRelationship.end_date,
              )
            ) {
              editData.end_date =
                relationship.end_date ?? EMPTY_PARTIAL_DATE;
            }
            if (relationship.ended !== origRelationship.ended) {
              editData.ended = relationship.ended;
            }
          }
          if (relationship.linkOrder !== origRelationship.linkOrder) {
            const linkType = getRelationshipLinkType(relationship);

            if (linkType?.orderable_direction) {
              const unorderedEntity = linkType.orderable_direction === 1
                ? relationship.entity0
                : relationship.entity1;
              if (
                unorderedEntity.entityType !== 'series' ||
                unorderedEntity.orderingTypeID === SERIES_ORDERING_TYPE_MANUAL
              ) {
                setMapDefault(
                  setMapDefault(
                    reorderedRelationships,
                    unorderedEntity.id,
                    createMap,
                  ),
                  linkType.id,
                  createArray,
                ).push({
                  link_order: relationship.linkOrder,
                  relationship,
                });
              }
            }
          }
          edits.push([
            [relationship],
            (editData: WsJsEditRelationshipEditT),
          ]);
          break;
        }
        case REL_STATUS_REMOVE: {
          const origRelationship = relationship._original;
          invariant(
            origRelationship &&
            origRelationship.linkTypeID != null,
          );
          edits.push([[relationship], {
            edit_type: EDIT_RELATIONSHIP_DELETE,
            id: origRelationship.id,
            linkTypeID: origRelationship.linkTypeID,
          }]);
          break;
        }
      }
    }
    for (
      const reorderedRelationshipsByLinkTypeId of
      reorderedRelationships.values()
    ) {
      for (
        const [linkTypeId, orderings] of reorderedRelationshipsByLinkTypeId
      ) {
        const relationships = [];
        const relationshipOrderEditData = [];

        for (const ordering of orderings) {
          relationships.push(ordering.relationship);
          relationshipOrderEditData.push({
            link_order: ordering.link_order,
            relationship_id: ordering.relationship.id,
          });
        }

        edits.push([relationships, {
          edit_type: EDIT_RELATIONSHIPS_REORDER,
          linkTypeID: linkTypeId,
          relationship_order: relationshipOrderEditData,
        }]);
      }
    }
    editCount += edits.length;
    return edits;
  }

  let responseData;
  mediumLoop:
  for (const [/* position */, mediumState] of tree.iterate(state.mediums)) {
    for (const recordingState of tree.iterate(mediumState)) {
      /* eslint-disable no-await-in-loop */
      responseData = await wsJsEditSubmission(
        dispatch,
        state,
        getRelationshipEditsForEntity(recordingState.targetTypeGroups),
      );
      if (responseData === null) {
        break mediumLoop;
      }

      for (const relatedWork of tree.iterate(recordingState.relatedWorks)) {
        responseData = await wsJsEditSubmission(
          dispatch,
          state,
          getRelationshipEditsForEntity(relatedWork.targetTypeGroups),
        );
        if (responseData === null) {
          break mediumLoop;
        }
      }
      /* eslint-enable no-await-in-loop */
    }
  }

  responseData = await wsJsEditSubmission(
    dispatch,
    state,
    getRelationshipEditsForEntity(findTargetTypeGroups(
      state.relationshipsBySource,
      state.entity,
    )),
  );
  if (responseData === null) {
    return;
  }

  responseData = await wsJsEditSubmission(
    dispatch,
    state,
    getRelationshipEditsForEntity(findTargetTypeGroups(
      state.relationshipsBySource,
      state.entity.releaseGroup,
    )),
  );
  if (responseData === null) {
    return;
  }

  if (editCount === 0) {
    alert(l('You haven’t made any changes!'));
  } else {
    window.location.replace('/release/' + state.entity.gid);
  }
}

async function submitEdits(
  dispatch: (ReleaseRelationshipEditorActionT) => void,
  currentStateRef: {
    +current: ReleaseRelationshipEditorStateT,
  },
) {
  const syncDispatch = (action: ReleaseRelationshipEditorActionT) => {
    flushSync(() => {
      dispatch(action);
    });
  };
  dispatch({type: 'start-submission'});
  await submitWorkEdits(syncDispatch, currentStateRef.current);
  await sleep(500);
  await submitRelationshipEdits(syncDispatch, currentStateRef.current);
}

function setRecordingsAsSelected(
  newState: {...ReleaseRelationshipEditorStateT},
  recordings: tree.ImmutableTree<RecordingT>,
  isSelected: boolean,
): void {
  newState.selectedRecordings = (
    isSelected ? tree.union : tree.difference
  )(
    newState.selectedRecordings,
    recordings,
    compareRecordings,
  );

  updateRecordingStates(
    newState,
    tree.iterate(recordings),
    (recordingState) => ({...recordingState, isSelected}),
  );
}

function setWorksAsSelected(
  newState: {...ReleaseRelationshipEditorStateT},
  works: tree.ImmutableTree<WorkT>,
  isSelected: boolean,
): void {
  newState.selectedWorks = (
    isSelected ? tree.union : tree.difference
  )(
    newState.selectedWorks,
    works,
    compareWorks,
  );

  updateWorkStates(
    newState,
    tree.iterate(works),
    (workState) => ({...workState, isSelected}),
  );
}

const reducer = reducerWithErrorHandling<
  ReleaseRelationshipEditorStateT,
  ReleaseRelationshipEditorActionT,
>(function (
  state: ReleaseRelationshipEditorStateT,
  action: ReleaseRelationshipEditorActionT,
): ReleaseRelationshipEditorStateT {
  const newState = cloneReleaseRelationshipEditorState(state);

  switch (action.type) {
    case 'move-relationship-down':
    case 'move-relationship-up':
    case 'remove-relationship':
    case 'toggle-ordering':
    case 'update-dialog-location':
    case 'update-entity':
    {
      runRelationshipEditorReducer(newState, action);
      break;
    }
    case 'load-tracks': {
      const tracks = action.tracks;
      if (tracks) {
        addTracksToState(newState, tracks, action.medium);
      }
      // falls through to runLazyReleaseReducer
    }
    case 'toggle-all-mediums':
    case 'toggle-medium': {
      runLazyReleaseReducer(newState, action);
      break;
    }
    case 'load-work-relationships': {
      updateRelationships(
        newState,
        getInitialRelationshipUpdates(
          action.relationships,
          action.work,
        ),
      );
      break;
    }
    case 'update-relationship-state': {
      const {
        batchSelectionCount,
        newRelationshipState,
        sourceEntity,
      } = action;

      if (batchSelectionCount == null) {
        runRelationshipEditorReducer(newState, action);
      } else {
        let selection = null;
        switch (sourceEntity.entityType) {
          case 'recording': {
            selection = state.selectedRecordings;
            break;
          }
          case 'work': {
            selection = state.selectedWorks;
            break;
          }
          default: {
            throw new Error(
              'Invalid source entity type from batch relationship dialog:' +
              sourceEntity.entityType,
            );
          }
        }
        const backward = isRelationshipBackward(
          newRelationshipState,
          sourceEntity,
        );
        const sourceEntityProp = backward ? 'entity1' : 'entity0';
        const getBatchUpdates = function* () {
          for (const newSource of tree.iterate(selection)) {
            const relationshipWithNewSource =
              cloneRelationshipState(newRelationshipState);
            relationshipWithNewSource.id = uniqueNegativeId();
            relationshipWithNewSource[sourceEntityProp] = newSource;
            yield *getUpdatesForAcceptedRelationship(
              newState,
              relationshipWithNewSource,
              newSource,
            );
          }
        };
        updateRelationships(newState, getBatchUpdates());
      }
      break;
    }
    case 'accept-batch-create-works-dialog': {
      const getBatchUpdates = function* () {
        for (const recording of tree.iterate(state.selectedRecordings)) {
          const mediums =
            expect(state.mediumsByRecordingId.get(recording.id));
          // Skip recordings that already have linked works.
          if (
            expect(tree.find(
              expect(tree.find(
                state.mediums,
                mediums[0],
                compareMediumWithMediumStateTuple,
              ))[1],
              recording.id,
              compareRecordingIdWithRecordingState,
            )).relatedWorks != null
          ) {
            continue;
          }
          const newWork = createWorkObject({
            _fromBatchCreateWorksDialog: true,
            id: uniqueNegativeId(),
            languages: action.languages.map(language => ({language})),
            name: recording.name,
            typeID: action.workType,
          });
          mergeLinkedEntities({
            work: {
              [String(newWork.id)]: newWork,
            },
          });
          const relationship: RelationshipStateT = {
            _original: null,
            _status: REL_STATUS_ADD,
            attributes: action.attributes,
            begin_date: null,
            editsPending: false,
            end_date: null,
            ended: false,
            entity0: recording,
            entity0_credit: '',
            entity1: newWork,
            entity1_credit: '',
            id: uniqueNegativeId(),
            linkOrder: 0,
            linkTypeID: RECORDING_OF_LINK_TYPE_ID,
          };
          yield {
            onConflict: onConflictThrowError,
            relationship,
            type: ADD_RELATIONSHIP,
          };
        }
      };
      updateRelationships(newState, getBatchUpdates());
      break;
    }
    case 'accept-edit-work-dialog': {
      const oldWork = action.work;
      const newWork = createWorkObject({
        _fromBatchCreateWorksDialog: true,
        id: uniqueNegativeId(),
        languages: action.languages.map(language => ({language})),
        name: clean(action.name),
        typeID: action.workType,
      });
      mergeLinkedEntities({
        work: {
          [String(newWork.id)]: newWork,
        },
      });
      const targetTypeGroups = findTargetTypeGroups(
        newState.relationshipsBySource,
        oldWork,
      );
      const updates = [];
      for (
        const relationship of
        iterateRelationshipsInTargetTypeGroups(targetTypeGroups)
      ) {
        const newRelationship = cloneRelationshipState(relationship);
        if (newRelationship.entity0.id === oldWork.id) {
          newRelationship.entity0 = newWork;
        }
        if (newRelationship.entity1.id === oldWork.id) {
          newRelationship.entity1 = newWork;
        }
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
      updateRelationships(newState, updates);
      break;
    }
    case 'toggle-select-all-recordings': {
      let allRecordings = null;
      for (
        const [/* mediumPosition */, recordingStateTree] of
        tree.iterate(newState.mediums)
      ) {
        for (const recordingState of tree.iterate(recordingStateTree)) {
          allRecordings = tree.insertIfNotExists(
            allRecordings,
            recordingState.recording,
            compareRecordings,
          );
        }
      }
      if (allRecordings) {
        setRecordingsAsSelected(
          newState,
          allRecordings,
          action.isSelected,
        );
      }
      break;
    }
    case 'toggle-select-all-works': {
      let allWorks = null;
      for (
        const [/* mediumPosition */, recordingStateTree] of
        tree.iterate(newState.mediums)
      ) {
        for (const recordingState of tree.iterate(recordingStateTree)) {
          for (const workState of tree.iterate(recordingState.relatedWorks)) {
            allWorks = tree.insertIfNotExists(
              allWorks,
              workState.work,
              compareWorks,
            );
          }
        }
      }
      if (allWorks) {
        setWorksAsSelected(
          newState,
          allWorks,
          action.isSelected,
        );
      }
      break;
    }
    case 'toggle-select-recording': {
      setRecordingsAsSelected(
        newState,
        tree.create(action.recording),
        action.isSelected,
      );
      break;
    }
    case 'toggle-select-work': {
      setWorksAsSelected(
        newState,
        tree.create(action.work),
        action.isSelected,
      );
      break;
    }
    case 'toggle-select-medium-recordings': {
      let mediumRecordings = null;
      for (const recordingState of tree.iterate(action.recordingStates)) {
        mediumRecordings = tree.insertIfNotExists(
          mediumRecordings,
          recordingState.recording,
          compareRecordings,
        );
      }
      if (mediumRecordings) {
        setRecordingsAsSelected(
          newState,
          mediumRecordings,
          action.isSelected,
        );
      }
      break;
    }
    case 'toggle-select-medium-works': {
      let mediumWorks = null;
      for (const recordingState of tree.iterate(action.recordingStates)) {
        for (const workState of tree.iterate(recordingState.relatedWorks)) {
          mediumWorks = tree.insertIfNotExists(
            mediumWorks,
            workState.work,
            compareWorks,
          );
        }
      }
      if (mediumWorks) {
        setWorksAsSelected(
          newState,
          mediumWorks,
          action.isSelected,
        );
      }
      break;
    }
    case 'update-edit-note': {
      newState.editNoteField = {
        ...newState.editNoteField,
        value: action.editNote,
      };
      break;
    }
    case 'update-make-votable': {
      const field = newState.enterEditForm.field;
      newState.enterEditForm = {
        ...newState.enterEditForm,
        field: {
          ...field,
          make_votable: {
            ...field.make_votable,
            value: action.checked,
          },
        },
      };
      break;
    }
    case 'start-submission': {
      newState.submissionInProgress = true;
      newState.submissionError = null;
      break;
    }
    case 'stop-submission': {
      newState.submissionInProgress = false;
      newState.submissionError = action.error;
      break;
    }
    case 'update-submitted-relationships': {
      const {
        edits,
        responseData,
      } = action;

      if (__DEV__) {
        invariant(
          edits.length === responseData.edits.length,
        );
      }

      const updateRelationshipState = function (
        relationship: RelationshipStateT,
        callback: ({...RelationshipStateT}) => void,
      ) {
        const newRelationship =
          cloneRelationshipState(relationship);
        callback(newRelationship);
        updates.push(
          {
            relationship,
            throwIfNotExists: false,
            type: REMOVE_RELATIONSHIP,
          },
          {
            onConflict: onConflictUseGivenValue,
            relationship: newRelationship,
            type: ADD_RELATIONSHIP,
          },
        );
      };

      const updates = [];
      for (let i = 0; i < edits.length; i++) {
        const [relationships, wsJsEdit] = edits[i];
        const response = responseData.edits[i];

        switch (wsJsEdit.edit_type) {
          case EDIT_RELATIONSHIP_CREATE: {
            if (
              response.response === WS_EDIT_RESPONSE_OK &&
              response.relationship_id !== null
            ) {
              invariant(
                response.edit_type === EDIT_RELATIONSHIP_CREATE &&
                relationships.length === 1,
              );
              updateRelationshipState(
                relationships[0],
                (newRelationship) => {
                  /*:: invariant(response.relationship_id !== null); */
                  newRelationship.id = response.relationship_id;
                  newRelationship._original = newRelationship;
                  newRelationship._status = REL_STATUS_NOOP;
                },
              );
            }
            break;
          }
          case EDIT_RELATIONSHIP_EDIT: {
            if (response.response === WS_EDIT_RESPONSE_OK) {
              invariant(
                response.edit_type === EDIT_RELATIONSHIP_EDIT &&
                relationships.length === 1,
              );
              updateRelationshipState(
                relationships[0],
                (newRelationship) => {
                  const newOriginal = cloneRelationshipState(
                    newRelationship,
                  );
                  /*:: invariant(newRelationship._original); */
                  // Can't modify the link order via EDIT_RELATIONSHIP_EDIT
                  newOriginal.linkOrder = newRelationship._original.linkOrder;
                  newRelationship._original = newOriginal;
                  newRelationship._status = getRelationshipEditStatus(
                    newRelationship,
                  );
                },
              );
            }
            break;
          }
          case EDIT_RELATIONSHIPS_REORDER: {
            if (response.response === WS_EDIT_RESPONSE_OK) {
              invariant(
                response.edit_type === EDIT_RELATIONSHIPS_REORDER,
              );
              for (const relationship of relationships) {
                updateRelationshipState(
                  relationship,
                  (newRelationship) => {
                    /*:: invariant(newRelationship._original); */
                    const newOriginal = cloneRelationshipState(
                      newRelationship._original,
                    );
                    newOriginal.linkOrder = newRelationship.linkOrder;
                    newRelationship._original = newOriginal;
                    newRelationship._status = getRelationshipEditStatus(
                      newRelationship,
                    );
                  },
                );
              }
            }
            break;
          }
          case EDIT_WORK_CREATE: {
            if (response.response === WS_EDIT_RESPONSE_OK) {
              invariant(
                response.edit_type === EDIT_WORK_CREATE &&
                relationships.length === 1,
              );
              const relationship = relationships[0];
              const oldWork = relationship.entity1;
              const newWork = response.entity;
              updateRelationshipState(
                relationship,
                (newRelationship) => {
                  newRelationship.entity1 = newWork;
                },
              );
              const targetTypeGroups = findTargetTypeGroups(
                newState.relationshipsBySource,
                oldWork,
              );
              invariant(targetTypeGroups);
              for (
                const workRelationship of
                iterateRelationshipsInTargetTypeGroups(targetTypeGroups)
              ) {
                if (workRelationship.id === relationship.id) {
                  continue;
                }
                updateRelationshipState(
                  workRelationship,
                  (newWorkRelationship) => {
                    newWorkRelationship.entity1 = newWork;
                  },
                );
              }
            }
            break;
          }
          default: {
            invariant(response.edit_type === EDIT_RELATIONSHIP_DELETE);
          }
        }
      }
      updateRelationships(newState, updates);
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }

  return newState;
});

type MediumRelationshipEditorsPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +expandedMediums: $ReadOnlyMap<number, boolean>,
  +loadedTracks: LoadedTracksMapT,
  +mediums: MediumStateTreeT,
  +release: ReleaseWithMediumsT,
};

const MediumRelationshipEditors = React.memo(({
  dialogLocation,
  dispatch,
  expandedMediums,
  loadedTracks,
  mediums,
  release,
}: MediumRelationshipEditorsPropsT) => {
  const hasUnloadedTracksPerMedium =
    useUnloadedTracksMap(release.mediums, loadedTracks);
  const mediumElements = [];
  for (const [medium, recordingStates] of tree.iterate(mediums)) {
    mediumElements.push(
      <MediumRelationshipEditor
        dialogLocation={
          (
            dialogLocation != null &&
            (dialogLocation.track?.medium_id) === medium.id
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        hasUnloadedTracks={
          hasUnloadedTracksPerMedium.get(medium.id) || false}
        isExpanded={isMediumExpanded(expandedMediums, medium)}
        key={medium.id}
        medium={medium}
        recordingStates={recordingStates}
        release={release}
        tracks={getMediumTracks(loadedTracks, medium)}
      />,
    );
  }
  return mediumElements;
});

type TrackRelationshipsSectionPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +expandedMediums: $ReadOnlyMap<number, boolean>,
  +loadedTracks: LoadedTracksMapT,
  +mediums: MediumStateTreeT,
  +release: ReleaseWithMediumsT,
  +selectedRecordings: tree.ImmutableTree<RecordingT> | null,
  +selectedWorks: tree.ImmutableTree<WorkT> | null,
};

const TrackRelationshipsSection = React.memo(({
  dialogLocation,
  dispatch,
  expandedMediums,
  loadedTracks,
  mediums,
  release,
  selectedRecordings,
  selectedWorks,
}: TrackRelationshipsSectionPropsT) => {
  const recordingCount = selectedRecordings ? selectedRecordings.size : 0;
  const workCount = selectedWorks ? selectedWorks.size : 0;

  const selectAllRecordings = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      type: 'toggle-select-all-recordings',
    });
  }, [dispatch]);

  const selectAllWorks = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      isSelected: event.currentTarget.checked,
      type: 'toggle-select-all-works',
    });
  }, [dispatch]);

  return (
    <>
      <h2>{l('Track Relationships')}</h2>
      {mediums?.size ? (
        <>
          <RelationshipEditorBatchTools
            dialogLocation={
              (
                dialogLocation != null &&
                dialogLocation.batchSelection === true
              ) ? dialogLocation : null
            }
            dispatch={dispatch}
            recordingSelectionCount={recordingCount}
            workSelectionCount={workCount}
          />
          <span id="medium-toolbox">
            <ToggleAllMediumsButtons
              dispatch={dispatch}
              mediums={release.mediums}
            />
          </span>
          <table className="tbl" id="tracklist">
            <thead>
              <tr>
                <th className="pos t">{l('#')}</th>
                <th className="recordings">
                  <input
                    className="all-recordings"
                    defaultChecked={false}
                    onChange={selectAllRecordings}
                    type="checkbox"
                  />
                  {' '}
                  {l('Recording')}
                  {' '}
                  {bracketedText(texp.ln(
                    '{n} recording selected',
                    '{n} recordings selected',
                    recordingCount,
                    {n: recordingCount},
                  ))}
                </th>
                <th className="works">
                  <input
                    className="all-works"
                    defaultChecked={false}
                    onChange={selectAllWorks}
                    type="checkbox"
                  />
                  {' '}
                  {l('Related Works')}
                  {' '}
                  {bracketedText(texp.ln(
                    '{n} work selected',
                    '{n} works selected',
                    workCount,
                    {n: workCount},
                  ))}
                </th>
              </tr>
            </thead>
            <MediumRelationshipEditors
              dialogLocation={
                (
                  dialogLocation != null &&
                  dialogLocation.batchSelection !== true
                ) ? dialogLocation : null
              }
              dispatch={dispatch}
              expandedMediums={expandedMediums}
              loadedTracks={loadedTracks}
              mediums={mediums}
              release={release}
            />
          </table>
        </>
      ) : (
        <p>
          {l(
            `We have no information about this release’s media and
             tracklist.`,
          )}
        </p>
      )}
    </>
  );
});

type ReleaseRelationshipSectionPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +relationshipsBySource: RelationshipSourceGroupsT,
  +release: ReleaseWithMediumsT,
};

const ReleaseRelationshipSection = React.memo(({
  dialogLocation,
  dispatch,
  relationshipsBySource,
  release,
}: ReleaseRelationshipSectionPropsT) => {
  if (dialogLocation != null) {
    invariant(dialogLocation.source.id === release.id);
  }

  const releaseCredits = React.useMemo(() => {
    return findTargetTypeGroups(
      relationshipsBySource,
      release,
    );
  }, [relationshipsBySource, release]);

  return (
    <>
      <h2>{l('Release Relationships')}</h2>
      <div className="ars" id="release-rels">
        <RelationshipTargetTypeGroups
          dialogLocation={dialogLocation}
          dispatch={dispatch}
          source={release}
          targetTypeGroups={releaseCredits}
          track={null}
        />
      </div>
    </>
  );
});

type ReleaseGroupRelationshipSectionPropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (ReleaseRelationshipEditorActionT) => void,
  +relationshipsBySource: RelationshipSourceGroupsT,
  +releaseGroup: ReleaseGroupT,
};

const ReleaseGroupRelationshipSection = React.memo(({
  dialogLocation,
  dispatch,
  relationshipsBySource,
  releaseGroup,
}: ReleaseGroupRelationshipSectionPropsT) => {
  if (dialogLocation != null) {
    invariant(dialogLocation.source.id === releaseGroup.id);
  }

  const releaseGroupCredits = React.useMemo(() => {
    return findTargetTypeGroups(
      relationshipsBySource,
      releaseGroup,
    );
  }, [relationshipsBySource, releaseGroup]);

  return (
    <>
      <h2>{l('Release Group Relationships')}</h2>
      <div className="ars" id="release-group-rels">
        <RelationshipTargetTypeGroups
          dialogLocation={dialogLocation}
          dispatch={dispatch}
          source={releaseGroup}
          targetTypeGroups={releaseGroupCredits}
          track={null}
        />
      </div>
    </>
  );
});

let ReleaseRelationshipEditor: React.AbstractComponent<{}, void> = (
): React.MixedElement => {
  const [state, dispatch] = React.useReducer(
    reducer,
    null,
    createInitialState,
  );

  const sourceGroupsContext = React.useMemo(() => ({
    existing: state.existingRelationshipsBySource,
    pending: state.relationshipsBySource,
  }), [
    state.existingRelationshipsBySource,
    state.relationshipsBySource,
  ]);

  const handleEditNoteChange = React.useCallback((event) => {
    dispatch({
      editNote: event.currentTarget.value,
      type: 'update-edit-note',
    });
  }, [dispatch]);

  const handleMakeVotableChange = React.useCallback((event) => {
    dispatch({
      checked: event.currentTarget.checked,
      type: 'update-make-votable',
    });
  }, [dispatch]);

  const currentStateRef = React.useRef(state);

  React.useEffect(() => {
    currentStateRef.current = state;

    // Expose internal state for userscripts.

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

  const handleSubmit = React.useCallback((
    event: SyntheticEvent<HTMLFormElement>,
  ) => {
    event.preventDefault();
    submitEdits(dispatch, currentStateRef);
  }, [dispatch]);

  const dialogLocation = state.dialogLocation;

  return (
    <RelationshipSourceGroupsContext.Provider value={sourceGroupsContext}>
      <TrackRelationshipsSection
        dialogLocation={
          (
            dialogLocation != null &&
            (
              dialogLocation.source.entityType === 'recording' ||
              dialogLocation.source.entityType === 'work'
            )
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        expandedMediums={state.expandedMediums}
        loadedTracks={state.loadedTracks}
        mediums={state.mediums}
        release={state.entity}
        selectedRecordings={state.selectedRecordings}
        selectedWorks={state.selectedWorks}
      />

      <ReleaseRelationshipSection
        dialogLocation={
          (
            dialogLocation != null &&
            dialogLocation.source.entityType === 'release'
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        relationshipsBySource={state.relationshipsBySource}
        release={state.entity}
      />

      <ReleaseGroupRelationshipSection
        dialogLocation={
          (
            dialogLocation != null &&
            dialogLocation.source.entityType === 'release_group'
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        relationshipsBySource={state.relationshipsBySource}
        releaseGroup={state.entity.releaseGroup}
      />

      {state.submissionError == null ? null : (
        <p className="warning" id="errors-msg">
          {state.submissionError}
        </p>
      )}

      <form
        action=""
        id="relationship-editor-form"
        onSubmit={handleSubmit}
      >
        <EnterEditNote
          controlled
          field={state.editNoteField}
          onChange={handleEditNoteChange}
        />
        <EnterEdit
          controlled
          disabled={state.submissionInProgress}
          form={state.enterEditForm}
          onChange={handleMakeVotableChange}
        />
        {state.submissionInProgress ? (
          <div className="row no-label">
            <span className="loading-message">
              {l('Submitting edits...')}
            </span>
          </div>
        ) : null}
      </form>
    </RelationshipSourceGroupsContext.Provider>
  );
};

ReleaseRelationshipEditor =
  withLoadedTypeInfoForRelationshipEditor<{}, void>(
    ReleaseRelationshipEditor,
    ['language', 'work_type'],
  );

ReleaseRelationshipEditor = hydrate<{}>(
  'div.release-relationship-editor',
  ReleaseRelationshipEditor,
);

export default ReleaseRelationshipEditor;
