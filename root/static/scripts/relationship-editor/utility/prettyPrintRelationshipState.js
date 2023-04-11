/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import expand2text from '../../common/i18n/expand2text.js';
import {
  displayLinkAttributeCustom,
} from '../../common/utility/displayLinkAttribute.js';
import formatDatePeriod from '../../common/utility/formatDatePeriod.js';
import type {RelationshipStateT} from '../types.js';

import {areLinkAttributesEqual} from './compareRelationships.js';
import getRelationshipKey from './getRelationshipKey.js';
import getRelationshipLinkType from './getRelationshipLinkType.js';
import getRelationshipStatusName from './getRelationshipStatusName.js';

const _displayLinkType = (linkType: LinkTypeT | null): string => {
  return linkType ? linkType.name : 'none';
};

const _displayAttribute = (attribute: LinkAttrT): string => {
  return displayLinkAttributeCustom(
    attribute,
    (x) => x.name,
    expand2text,
  );
};

const _displayAttributes = (
  attributes: tree.ImmutableTree<LinkAttrT> | null,
): string => {
  if (attributes == null) {
    return 'none';
  }
  return tree.toArray(attributes).map(_displayAttribute).join(', ');
};

const _displayEntity = (
  entity: RelatableEntityT,
  credit: string,
): string => {
  return (credit || entity.name) + ' (' + entity.id + ')';
};

export default function prettyPrintRelationshipState(
  state: RelationshipStateT,
): string {
  const old = (x: string) => ` (old: ${x})`;

  const original = state._original;
  const entity0 = state.entity0;
  const entity1 = state.entity1;
  const type0 = entity0.entityType.replace('_', '-');
  const type1 = entity1.entityType.replace('_', '-');
  const linkType = getRelationshipLinkType(state);

  let result = 'key: ' + getRelationshipKey(state) + '\n';

  result += 'status: ' + getRelationshipStatusName(state) + '\n';

  result += 'type: ' + _displayLinkType(linkType);
  if (original) {
    const oldLinkType = getRelationshipLinkType(original);
    if ((oldLinkType?.id) !== (linkType?.id)) {
      result += old(_displayLinkType(oldLinkType));
    }
  }
  result += '\n';

  result += type0 + ': ' + _displayEntity(entity0, state.entity0_credit);
  if (original) {
    const oldEntity = original.entity0;
    const oldCredit = original.entity0_credit;
    if (
      entity0.id !== oldEntity.id ||
      state.entity0_credit !== oldCredit
    ) {
      result += old(_displayEntity(oldEntity, oldCredit));
    }
  }
  result += '\n';

  result += type1 + ': ' + _displayEntity(entity1, state.entity1_credit);
  if (original) {
    const oldEntity = original.entity1;
    const oldCredit = original.entity1_credit;
    if (
      entity1.id !== oldEntity.id ||
      state.entity1_credit !== oldCredit
    ) {
      result += old(_displayEntity(oldEntity, oldCredit));
    }
  }
  result += '\n';

  result += 'attributes: ' + _displayAttributes(state.attributes);
  if (original) {
    if (!areLinkAttributesEqual(state.attributes, original.attributes)) {
      result += old(_displayAttributes(original.attributes));
    }
  }
  result += '\n';

  const datePeriod = formatDatePeriod(state) || 'none';
  result += 'date: ' + datePeriod;
  if (original) {
    const oldDatePeriod = formatDatePeriod(original) || 'none';
    if (datePeriod !== oldDatePeriod) {
      result += old(oldDatePeriod);
    }
  }
  result += '\n';

  result += 'link order: ' + state.linkOrder;
  if (original) {
    if (state.linkOrder !== original.linkOrder) {
      result += old('' + original.linkOrder);
    }
  }
  result += '\n';

  result += 'edits pending: ' + String(state.editsPending) + '\n';
  result += 'lineage: ' + state._lineage.join(', ') + '\n';

  return result;
}
