/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import areDatesEqual from '../../common/utility/areDatesEqual.js';
import memoize from '../../common/utility/memoize.js';
import type {
  LinkRelationshipStateT,
  LinkRelationshipStatusT,
} from '../types.js';

const getLinkRelationshipStatus: (
  relationship: LinkRelationshipStateT,
) => LinkRelationshipStatusT = memoize((
  relationship: LinkRelationshipStateT,
): LinkRelationshipStatusT => {
  const originalState = relationship.originalState;
  const removed = relationship.removed;
  const isNew = originalState === null;
  const changes: {...LinkRelationshipStatusT['changes']} = {};
  if (!isNew) {
    /*:: invariant(originalState !== null); */
    if (!areDatesEqual(relationship.beginDate, originalState.beginDate)) {
      changes.beginDate = {
        new: relationship.beginDate,
        old: originalState.beginDate,
      };
    }
    if (!areDatesEqual(relationship.endDate, originalState.endDate)) {
      changes.endDate = {
        new: relationship.endDate,
        old: originalState.endDate,
      };
    }
    if (relationship.ended !== originalState.ended) {
      changes.ended = {new: relationship.ended, old: originalState.ended};
    }
    if (relationship.entityCredit !== originalState.entityCredit) {
      changes.entityCredit = {
        new: relationship.entityCredit,
        old: originalState.entityCredit,
      };
    }
    if (relationship.linkTypeID !== originalState.linkTypeID) {
      changes.linkTypeID = {
        new: relationship.linkTypeID,
        old: originalState.linkTypeID,
      };
    }
    if (relationship.url !== originalState.url) {
      changes.url = {new: relationship.url, old: originalState.url};
    }
    if (relationship.video !== originalState.video) {
      changes.video = {new: relationship.video, old: originalState.video};
    }
  }
  return {
    changes,
    isNew,
    removed,
  };
});

export default getLinkRelationshipStatus;
