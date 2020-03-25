/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  INSTRUMENT_ROOT_ID,
  VOCAL_ROOT_ID,
} from '../static/scripts/common/constants';
import {compare} from '../static/scripts/common/i18n';
import commaList from '../static/scripts/common/i18n/commaList';
import linkedEntities from '../static/scripts/common/linkedEntities';
import {compareStrings} from '../static/scripts/common/utility/compare';
import {compareDatePeriods}
  from '../static/scripts/common/utility/compareDates';
import {
  arraysEqual,
  mergeSortedArrayInto,
  sortedIndexWith,
} from '../static/scripts/common/utility/arrays';
import {
  cmpLinkAttrs,
  getExtraAttributes,
  interpolate,
  interpolateText,
} from '../static/scripts/edit/utility/linkPhrase';

import areDatePeriodsEqual from './areDatePeriodsEqual';

const UNIT_SEP = '\x1F';

export type DatedExtraAttributes = {
  +attributes: Array<LinkAttrT>,
  +datePeriods: Array<DatePeriodRoleT>,
};

export type RelationshipTargetGroupT = {
  datedExtraAttributesList: Array<DatedExtraAttributes>,
  earliestDatePeriod: DatePeriodRoleT,
  editsPending: boolean,
  hasAttributes: boolean,
  isOrderable: boolean,
  key: string,
  linkOrder: number | null,
  target: CoreEntityT,
  targetCredit: string,
};

export type RelationshipPhraseGroupT = {
  combinedPhrase: Expand2ReactOutput,
  key: string,
  linkTypeInfo: Array<{
    editsPending: boolean,
    phrase: Expand2ReactOutput,
    rootTypeId: number | null,
    textPhrase: string,
    typeId: number,
  }>,
  targetGroups: Array<RelationshipTargetGroupT>,
};

export type RelationshipTargetTypeGroupT = {
  +relationshipPhraseGroups: Array<RelationshipPhraseGroupT>,
  +targetType: string,
};

function cmpRelationshipPhraseGroups(a, b) {
  const linkTypeInfoA = a.linkTypeInfo[0];
  const linkTypeInfoB = b.linkTypeInfo[0];
  return (
    (linkTypeInfoA.typeId - linkTypeInfoB.typeId) ||
    compare(linkTypeInfoA.textPhrase, linkTypeInfoB.textPhrase)
  );
}

const cmpPhraseGroupLinkTypeInfo = (a, b) => (
  (a.typeId - b.typeId) ||
  compare(a.textPhrase, b.textPhrase)
);

function cmpFirstDatePeriods(
  a: DatedExtraAttributes,
  b: DatedExtraAttributes,
) {
  return compareDatePeriods(
    a.datePeriods[0] ?? null,
    b.datePeriods[0] ?? null,
  );
}

const cmpRelationshipTargetGroups = (a, b) => (
  ((a.linkOrder ?? 0) - (b.linkOrder ?? 0)) ||
  compareDatePeriods(a.earliestDatePeriod, b.earliestDatePeriod) ||
  compare(
    a.targetCredit || getSortName(a.target),
    b.targetCredit || getSortName(b.target),
  ) ||
  (a.target.id - b.target.id)
);

const areLinkAttrsEqual = (a, b) => (
  a.typeID === b.typeID &&
  a.text_value === b.text_value &&
  a.credited_as === b.credited_as
);

const areDatedExtraAttributesEqual = (a, b) => (
  arraysEqual(a.datePeriods, b.datePeriods, areDatePeriodsEqual) &&
  arraysEqual(a.attributes, b.attributes, areLinkAttrsEqual)
);

const areRelationshipTargetGroupsEqual = (a, b) => (
  a.key === b.key &&
  arraysEqual(
    a.datedExtraAttributesList,
    b.datedExtraAttributesList,
    areDatedExtraAttributesEqual,
  )
);

function displayLinkPhrase(linkTypeInfo) {
  const phrase = linkTypeInfo.phrase;
  if (linkTypeInfo.editsPending) {
    return <span className="mp">{phrase}</span>;
  }
  return phrase;
}

function isNotInstrumentOrVocal(attribute) {
  const type = linkedEntities.link_attribute_type[attribute.typeID];
  return (
    type.root_id !== INSTRUMENT_ROOT_ID &&
    type.root_id !== VOCAL_ROOT_ID
  );
}

