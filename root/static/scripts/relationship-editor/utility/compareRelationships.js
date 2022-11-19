/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';

import {
  PART_OF_SERIES_LINK_TYPE_IDS,
  SERIES_ORDERING_ATTRIBUTE,
  SERIES_ORDERING_TYPE_AUTOMATIC,
} from '../../common/constants.js';
import {compare} from '../../common/i18n.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import {compareStrings} from '../../common/utility/compare.js';
import compareDates, {
  compareDatePeriods,
} from '../../common/utility/compareDates.js';
import {areLinkAttrsEqual} from '../../common/utility/groupRelationships.js';
import {memoizeWithDefault} from '../../common/utility/memoize.js';
import {fixedWidthInteger} from '../../common/utility/strings.js';
import type {
  RelationshipStateT,
} from '../../relationship-editor/types.js';

/*
 * Link attributes are sorted by root ID and ID.  In the relationship dialog,
 * they are further sorted by credit and text value (with duplicate IDs
 * handled by `splitRelationshipByAttributes`).
 *
 * Note that since they are kept in a tree, items can be found by any set of
 * leading sort criteria.
 */
export function compareLinkAttributeRootIds(
  a: LinkAttrT,
  b: LinkAttrT,
): number {
  const attributeTypeA = linkedEntities.link_attribute_type[a.typeID];
  const attributeTypeB = linkedEntities.link_attribute_type[b.typeID];
  return attributeTypeA.root_id - attributeTypeB.root_id;
}

export function compareLinkAttributeIds(
  a: LinkAttrT,
  b: LinkAttrT,
): number {
  return compareLinkAttributeRootIds(a, b) || (a.typeID - b.typeID);
}

export function compareLinkAttributes(
  a: LinkAttrT,
  b: LinkAttrT,
): number {
  let result = compareLinkAttributeIds(a, b);
  if (result) {
    return result;
  }
  const attributeType = linkedEntities.link_attribute_type[a.typeID];
  const rootAttributeType =
    linkedEntities.link_attribute_type[attributeType.root_id];
  if (rootAttributeType.creditable) {
    result = compareStrings(a.credited_as ?? '', b.credited_as ?? '');
    if (result) {
      return result;
    }
  }
  if (rootAttributeType.free_text) {
    result = compareStrings(a.text_value ?? '', b.text_value ?? '');
    if (result) {
      return result;
    }
  }
  return 0;
}

export function areLinkAttributesEqual(
  a: tree.ImmutableTree<LinkAttrT> | null,
  b: tree.ImmutableTree<LinkAttrT> | null,
): boolean {
  return tree.equals(a, b, areLinkAttrsEqual);
}

export function compareNullableLinkAttributes(
  a: ?LinkAttrT,
  b: ?LinkAttrT,
): number {
  if (a == null && b == null) {
    return 0;
  } else if (a == null) {
    return -1;
  } else if (b == null) {
    return 1;
  }
  return compareLinkAttributeIds(a, b);
}

function compareAttributeLists(
  a: tree.ImmutableTree<LinkAttrT> | null,
  b: tree.ImmutableTree<LinkAttrT> | null,
) {
  for (const [attrA, attrB] of tree.zip(a, b)) {
    const result = compareNullableLinkAttributes(attrA, attrB);
    if (result) {
      return result;
    }
  }
  return 0;
}

function getReleaseEventDate(
  event: ReleaseEventT,
  // eslint-disable-next-line no-unused-vars -- map index
  index: number,
): PartialDateT | null {
  return event.date;
}

function getReleaseLabelCatalogNumber(
  label: ReleaseLabelT,
  // eslint-disable-next-line no-unused-vars -- map index
  index: number,
): string {
  return label.catalogNumber || '';
}

const getReleaseFirstDate = memoizeWithDefault<ReleaseT, PartialDateT | null>(
  (release: ReleaseT) => {
    const sortedDates =
      release.events?.map(getReleaseEventDate).sort(compareDates);
    if (sortedDates?.length) {
      return sortedDates[0];
    }
    return null;
  },
  null,
);

const getReleaseFirstCatalogNumber = memoizeWithDefault<ReleaseT, string>(
  (release: ReleaseT): string => {
    const sortedCatalogNumbers =
      release.labels?.map(getReleaseLabelCatalogNumber).sort(compareStrings);
    if (sortedCatalogNumbers?.length) {
      return sortedCatalogNumbers[0];
    }
    return '';
  },
  '',
);

const intRegExp = /^\d+$/;
const intPartRegExp = /(\d+)/;

const getPaddedSeriesNumber = memoizeWithDefault<
  RelationshipStateT,
  string,
>((relationship: RelationshipStateT) => {
  for (const attribute of tree.iterate(relationship.attributes)) {
    if (attribute.type.gid === SERIES_ORDERING_ATTRIBUTE) {
      const parts = (attribute.text_value || '').split(intPartRegExp);

      for (let p = 0; p < parts.length; p++) {
        const part = parts[p];
        if (intRegExp.test(part)) {
          parts[p] = fixedWidthInteger(part, 10);
        }
      }
      return parts.join('');
    }
  }
  return '';
}, '');

function compareEvents(
  event1: EventT,
  event2: EventT,
): number {
  const eventDateCmp = compareDatePeriods(event1, event2);
  if (eventDateCmp) {
    return eventDateCmp;
  }
  const timeCmp = compareStrings(
    event1 ? event1.time : '',
    event2 ? event2.time : '',
  );
  if (timeCmp) {
    return timeCmp;
  }
  return 0;
}

