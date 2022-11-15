/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compareStrings} from '../../common/utility/compare.js';
import type {
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
  a: CentralEntityT,
  [b]: RelationshipSourceGroupT,
): number {
  return (
    compareStrings(a.entityType, b.entityType) ||
    (a.id - b.id)
  );
}

export function compareWorks(a: WorkT, b: WorkT): number {
  return a.id - b.id;
}
