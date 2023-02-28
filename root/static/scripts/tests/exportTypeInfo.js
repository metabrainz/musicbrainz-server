/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../common/linkedEntities.mjs';
import MB from '../common/MB.js';
import {groupBy} from '../common/utility/arrays.js';

let typeInfoLoaded = false;

function editorMayEditTypes(type0, type1) {
  var types = [type0, type1].sort().join('-');

  if (/^area-area|area-url$/.test(types)) {
    return !!MB.userIsLocationEditor;
  } else if (/^area-instrument|instrument-instrument|instrument-url$/.test(types)) {
    return !!MB.userIsRelationshipEditor;
  }

  return true;
}

export default function exportTypeInfo(typeInfo, attrInfo) {
  if (typeInfoLoaded) {
    return;
  }
  const attrChildren = groupBy(attrInfo, x => String(x.parent_id));

  function mapItems(result, item) {
    if (item.id) {
      result[item.id] = item;
    }
    if (item.gid) {
      result[item.gid] = item;
    }
    switch (item.entityType) {
      case 'link_attribute_type':
        const children = attrChildren.get(String(item.id));
        if (children) {
          item.children = children;
        }
        break;
      case 'link_type':
        if (item.children) {
          item.children.forEach((child) => {
            mapItems(result, child);
          });
        }
        break;
    }
    return result;
  }

  Object.assign(linkedEntities, {
    link_type_tree: typeInfo,
    link_type: Object.values(typeInfo).flat().reduce(mapItems, {}),
    link_attribute_type: attrInfo.reduce(mapItems, {}),
  });

  for (const type of Object.values(linkedEntities.link_type)) {
    for (const [id, typeAttr] of Object.entries(type.attributes)) {
      typeAttr.attribute = linkedEntities.link_attribute_type[id];
    }
  }

  MB.allowedRelations = {};

  Object.keys(typeInfo).forEach(function (typeString) {
    var types = typeString.split('-');
    var type0 = types[0];
    var type1 = types[1];

    if (!editorMayEditTypes(type0, type1)) {
      return;
    }

    (MB.allowedRelations[type0] = MB.allowedRelations[type0] || [])
      .push(type1);

    if (type0 !== type1) {
      (MB.allowedRelations[type1] = MB.allowedRelations[type1] || [])
        .push(type0);
    }
  });

  // Sort each list of types alphabetically.
  Object.values(MB.allowedRelations).forEach(x => x.sort());

  for (const attr of Object.values(linkedEntities.link_attribute_type)) {
    attr.root = linkedEntities.link_attribute_type[attr.root_id];
  }

  typeInfoLoaded = true;
}
