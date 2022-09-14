/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import localizeLinkAttributeTypeDescription
  from '../../common/i18n/localizeLinkAttributeTypeDescription.js';
import localizeLinkAttributeTypeName
  from '../../common/i18n/localizeLinkAttributeTypeName.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {groupBy} from '../../common/utility/arrays.js';
import {unaccent} from '../../common/utility/strings.js';

function normalize(str: string): string {
  return unaccent(str).toLowerCase();
}

export function exportLinkTypeInfo(
  allLinkTypes: $ReadOnlyArray<LinkTypeT>,
): void {
  const linkTypeChildren =
    groupBy(allLinkTypes, x => String(x.parent_id));

  const linkTypeTree: {
    [entityTypes: string]: Array<LinkTypeT>,
  } = {};

  function mapItems<-T: LinkTypeT>(
    result: {-[idOrGid: StrOrNum]: T},
    item: T,
  ) {
    if (item.id) {
      result[item.id] = item;
    }
    if (item.gid) {
      result[item.gid] = item;
    }

    const children = linkTypeChildren.get(String(item.id));
    if (children) {
      item.children = children;
    }

    item.l_name = l_relationships(item.name);
    item.l_name_normalized = normalize(item.l_name);

    if (item.link_phrase) {
      item.l_link_phrase = l_relationships(item.link_phrase);
    }

    if (item.reverse_link_phrase) {
      item.l_reverse_link_phrase =
        l_relationships(item.reverse_link_phrase);
    }

    if (item.description) {
      item.l_description = l_relationships(item.description);
    }

    if (item.parent_id == null) {
      const entityTypes = item.type0 + '-' + item.type1;
      (linkTypeTree[entityTypes] ||
        (linkTypeTree[entityTypes] = []))
        .push(item);
    }
  }

  Object.assign(linkedEntities, {
    link_type: allLinkTypes.reduce((accum, linkType) => {
      mapItems<LinkTypeT>(accum, linkType);
      return accum;
    }, {}),
    link_type_tree: linkTypeTree,
  });
}

export function exportLinkAttributeTypeInfo(
  allLinkAttributeTypes: $ReadOnlyArray<LinkAttrTypeT>,
): void {
  const linkAttributeTypeChildren =
    groupBy(allLinkAttributeTypes, x => String(x.parent_id));

  function mapItems<-T: LinkAttrTypeT>(
    result: {-[idOrGid: StrOrNum]: T},
    item: T,
  ) {
    if (item.id) {
      result[item.id] = item;
    }
    if (item.gid) {
      result[item.gid] = item;
    }

    const children = linkAttributeTypeChildren.get(String(item.id));
    if (children) {
      item.children = children;
    }

    item.l_name = localizeLinkAttributeTypeName(item);
    item.l_name_normalized = normalize(item.l_name);

    item.l_description = localizeLinkAttributeTypeDescription(item);
  }

  Object.assign(linkedEntities, {
    link_attribute_type:
      allLinkAttributeTypes.reduce((accum, linkAttrType) => {
        mapItems<LinkAttrTypeT>(accum, linkAttrType);
        return accum;
      }, {}),
  });
}
