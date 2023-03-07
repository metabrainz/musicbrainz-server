/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {ENTITY_NAMES} from '../../common/constants.js';
import {compare} from '../../common/i18n.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {
  isLocationEditor,
  isRelationshipEditor,
} from '../../common/utility/privileges.js';
import type {
  TargetTypeOptionsT,
  TargetTypeOptionT,
} from '../types.js';
import {
  hasDialogLinkTypeOptions,
} from '../utility/getDialogLinkTypeOptions.js';

function editorMayEditTypes(
  user: ActiveEditorT,
  typeString: string,
) {
  switch (typeString) {
    case 'area-area':
    case 'area-url':
      return isLocationEditor(user);
    case 'area-instrument':
    case 'instrument-instrument':
    case 'instrument-url':
      return isRelationshipEditor(user);
    default:
      return true;
  }
}

const allowedRelations =
  new Map<RelatableEntityTypeT, Array<RelatableEntityTypeT>>();

function calculateAllowedRelations(user: ActiveEditorT) {
  const entityTypePairs = Object.keys(linkedEntities.link_type_tree);

  for (let i = 0; i < entityTypePairs.length; i++) {
    const typeString = entityTypePairs[i];
    const [type0, type1] =
      // $FlowIgnore[incompatible-cast]
      (typeString.split('-'): $ReadOnlyArray<RelatableEntityTypeT>);

    if (editorMayEditTypes(user, typeString)) {
      // Only allow URL as a source type.
      if (type1 !== 'url') {
        const typeList = allowedRelations.get(type0);
        if (typeList) {
          typeList.push(type1);
        } else {
          allowedRelations.set(type0, [type1]);
        }
      }
      if (type0 !== type1 && type0 !== 'url') {
        const typeList = allowedRelations.get(type1);
        if (typeList) {
          typeList.push(type0);
        } else {
          allowedRelations.set(type1, [type0]);
        }
      }
    }
  }

  for (const typeList of allowedRelations.values()) {
    typeList.sort();
  }
}

export function createTargetTypeOption(
  type: RelatableEntityTypeT,
): TargetTypeOptionT {
  return {
    text: ENTITY_NAMES[type](),
    value: type,
  };
}

export default function getTargetTypeOptions(
  user: ActiveEditorT,
  sourceType: RelatableEntityTypeT,
): TargetTypeOptionsT {
  if (!allowedRelations.size) {
    calculateAllowedRelations(user);
  }

  const typeList: $ReadOnlyArray<RelatableEntityTypeT> =
    allowedRelations.get(sourceType) ?? [];

  return typeList
    .filter((targetType) => hasDialogLinkTypeOptions(
      sourceType,
      targetType,
    ))
    .map(createTargetTypeOption)
    .sort((a, b) => compare(a.text, b.text));
}
