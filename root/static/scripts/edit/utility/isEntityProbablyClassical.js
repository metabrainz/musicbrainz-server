/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko, {
  type Observable as KnockoutObservable,
  type ObservableArray as KnockoutObservableArray,
} from 'knockout';

import {
  PROBABLY_CLASSICAL_LINK_TYPES,
} from '../../common/constants.js';

const classicalRoles = /\W(baritone|cello|conductor|gamba|guitar|orch|orchestra|organ|piano|soprano|tenor|trumpet|vocals?|viola|violin): /;

const testRelationship = (r: RelationshipT) => {
  return PROBABLY_CLASSICAL_LINK_TYPES.includes(r.linkTypeID);
};

export default function isEntityProbablyClassical(
  entity: {
    +name: string | KnockoutObservable<string>,
    +relationships?:
      | $ReadOnlyArray<RelationshipT>
      | KnockoutObservableArray<RelationshipT>,
    ...
  },
): boolean {
  return classicalRoles.test(ko.unwrap(entity.name)) ||
    (ko.unwrap(entity.relationships)?.some(testRelationship) ?? false);
}
