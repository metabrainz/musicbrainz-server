/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {compare} from '../i18n.js';

import {groupBy} from './arrays.js';

/*
 * Unlike MB.forms.buildOptionsTree, this builds from a flat list.
 * TODO: These should probably be combined at some point?
 */
export default function buildOptionList<+T>(
  options: $ReadOnlyArray<OptionTreeT<T>>,
  localizeName: (string) => string,
): OptionListT {
  const optionsByParentId = groupBy(options, option => option.parent_id);

  const compareChildren = (a: OptionTreeT<T>, b: OptionTreeT<T>) => {
    return (
      (a.child_order - b.child_order) ||
      compare(localizeName(a.name), localizeName(b.name))
    );
  };

  const getOptionsByParentId = (parentId: number | null, level: number) => {
    const options = optionsByParentId.get(parentId);
    if (!options) {
      return [];
    }
    options.sort(compareChildren);
    return options.flatMap((option) => {
      return [
        {
          text: '\xA0'.repeat(level * 2) + localizeName(option.name),
          value: option.id,
        },
        ...getOptionsByParentId(option.id, level + 1),
      ];
    });
  };

  return getOptionsByParentId(null, 0);
}
