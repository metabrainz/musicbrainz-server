/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';
import {onConflictUseGivenValue} from 'weight-balanced-tree/update';

import areDatePeriodsEqual from '../../common/utility/areDatePeriodsEqual.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import isDateEmpty from '../../common/utility/isDateEmpty.js';
import {isDatePeriodValid} from '../../edit/utility/dates.js';
import type {
  RelationshipStateT,
  RelationshipTargetTypeGroupsT,
} from '../types.js';

import {cloneRelationshipState} from './cloneState.js';
import {
  findExistingRelationship,
  findLinkPhraseGroupInTargetTypeGroups,
} from './findState.js';
import getRelationshipEditStatus from './getRelationshipEditStatus.js';
import mergeDates from './mergeDates.js';
import relationshipsHaveSamePhraseGroup
  from './relationshipsHaveSamePhraseGroup.js';
import {
  type RelationshipUpdateT,
  ADD_RELATIONSHIP,
  REMOVE_RELATIONSHIP,
} from './updateRelationships.js';

export function mergeRelationshipStates(
  sourceRelationship: RelationshipStateT,
  targetRelationship: RelationshipStateT,
): RelationshipStateT | null {
  /*
   * Attempts to merge `sourceRelationship` into `targetRelationship`,
   * combining dates and entity credits where possible.  This is used after
   * accepting a relationship dialog: `sourceRelationship` is the one to be
   * added/edited.
   */

  if (
    sourceRelationship.id === targetRelationship.id ||
    sourceRelationship.linkOrder !== targetRelationship.linkOrder ||
    !relationshipsHaveSamePhraseGroup(sourceRelationship, targetRelationship)
  ) {
    return null;
  }

  /*
   * If the relationships are identical, return `targetRelationship` to
   * indicate this to the caller.
   */
  if (
    sourceRelationship.entity0_credit === targetRelationship.entity0_credit &&
    sourceRelationship.entity1_credit === targetRelationship.entity1_credit &&
    areDatePeriodsEqual(sourceRelationship, targetRelationship)
  ) {
    return targetRelationship;
  }

  const mergedBeginDate = mergeDates(
    sourceRelationship.begin_date,
    targetRelationship.begin_date,
  );
  const mergedEndDate = mergeDates(
    sourceRelationship.end_date,
    targetRelationship.end_date,
  );
  if (
    !mergedBeginDate ||
    !mergedEndDate ||
    !isDatePeriodValid(mergedBeginDate, mergedEndDate)
  ) {
    return null;
  }

  /*
   * We want to avoid merging dates if one is ended and the other isn't,
   * unless one of them is empty and can safely be overwritten.
   */
  const isOneDateEmpty =
    (isDateEmpty(sourceRelationship.begin_date) &&
      isDateEmpty(sourceRelationship.end_date) &&
      !sourceRelationship.ended) ||
    (isDateEmpty(targetRelationship.begin_date) &&
      isDateEmpty(targetRelationship.end_date) &&
      !targetRelationship.ended);
  const isEndedSame =
    sourceRelationship.ended === targetRelationship.ended;

  if (!isOneDateEmpty && !isEndedSame) {
    return null;
  }

  const mergedRelationship = cloneRelationshipState(
    targetRelationship,
  );

  mergedRelationship.begin_date = mergedBeginDate;
  mergedRelationship.end_date = mergedEndDate;
  mergedRelationship.ended = isDateEmpty(mergedEndDate)
    ? (sourceRelationship.ended || targetRelationship.ended)
    : true;

  if (nonEmpty(sourceRelationship.entity0_credit)) {
    mergedRelationship.entity0_credit = sourceRelationship.entity0_credit;
  }

  if (nonEmpty(sourceRelationship.entity1_credit)) {
    mergedRelationship.entity1_credit = sourceRelationship.entity1_credit;
  }

  mergedRelationship._status = getRelationshipEditStatus(
    mergedRelationship,
  );

  return mergedRelationship;
}

export default function mergeRelationship(
  targetTypeGroups: RelationshipTargetTypeGroupsT | null,
  existingTargetTypeGroups: RelationshipTargetTypeGroupsT | null,
  sourceRelationship: RelationshipStateT,
  source: CoreEntityT,
): $ReadOnlyArray<RelationshipUpdateT> | null {
  // Refuse to merge an existing relationship.
  if (isDatabaseRowId(sourceRelationship.id)) {
    return null;
  }

  const linkPhraseGroup = findLinkPhraseGroupInTargetTypeGroups(
    targetTypeGroups,
    sourceRelationship,
    source,
  );

  let mergedRelationshipState = null;
  if (linkPhraseGroup) {
    for (
      const targetRelationshipState of
      tree.iterate(linkPhraseGroup.relationships)
    ) {
      mergedRelationshipState = mergeRelationshipStates(
        sourceRelationship,
        targetRelationshipState,
      );
      if (mergedRelationshipState === targetRelationshipState) {
        /*
         * The relationships are identical.  Return an empty array to indicate
         * to the caller that the relationship should be considered "merged"
         * already (with no update to perform).
         */
        return [];
      }
      if (mergedRelationshipState) {
        if (
          findExistingRelationship(
            existingTargetTypeGroups,
            mergedRelationshipState,
            source,
          ) !== null
        ) {
          return null;
        }
        return [
          {
            relationship: targetRelationshipState,
            throwIfNotExists: true,
            type: REMOVE_RELATIONSHIP,
          },
          {
            onConflict: onConflictUseGivenValue,
            relationship: mergedRelationshipState,
            type: ADD_RELATIONSHIP,
          },
        ];
      }
    }
  }

  return null;
}