function compareReleases(
  release1: ReleaseT,
  release2: ReleaseT,
): number {
  const firstDateCmp = compareDates(
    getReleaseFirstDate(release1),
    getReleaseFirstDate(release2),
  );
  if (firstDateCmp) {
    return firstDateCmp;
  }

  const firstCatalogNumberCmp = compareStrings(
    getReleaseFirstCatalogNumber(release1),
    getReleaseFirstCatalogNumber(release2),
  );
  if (firstCatalogNumberCmp) {
    return firstCatalogNumberCmp;
  }
  return 0;
}

function compareSeriesItems(
  linkTypeId: number,
  target1: CoreEntityT,
  target2: CoreEntityT,
): number {
  switch (linkTypeId) {
    case 802: { // event
      invariant(target1.entityType === 'event');
      invariant(target2.entityType === 'event');

      const eventsCmp = compareEvents(target1, target2);
      if (eventsCmp) {
        return eventsCmp;
      }
      break;
    }
    case 741: { // release
      invariant(target1.entityType === 'release');
      invariant(target2.entityType === 'release');

      const releasesCmp = compareReleases(target1, target2);
      if (releasesCmp) {
        return releasesCmp;
      }
      break;
    }
    case 742: { // release group
      invariant(target1.entityType === 'release_group');
      invariant(target2.entityType === 'release_group');

      const firstReleaseDateCmp = compareStrings(
        target1.firstReleaseDate || '',
        target2.firstReleaseDate || '',
      );
      if (firstReleaseDateCmp) {
        return firstReleaseDateCmp;
      }
      break;
    }
  }
  return 0;
}

/*
 * This function assumes that both relationships have the same
 * source entity and link type.
 */
export default function compareRelationships(
  a: RelationshipStateT,
  b: RelationshipStateT,
  backward: boolean,
): number {
  if (a === b) {
    return 0;
  }

  const linkTypeId = a.linkTypeID;
  const source = backward ? a.entity1 : a.entity0;
  const targetA = backward ? a.entity0 : a.entity1;
  const targetB = backward ? b.entity0 : b.entity1;
  const targetIdCmp = targetA.id - targetB.id;

  if (__DEV__) {
    invariant(
      linkTypeId === b.linkTypeID &&
      source.id === (backward ? b.entity1.id : b.entity0.id),
    );
  }

  /*
   * If we're editing an automatically-ordered series, ignore the
   * link orders: those will be set by the server.
   *
   * Note that such series' relationships are ordered by number
   * attribute, then relationship date, then any entity-specific
   * ordering.
   *
   * Please keep all sorting logic consistent with
   * `Data::Series::automatically_reorder` on the server.
   */
  if (
    source.entityType === 'series' &&
    source.orderingTypeID === SERIES_ORDERING_TYPE_AUTOMATIC &&
    linkTypeId != null &&
    PART_OF_SERIES_LINK_TYPE_IDS.includes(linkTypeId)
  ) {
    const seriesItemCmp = (
      /*
       * If the number attributes are different, the relationships would
       * reference different rows in the link table, which is enough to
       * establish uniqueness.
       */
      compareStrings(
        getPaddedSeriesNumber(a),
        getPaddedSeriesNumber(b),
      ) ||
      compareDatePeriods(a, b) ||
      (targetIdCmp ? (
        compareSeriesItems(linkTypeId, targetA, targetB)
      ) : 0)
    );
    if (seriesItemCmp) {
      return seriesItemCmp;
    }
  }

  const linkOrderCmp = a.linkOrder - b.linkOrder;
  if (linkOrderCmp) {
    return linkOrderCmp;
  }

  const datePeriodCmp = compareDatePeriods(a, b);
  if (datePeriodCmp) {
    return datePeriodCmp;
  }

  const targetCreditA = backward
    ? a.entity0_credit
    : a.entity1_credit;
  const targetCreditB = backward
    ? b.entity0_credit
    : b.entity1_credit;

  if (targetIdCmp) {
    /*
     * The target name comparison is performed to make the sorting
     * nicer for display, but should only be performed if the targets
     * are actually different. If we were to receive different versions
     * of the same entity via Autocomplete lookups, for example, it
     * would be an error for this function to return a non-zero value
     * if the relationships were otherwise identical.
     */
    return compare(
      // $FlowIgnore[sketchy-null-string]
      targetA ? (targetA.sort_name || targetCreditA || targetA.name) : '',
      // $FlowIgnore[sketchy-null-string]
      targetB ? (targetB.sort_name || targetCreditB || targetB.name) : '',
    ) || targetIdCmp;
  }

  const attributesCmp = compareAttributeLists(a.attributes, b.attributes);
  if (attributesCmp) {
    return attributesCmp;
  }

  return 0;
}

function compareForwardRelationships(
  a: RelationshipStateT,
  b: RelationshipStateT,
): number {
  return compareRelationships(a, b, false);
}

function compareBackwardRelationships(
  a: RelationshipStateT,
  b: RelationshipStateT,
): number {
  return compareRelationships(a, b, true);
}

export function getRelationshipsComparator(
  backward: boolean,
): (
  a: RelationshipStateT,
  b: RelationshipStateT,
) => number {
  return (
    backward
      ? compareBackwardRelationships
      : compareForwardRelationships
  );
}
