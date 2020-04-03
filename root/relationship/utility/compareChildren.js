/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../../static/scripts/common/i18n';

export default function compareChildren(
  a: LinkTypeT | LinkAttrTypeT,
  b: LinkTypeT | LinkAttrTypeT,
): number {
  if (a.child_order === b.child_order) {
    return compare(a.name, b.name);
  }
  return a.child_order < b.child_order
    ? -1
    : (a.child_order > b.child_order ? 1 : 0);
}
