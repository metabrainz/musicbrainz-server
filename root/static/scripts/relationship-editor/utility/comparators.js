/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../../common/i18n.js';
import {compareStrings} from '../../common/utility/compare.js';
import type {
  MediumWorkStateT,
  RelationshipSourceGroupT,
} from '../types.js';

export function compareMediums(
  a: MediumWithRecordingsT,
  b: MediumWithRecordingsT,
): number {
  return a.id - b.id;
}

export function compareRecordings(a: RecordingT, b: RecordingT): number {
  return a.id - b.id;
}

export function compareSourceWithSourceGroup(
  a: RelatableEntityT,
  [b]: RelationshipSourceGroupT,
): number {
  return (
    compareStrings(a.entityType, b.entityType) ||
    (a.id - b.id)
  );
}

export function compareWorks(a: WorkT, b: WorkT): number {
  return compare(a.name, b.name) || (a.id - b.id);
}

export function compareWorkStates(
  a: MediumWorkStateT,
  b: MediumWorkStateT,
): number {
  return compareWorks(a.work, b.work);
}
