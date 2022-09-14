/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';
import * as tree from 'weight-balanced-tree';

import {defaultContext} from '../../../context.mjs';
import linkedEntities from '../common/linkedEntities.mjs';
import {
  createInitialState,
  reducer,
} from '../relationship-editor/components/RelationshipEditor.js';
import {REL_STATUS_ADD} from '../relationship-editor/constants.js';
import type {
  RelationshipEditorStateT,
  RelationshipLinkTypeGroupT,
  RelationshipPhraseGroupT,
  RelationshipSourceGroupsT,
  RelationshipSourceGroupT,
  RelationshipStateT,
  RelationshipTargetTypeGroupT,
} from '../relationship-editor/types.js';
import {
  compareLinkAttributeIds,
} from '../relationship-editor/utility/compareRelationships.js';
import {
  mergeRelationshipStates,
} from '../relationship-editor/utility/mergeRelationship.js';
import relationshipsAreIdentical
  from '../relationship-editor/utility/relationshipsAreIdentical.js';
import updateRelationships, {
  ADD_RELATIONSHIP,
} from '../relationship-editor/utility/updateRelationships.js';

import {
  artist,
  recording,
} from './relationship-editor/constants.js';

const $c = {
  ...defaultContext,
  stash: {
    ...defaultContext.stash,
    source_entity: artist,
  },
};

window[GLOBAL_JS_NAMESPACE] = {$c};

const initialState = createInitialState({
  formName: 'edit-artist',
  seededRelationships: undefined,
});

test('merging duplicate relationships', function (t) {
  let nonEndedRelationshipWithBeginDate = {
    _original: null,
    _status: REL_STATUS_ADD,
    attributes: ids2attrs([194, 277]),
    begin_date: {day: null, month: null, year: 2001},
    editsPending: false,
    end_date: null,
    ended: false,
    entity0: artist,
    entity0_credit: '',
    entity1: recording,
    entity1_credit: '',
    id: -1,
    linkOrder: 0,
    linkTypeID: 148,
  };

  let newState = addRelationship(
    initialState,
    recording,
    nonEndedRelationshipWithBeginDate,
  );

  let notDuplicateRelationship1 = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: null,
    end_date: {day: null, month: null, year: 2002},
    ended: true,
    id: -2,
  };

  newState = addRelationship(
    newState,
    recording,
    notDuplicateRelationship1,
  );

  currentRelationshipsEqual(
    t,
    newState,
    [nonEndedRelationshipWithBeginDate, notDuplicateRelationship1],
    'relationships were not merged where ended differs',
  );

  let relationshipEnded = {
    ...nonEndedRelationshipWithBeginDate,
    ended: true,
  };

  let duplicateRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: null,
    end_date: {day: null, month: null, year: 2002},
    ended: true,
    id: -2,
  };

  newState = addRelationships(
    initialState,
    recording,
    [relationshipEnded, duplicateRelationship],
  );

  let mergedRelationship = mergeRelationshipStates(
    duplicateRelationship,
    relationshipEnded,
  );

  currentRelationshipsEqual(
    t,
    newState,
    [mergedRelationship],
    'relationships were merged where ended is the same',
  );

  t.deepEqual(
    tree.toArray(
      tree.map<LinkAttrT, number>(
        mergedRelationship?.attributes ?? null,
        attr => attr.typeID,
      ),
    ).sort(),
    [194, 277],
    'attributes are the same',
  );

  t.deepEqual(
    {
      begin_date: mergedRelationship?.begin_date,
      end_date: mergedRelationship?.end_date,
      ended: mergedRelationship?.ended,
    },
    {
      begin_date: {year: 2001, month: null, day: null},
      end_date: {year: 2002, month: null, day: null},
      ended: true,
    },
    'date period is merged correctly',
  );

  let notDuplicateRelationship2 = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: {day: null, month: null, year: 2003},
    end_date: {day: null, month: null, year: 2004},
    id: -2,
  };

  newState = addRelationships(
    initialState,
    recording,
    [nonEndedRelationshipWithBeginDate, notDuplicateRelationship2],
  );

  currentRelationshipsEqual(
    t,
    newState,
    [nonEndedRelationshipWithBeginDate, notDuplicateRelationship2],
    'relationship with different date is not merged',
  );

  let laterRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    ended: true,
  };

  let earlierRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: null,
    end_date: {day: null, month: null, year: 2000},
    ended: true,
    id: -2,
  };

  newState = addRelationships(
    initialState,
    recording,
    [laterRelationship, earlierRelationship],
  );

  currentRelationshipsEqual(
    t,
    newState,
    [laterRelationship, earlierRelationship],
    'relationships were not merged where it would lead to invalid date period',
  );

  let emptyDatesRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: null,
  };

  let newDatedRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: {day: null, month: null, year: 2000},
    end_date: {day: null, month: null, year: 2000},
    ended: true,
    id: -2,
  };

  newState = addRelationships(
    initialState,
    recording,
    [emptyDatesRelationship, newDatedRelationship],
  );

  mergedRelationship = mergeRelationshipStates(
    newDatedRelationship,
    emptyDatesRelationship,
  );

  currentRelationshipsEqual(
    t,
    newState,
    [mergedRelationship],
    'relationships were merged when one date period was empty',
  );

  let emptyDatesEndedRelationship = {
    ...nonEndedRelationshipWithBeginDate,
    begin_date: null,
    ended: true,
    id: -2,
  };

  newState = addRelationships(
    initialState,
    recording,
    [emptyDatesEndedRelationship, nonEndedRelationshipWithBeginDate],
  );

  currentRelationshipsEqual(
    t,
    newState,
    [emptyDatesEndedRelationship, nonEndedRelationshipWithBeginDate],
    'relationships were not merged when original was ended even if date period is empty',
  );

  t.end();
});

