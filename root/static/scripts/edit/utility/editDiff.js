/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import fastDiff, {type FastEditDiff} from 'fast-diff';
import genericDiff, {type GenericEditDiff} from 'generic-diff';

const INSERT: 1 = 1;
const EQUAL: 2 = 2;
const DELETE: 3 = 3;
const CHANGE: 4 = 4;

export type NonChangeEditType =
  | typeof DELETE
  | typeof EQUAL
  | typeof INSERT;

export type EditType =
  | NonChangeEditType
  | typeof CHANGE;

const CLASS_MAP: {+[editType: EditType]: string} = {
  [CHANGE]: '',
  [DELETE]: 'diff-only-a',
  [EQUAL]: '',
  [INSERT]: 'diff-only-b',
};

const FAST_DIFF_CHANGE_TYPE_MAP = new Map<number, NonChangeEditType>([
  [fastDiff.INSERT, INSERT],
  [fastDiff.EQUAL, EQUAL],
  [fastDiff.DELETE, DELETE],
]);

export {CHANGE, CLASS_MAP, DELETE, EQUAL, INSERT};

export type EditDiff<+T> = {
  +newItems: $ReadOnlyArray<T>,
  +oldItems: $ReadOnlyArray<T>,
  +type: EditType,
};

export type StringEditDiff = {
  +newText: string,
  +oldText: string,
  +type: EditType,
};

function getChangeType<T>(diff: GenericEditDiff<T>): NonChangeEditType {
  if (!diff.added && !diff.removed) {
    return EQUAL;
  }
  return diff.added ? INSERT : DELETE;
}

/*
 * Combines adjacent (DELETE, INSERT) diffs into a single CHANGE diff.
 * Note: for large strings, this is slow; use stringEditDiff instead!
 */
export default function editDiff<T>(
  oldSide: $ReadOnlyArray<T>,
  newSide: $ReadOnlyArray<T>,
  eqFunc?: (T, T) => boolean,
): $ReadOnlyArray<EditDiff<T>> {
  const diffs: $ReadOnlyArray<GenericEditDiff<T>> =
    genericDiff(oldSide, newSide, eqFunc);
  const normalized = [];

  for (let i = 0; i < diffs.length; i++) {
    const diff = diffs[i];

    const changeType = getChangeType<T>(diff);

    let nextDiff;
    if ((i + 1) < diffs.length) {
      nextDiff = diffs[i + 1];
    }

    let oldItems: $ReadOnlyArray<T> = [];
    let newItems: $ReadOnlyArray<T> = [];

    let normalizedChangeType: EditType = changeType;
    match (changeType) {
      INSERT => {
        newItems = diff.items;
      }
      EQUAL => {
        oldItems = diff.items;
        newItems = diff.items;
      }
      DELETE => {
        oldItems = diff.items;

        if (nextDiff && getChangeType(nextDiff) === INSERT) {
          i++; // skip next
          normalizedChangeType = CHANGE;
          newItems = nextDiff.items;
        }
      }
    }

    normalized.push({newItems, oldItems, type: normalizedChangeType});
  }

  return normalized;
}

export function stringEditDiff(
  oldSide: string,
  newSide: string,
): $ReadOnlyArray<StringEditDiff> {
  const diffs: $ReadOnlyArray<FastEditDiff> =
    fastDiff(oldSide, newSide);
  const normalized = [];

  for (let i = 0; i < diffs.length; i++) {
    const diff = diffs[i];

    const changeType: ?NonChangeEditType =
      FAST_DIFF_CHANGE_TYPE_MAP.get(diff[0]);
    invariant(
      changeType != null,
      'fast-diff change type is null or undefined',
    );

    let nextDiff;
    if ((i + 1) < diffs.length) {
      nextDiff = diffs[i + 1];
    }

    let newText = '';
    let oldText = '';

    let normalizedChangeType: EditType = changeType;
    match (changeType) {
      INSERT => {
        newText = diff[1];
      }
      EQUAL => {
        newText = diff[1];
        oldText = diff[1];
      }
      DELETE => {
        oldText = diff[1];

        if (nextDiff) {
          const nextChangeType = FAST_DIFF_CHANGE_TYPE_MAP.get(nextDiff[0]);
          if (nextChangeType === INSERT) {
            i++; // skip next
            normalizedChangeType = CHANGE;
            newText = nextDiff[1];
          }
        }
      }
    }

    normalized.push({oldText, newText, type: normalizedChangeType});
  }

  return normalized;
}
