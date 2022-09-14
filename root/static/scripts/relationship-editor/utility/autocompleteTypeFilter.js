/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  ItemT as AutocompleteItemT,
} from '../../common/components/Autocomplete2/types.js';
import {unaccent} from '../../common/utility/strings.js';

export function autocompleteLinkAttributeTypeFilter(
  item: AutocompleteItemT<LinkAttrTypeT>,
  searchTerm: string,
): boolean {
  if (item.type === 'option') {
    const entity = item.entity;
    const lowerSearchTerm = unaccent(searchTerm).toLowerCase();
    return (entity.l_name_normalized ?? '').includes(lowerSearchTerm);
  }
  return true;
}

export function autocompleteLinkTypeFilter(
  item: AutocompleteItemT<LinkTypeT>,
  searchTerm: string,
): boolean {
  if (item.type === 'option') {
    const entity = item.entity;
    const lowerSearchTerm = unaccent(searchTerm).toLowerCase();
    return (
      (entity.l_name_normalized ?? '').includes(lowerSearchTerm) ||
      (entity.l_link_phrase ?? '').includes(lowerSearchTerm) ||
      (entity.l_reverse_link_phrase ?? '').includes(lowerSearchTerm)
    );
  }
  return true;
}