function addRelationships(
  rootState: RelationshipEditorStateT,
  source: CoreEntityT,
  relationships: $ReadOnlyArray<RelationshipStateT>,
): RelationshipEditorStateT {
  let newState = rootState;
  relationships.forEach((relationship) => {
    newState = addRelationship(newState, source, relationship);
  });
  return newState;
}

function addRelationship(
  rootState: RelationshipEditorStateT,
  source: CoreEntityT,
  relationship: RelationshipStateT,
): RelationshipEditorStateT {
  return reducer(
    rootState,
    {
      batchSelectionCount: 0,
      creditsToChangeForSource: '',
      creditsToChangeForTarget: '',
      newRelationshipState: relationship,
      oldRelationshipState: null,
      sourceEntity: source,
      type: 'update-relationship-state',
    },
  );
}

function currentRelationshipsEqual(
  t: tape$Context,
  rootState: RelationshipEditorStateT,
  relationships: $ReadOnlyArray<RelationshipStateT | null>,
  msg: string,
) {
  t.ok(tree.equals(
    rootState.relationshipsBySource,
    createRelationshipSourceGroups(relationships),
    areSourceGroupsEqual,
  ), msg);
}

function createRelationshipSourceGroups(
  relationships: $ReadOnlyArray<RelationshipStateT | null>,
): RelationshipSourceGroupsT {
  const writableRootState = {...initialState};
  updateRelationships(
    writableRootState,
    relationships.reduce((accum, relationship) => {
      if (relationship) {
        accum.push({
          relationship,
          type: ADD_RELATIONSHIP,
        });
      }
      return accum;
    }, []),
  );
  return writableRootState.relationshipsBySource;
}

function areSourceGroupsEqual(
  a: RelationshipSourceGroupT,
  b: RelationshipSourceGroupT,
): boolean {
  const [entityA, targetTypeGroupA] = a;
  const [entityB, targetTypeGroupB] = b;
  return (
    entityA.entityType === entityB.entityType &&
    entityA.id === entityB.id &&
    tree.equals(
      targetTypeGroupA,
      targetTypeGroupB,
      areTargetTypeGroupsEqual,
    )
  );
}

function areTargetTypeGroupsEqual(
  a: RelationshipTargetTypeGroupT,
  b: RelationshipTargetTypeGroupT,
): boolean {
  const [targetTypeA, linkTypeGroupsA] = a;
  const [targetTypeB, linkTypeGroupsB] = b;
  return (
    targetTypeA === targetTypeB &&
    tree.equals(
      linkTypeGroupsA,
      linkTypeGroupsB,
      areLinkTypeGroupsEqual,
    )
  );
}

function areLinkTypeGroupsEqual(
  a: RelationshipLinkTypeGroupT,
  b: RelationshipLinkTypeGroupT,
): boolean {
  return (
    a.backward === b.backward &&
    a.typeId === b.typeId &&
    tree.equals(a.phraseGroups, b.phraseGroups, arePhraseGroupsEqual)
  );
}

function arePhraseGroupsEqual(
  a: RelationshipPhraseGroupT,
  b: RelationshipPhraseGroupT,
): boolean {
  return (
    a.textPhrase === b.textPhrase &&
    tree.equals(a.relationships, b.relationships, relationshipsAreIdentical)
  );
}

function id2attr(id: number): LinkAttrT {
  const type = linkedEntities.link_attribute_type[id];
  return {
    type,
    typeID: id,
    typeName: type.name,
  };
}

function ids2attrs(
  ids: $ReadOnlyArray<number>,
): tree.ImmutableTree<LinkAttrT> | null {
  return tree.fromDistinctAscArray(
    ids.map(id2attr).sort(compareLinkAttributeIds),
  );
}