function areAttributeListsMergeable(
  attributeList1,
  attributeList2,
) {
  /*
   * Two attribute lists are mergeable for display if all their non-
   * instrument and non-vocal attributes are equal. This is basically
   * the inverse of Data::Util::split_relationship_by_attributes on the
   * server, which was added for MBS-1377 and introduced the display
   * issue described by MBS-7678.
   *
   * This method helps on orderable link types such as "recording of."
   * When displaying those, we don't interpolate any attributes into
   * the link phrase in order to keep the relevant relationships
   * grouped and numbered together in a single list. Thus, without
   * the check below, something like
   *     recording of: Work (in 2001: cover; in 2001: cover, live)
   * would be displayed only as
   *     recording of: Work (in 2001: cover, live)
   * which creates a deficiency in the editing interface insofar as
   * it doesn't make duplicates visible to the user.
   */
  return arraysEqual(
    attributeList1.filter(isNotInstrumentOrVocal),
    attributeList2.filter(isNotInstrumentOrVocal),
    areLinkAttrsEqual,
  );
}

/*
 * MBS-7678: Given the following relationships,
 *   member: A (1999-2005) (bass)
 *   member: A (1999-2005) (guitar)
 *   member: A (2009-) (bass)
 *   member: A (2009-) (guitar)
 *
 * `groupedRelationships` below will compute a `datedExtraAttributesList`
 * for each relationship target group as follows:
 *   [{attributes: [bass], datePeriods: [1999-2005]},
 *    {attributes: [guitar], datePeriods: [1999-2005]},
 *    {attributes: [bass], datePeriods: [2009-]},
 *    {attributes: [guitar], datePeriods: [2009-]}]
 *
 * `mergeDatedExtraAttributes` implements part of MBS-7678 by taking the
 * above list, and
 *   (1) merging the attributes lists where datePeriods are identical;
 *   (2) merging the datePeriods lists where the attributes are identical
 *
 * in that order. The result then resembles the object below.
 *   [{attributes: [bass, guitar], datePeriods: [1999-2005, 2009-]}]
 */

function mergeDatedExtraAttributes(pairs) {
  for (let i = 0; i < pairs.length; i++) {
    const a = pairs[i];
    for (let j = i + 1; j < pairs.length; j++) {
      const b = pairs[j];
      if (areDatePeriodsEqual(a.datePeriods[0], b.datePeriods[0]) &&
          areAttributeListsMergeable(a.attributes, b.attributes)) {
        mergeSortedArrayInto(a.attributes, b.attributes, cmpLinkAttrs);
        pairs.splice(j, 1);
        j--;
      }
    }
  }
  for (let i = 0; i < pairs.length; i++) {
    const a = pairs[i];
    for (let j = i + 1; j < pairs.length; j++) {
      const b = pairs[j];
      if (arraysEqual(a.attributes, b.attributes, areLinkAttrsEqual)) {
        mergeSortedArrayInto(
          a.datePeriods,
          b.datePeriods,
          compareDatePeriods,
        );
        pairs.splice(j, 1);
        j--;
      }
    }
  }
}

const getSortName = x => x.entityType === 'artist' ? x.sort_name : x.name;

function targetIsOrderable(relationship: RelationshipT) {
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  const backward = relationship.direction === 'backward';
  // `backward` indicates that the relationship target is entity0
  return (linkType.orderable_direction === 1 && !backward) ||
          (linkType.orderable_direction === 2 && backward);
}

