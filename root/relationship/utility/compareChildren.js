/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../../static/scripts/common/i18n.js';

export default function compareChildren(
  a: LinkTypeT | LinkAttrTypeT,
  b: LinkTypeT | LinkAttrTypeT,
): number {
  return (
    (a.child_order - b.child_order) ||
    compare(l_relationships(a.name), l_relationships(b.name))
  );
}
