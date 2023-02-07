/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import createFastObjectCloneFunction
  from '../../common/utility/createFastObjectCloneFunction.js';
import type {
  RelationshipEditorStateT,
  RelationshipLinkTypeGroupT,
  RelationshipPhraseGroupT,
  RelationshipStateT,
  ReleaseRelationshipEditorStateT,
} from '../types.js';

export const cloneRelationshipEditorState:
  (RelationshipEditorStateT) => {...RelationshipEditorStateT} =
  createFastObjectCloneFunction<RelationshipEditorStateT>({
    dialogLocation: null,
    entity: null,
    existingRelationshipsBySource: null,
    reducerError: null,
    relationshipsBySource: null,
  });

export const cloneReleaseRelationshipEditorState:
  (ReleaseRelationshipEditorStateT) => {...ReleaseRelationshipEditorStateT} =
  createFastObjectCloneFunction<ReleaseRelationshipEditorStateT>({
    dialogLocation: null,
    editNoteField: null,
    enterEditForm: null,
    entity: null,
    existingRelationshipsBySource: null,
    expandedMediums: null,
    loadedTracks: null,
    mediums: null,
    mediumsByRecordingId: null,
    reducerError: null,
    relationshipsBySource: null,
    selectedRecordings: null,
    selectedWorks: null,
    submissionError: null,
    submissionInProgress: null,
  });

export const cloneLinkTypeGroup:
  (RelationshipLinkTypeGroupT) => {...RelationshipLinkTypeGroupT} =
  createFastObjectCloneFunction<RelationshipLinkTypeGroupT>({
    backward: null,
    phraseGroups: null,
    typeId: null,
  });

export const cloneLinkPhraseGroup:
  (RelationshipPhraseGroupT) => {...RelationshipPhraseGroupT} =
  createFastObjectCloneFunction<RelationshipPhraseGroupT>({
    relationships: null,
    textPhrase: null,
  });

export const cloneRelationshipState:
  (RelationshipStateT) => {...RelationshipStateT} =
  createFastObjectCloneFunction<RelationshipStateT>({
    _lineage: null,
    _original: null,
    _status: null,
    attributes: null,
    begin_date: null,
    editsPending: null,
    end_date: null,
    ended: null,
    entity0: null,
    entity0_credit: null,
    entity1: null,
    entity1_credit: null,
    id: null,
    linkOrder: null,
    linkTypeID: null,
  });