export default function groupRelationships(
  relationships: ?$ReadOnlyArray<RelationshipT>,
  types?: ?$ReadOnlyArray<CoreEntityTypeT>,
  filter?: (RelationshipT, CoreEntityT, CoreEntityTypeT) => boolean,
): $ReadOnlyArray<RelationshipTargetTypeGroupT> {
  if (!relationships) {
    return [];
  }

  const targetTypeGroups: Array<RelationshipTargetTypeGroupT> = [];

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const target = relationship.target;
    const targetType = target.entityType;

    if (types && !types.includes(targetType)) {
      continue;
    }

    if (filter && !filter(relationship, target, targetType)) {
      continue;
    }

    let targetTypeGroup;
    {
      const [index, exists] = sortedIndexWith(
        targetTypeGroups,
        targetType,
        (group, targetType) => compareStrings(group.targetType, targetType),
      );
      if (exists) {
        targetTypeGroup = targetTypeGroups[index];
      } else {
        targetTypeGroup = ({
          relationshipPhraseGroups: [],
          targetType,
        }: RelationshipTargetTypeGroupT);
        targetTypeGroups.splice(index, 0, targetTypeGroup);
      }
    }

    const backward = relationship.direction === 'backward';
    const linkType = linkedEntities.link_type[relationship.linkTypeID];

    /*
     * In order to group relationships by link phrase, the link phrase
     * must be a string. However, phrases with instruments contain
     * links, so produce a React element from `interpolate`. We can't
     * use a React element as a grouping key for obvious reasons. (We
     * could convert it to HTML and use that as the key, but the HTML
     * would be more difficult to sort properly.) The solution is to
     * always call `interpolateText` to produce a rendered phrase
     * suitable for grouping. If the relationship contains instruments,
     * we additionally call `interpolate` to produce a phrase with
     * links for display. There's currently no other case where
     * `interpolateText` doesn't suffice for display, so we otherwise
     * just use the `textPhrase` for display if the relationship is
     * instrument-free.
     */
    let hasInstruments = false;
    const linkAttrs = relationship.attributes;
    if (linkAttrs) {
      for (let i = 0; i < linkAttrs.length; i++) {
        const linkAttr = linkAttrs[i];
        const linkAttrType =
          linkedEntities.link_attribute_type[linkAttr.typeID];
        if (linkAttrType.root_id === INSTRUMENT_ROOT_ID) {
          hasInstruments = true;
          break;
        }
      }
    }

    const phraseArgs = [
      relationship,
      backward ? 'reverse_link_phrase' : 'link_phrase',
      true, /* forGrouping */
    ];

    let textPhrase = interpolateText(...phraseArgs);
    let phrase;

    if (hasInstruments) {
      phrase = interpolate(...phraseArgs);
    }

    const sourceCredit = backward
      ? relationship.entity1_credit
      : relationship.entity0_credit;

    if (sourceCredit) {
      textPhrase = texp.l('{role} (as {credited_name})', {
        credited_name: sourceCredit,
        role: textPhrase,
      });

      if (hasInstruments /*:: && phrase */) {
        phrase = exp.l('{role} (as {credited_name})', {
          credited_name: sourceCredit,
          role: phrase,
        });
      }
    }

    /*
     * linkType.id shouldn't really be needed in the grouping key, since
     * two different link types to the same entity types shouldn't ever
     * produce the same text phrase. Nonetheless, the code should continue
     * to work if that happens.
     */
    const phraseGroupKey = textPhrase + UNIT_SEP + String(linkType.id);
    let phraseGroup;
    {
      const phraseGroups = targetTypeGroup.relationshipPhraseGroups;
      const [index, exists] = sortedIndexWith(
        phraseGroups,
        phraseGroupKey,
        (group, phraseGroupKey) => compare(group.key, phraseGroupKey),
      );
      if (exists) {
        phraseGroup = phraseGroups[index];
      } else {
        phraseGroup = ({
          combinedPhrase: '',
          key: phraseGroupKey,
          linkTypeInfo: [{
            editsPending: relationship.editsPending,
            phrase: phrase ?? textPhrase,
            rootTypeId: linkType.root_id,
            textPhrase,
            typeId: linkType.id,
          }],
          targetGroups: [],
        }: RelationshipPhraseGroupT);
        phraseGroups.splice(index, 0, phraseGroup);
      }
    }

    const targetCredit = relationship.direction === 'backward'
      ? relationship.entity0_credit
      : relationship.entity1_credit;
    const isOrderable = targetIsOrderable(relationship);
    const linkOrder = relationship.linkOrder;
    const datePeriod = {
      begin_date: relationship.begin_date,
      end_date: relationship.end_date,
      ended: relationship.ended,
    };
    const hasAttributes = relationship.attributes
      ? relationship.attributes.length > 0
      : false;

    let targetGroup = phraseGroup.targetGroups.find(targetGroup => (
      targetGroup.target.id === target.id &&
      targetGroup.targetCredit === targetCredit &&
      /*
       * Ordered relationships are displayed as a numbered list. It doesn't
       * make sense to group differently-numbered parts together, even if they
       * refer to the same entity, so we include the linkOrder in the key.
       * (As an example, there are some known cases with "part of" work
       * relationships where a sub-work is supposed to be played twice in
       * different orders.)
       */
      targetGroup.linkOrder === linkOrder &&
      /*
       * Don't merge relationships without attributes into ones that have
       * them; that makes the ones without any completely invisible to the
       * user.
       */
      targetGroup.hasAttributes === hasAttributes
    ));

    if (!targetGroup) {
      targetGroup = ({
        datedExtraAttributesList: [],
        earliestDatePeriod: datePeriod,
        editsPending: relationship.editsPending,
        hasAttributes,
        isOrderable,
        key: String(target.id) + UNIT_SEP + targetCredit + UNIT_SEP +
          (linkOrder ?? ''),
        linkOrder,
        target,
        targetCredit,
      }: RelationshipTargetGroupT);
      phraseGroup.targetGroups.push(targetGroup);
    }

    if (datePeriod !== targetGroup.earliestDatePeriod) {
      if (compareDatePeriods(
        datePeriod,
        targetGroup.earliestDatePeriod,
      ) < 0) {
        targetGroup.earliestDatePeriod = datePeriod;
      }
    }

    targetGroup.datedExtraAttributesList.push({
      attributes: [...getExtraAttributes(...phraseArgs)],
      datePeriods: [datePeriod],
    });

    /*
     * If one of the relationships in the target group has pending edits,
     * mark the whole group as having pending edits.
     */
    targetGroup.editsPending = targetGroup.editsPending ||
      relationship.editsPending;
  }

  for (const targetTypeGroup of targetTypeGroups) {
    const phraseGroups = targetTypeGroup.relationshipPhraseGroups;

    for (let i = 0; i < phraseGroups.length; i++) {
      const targetGroups = phraseGroups[i].targetGroups;

      for (let j = 0; j < targetGroups.length; j++) {
        const datedExtraAttributesList = targetGroups[j].datedExtraAttributesList;
        mergeDatedExtraAttributes(datedExtraAttributesList);
        datedExtraAttributesList.sort(cmpFirstDatePeriods);
      }

      targetGroups.sort(cmpRelationshipTargetGroups);
    }

    for (let i = 0; i < phraseGroups.length; i++) {
      const phraseGroup1 = phraseGroups[i];
      const linkTypeInfo1 = phraseGroup1.linkTypeInfo;

      /*
       * As a final nicety for MBS-7678, we further merge phrase groups
       * together that (1) share a link type or parent link type, and (2)
       * have completely identical target entity lists *including* the
       * dated extra attribute lists for each target.
       */
      for (let j = i + 1; j < phraseGroups.length; j++) {
        const phraseGroup2 = phraseGroups[j];
        const firstLinkType2 = phraseGroup2.linkTypeInfo[0];
        const relatedLinkType = linkTypeInfo1.find(t => (
          t.rootTypeId === firstLinkType2.rootTypeId
        ));
        const targetGroups1 = phraseGroup1.targetGroups;
        const targetGroups2 = phraseGroup2.targetGroups;

        if (relatedLinkType && arraysEqual(
          targetGroups1,
          targetGroups2,
          areRelationshipTargetGroupsEqual,
        )) {
          // Merge editsPending flags
          for (let k = 0; k < targetGroups1.length; k++) {
            const targetGroup1 = targetGroups1[k];
            targetGroup1.editsPending =
              targetGroup1.editsPending || targetGroups2[k].editsPending;
          }

          phraseGroup1.key += UNIT_SEP + phraseGroup2.key;
          const [index, exists] = sortedIndexWith(
            linkTypeInfo1,
            firstLinkType2,
            cmpPhraseGroupLinkTypeInfo,
          );
          if (!exists) {
            linkTypeInfo1.splice(index, 0, firstLinkType2);
            phraseGroups.splice(j, 1);
            j--;
          }
        }
      }

      phraseGroup1.combinedPhrase = linkTypeInfo1.length > 1
        ? commaList(linkTypeInfo1.map(displayLinkPhrase))
        : displayLinkPhrase(linkTypeInfo1[0]);
    }

    phraseGroups.sort(cmpRelationshipPhraseGroups);
  }

  return targetTypeGroups;
}
