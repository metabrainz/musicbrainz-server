/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';

export type RelationshipEntityPropertiesT ={
  +entity0: RelatableEntityT | null,
  +entity1: RelatableEntityT | null,
  ...
};

export default function getOpenEditsLink(
  relationship: RelationshipEntityPropertiesT,
): string | null {
  const entity0 = relationship.entity0;
  const entity1 = relationship.entity1;
  if (!entity0 || !entity1) {
    return null;
  }

  const entity0Name = entity0.name;
  const entity1Name = entity1.name;
  if (empty(entity0Name) || empty(entity1Name)) {
    return null;
  }

  if (!isDatabaseRowId(entity0.id) || !isDatabaseRowId(entity1.id)) {
    return null;
  }

  const entity0Conditions = entity0.entityType === 'url' ? (
    `&conditions.0.field=${encodeURIComponent(entity0.entityType)}` +
    '&conditions.0.operator=%3D' +
    `&conditions.0.args.0=${encodeURIComponent(entity0Name)}`
  ) : (
    `&conditions.0.field=${encodeURIComponent(entity0.entityType)}` +
    '&conditions.0.operator=%3D' +
    `&conditions.0.name=${encodeURIComponent(entity0Name)}` +
    `&conditions.0.args.0=${encodeURIComponent(String(entity0.id))}`
  );

  const entity1Conditions = entity1.entityType === 'url' ? (
    `&conditions.1.field=${encodeURIComponent(entity1.entityType)}` +
    '&conditions.1.operator=%3D' +
    `&conditions.1.args.0=${encodeURIComponent(entity1Name)}`
  ) : (
    `&conditions.1.field=${encodeURIComponent(entity1.entityType)}` +
    '&conditions.1.operator=%3D' +
    `&conditions.1.name=${encodeURIComponent(entity1Name)}` +
    `&conditions.1.args.0=${encodeURIComponent(String(entity1.id))}`
  );

  return (
    '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
    entity0Conditions +
    entity1Conditions +
    '&conditions.2.field=type' +
    '&conditions.2.operator=%3D&conditions.2.args=90%2C233' +
    '&conditions.2.args=91&conditions.2.args=92' +
    '&conditions.3.field=status&conditions.3.operator=%3D' +
    '&conditions.3.args=1&field=Please+choose+a+condition'
  );
}
