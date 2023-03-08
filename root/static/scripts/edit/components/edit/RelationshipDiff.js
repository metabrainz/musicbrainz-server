/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from '../../../common/components/DescriptiveLink.js';
import commaList from '../../../common/i18n/commaList.js';
import {
  expand2reactWithVarArgsInstance,
  hooks as expand2reactHooks,
} from '../../../common/i18n/expand2react.js';
import linkedEntities from '../../../common/linkedEntities.mjs';
import {keyBy} from '../../../common/utility/arrays.js';
import bracketed from '../../../common/utility/bracketed.js';
import displayLinkAttribute, {displayLinkAttributes}
  from '../../../common/utility/displayLinkAttribute.js';
import isDisabledLink from '../../../common/utility/isDisabledLink.js';
import relationshipDateText
  from '../../../common/utility/relationshipDateText.js';
import {DELETE, INSERT} from '../../utility/editDiff.js';
import {
  type LinkPhraseI18n,
  getPhraseAndExtraAttributes,
} from '../../utility/linkPhrase.js';

import DiffSide from './DiffSide.js';

const diffOnlyA = (
  content: Expand2ReactOutput,
) => <span className="diff-only-a">{content}</span>;
const diffOnlyB = (
  content: Expand2ReactOutput,
) => <span className="diff-only-b">{content}</span>;

type Props = {
  makeEntityLink?: (
    entity: CoreEntityT,
    content: string,
    relationship: RelationshipT,
  ) => React$MixedElement,
  newRelationship: RelationshipT,
  oldRelationship: RelationshipT,
};

const getTypeId = (x: LinkAttrT) => String(x.typeID);

const makeDescriptiveLink = (
  entity: CoreEntityT,
  content: string,
  relationship: RelationshipT,
) => (
  <DescriptiveLink
    content={content}
    disableLink={isDisabledLink(relationship, entity)}
    entity={entity}
  />
);

const RelationshipDiff = (React.memo(({
  newRelationship,
  oldRelationship,
  makeEntityLink = makeDescriptiveLink,
}: Props): React$Element<typeof React.Fragment> => {
  const oldAttrs = keyBy(oldRelationship.attributes, getTypeId);
  const newAttrs = keyBy(newRelationship.attributes, getTypeId);

  const i18nConfig: LinkPhraseI18n<Expand2ReactOutput> = {
    commaList,
    displayLinkAttribute: function (attr: LinkAttrT) {
      const typeId = String(attr.typeID);
      const display = displayLinkAttribute(attr);

      if (oldAttrs.has(typeId) && !newAttrs.get(typeId)) {
        return diffOnlyA(display);
      }

      if (newAttrs.get(typeId) && !oldAttrs.has(typeId)) {
        return diffOnlyB(display);
      }

      return display;
    },
    expand: expand2reactWithVarArgsInstance,
  };

  const oldLinkType = oldRelationship.linkTypeID == null
    ? null
    : linkedEntities.link_type[oldRelationship.linkTypeID];
  const newLinkType = newRelationship.linkTypeID == null
    ? null
    : linkedEntities.link_type[newRelationship.linkTypeID];

  invariant(
    oldLinkType && newLinkType,
    'No link type found',
  );

  /*
   * The display data relationships are created with direction=forward,
   * so entity0 is always the source.
   */
  const oldSource = oldRelationship.entity0 ?? (
    oldRelationship.entity0_id == null
      ? null
      : linkedEntities[oldLinkType.type0][oldRelationship.entity0_id]
  );
  const newSource = newRelationship.entity0 ?? (
    newRelationship.entity0_id == null
      ? null
      : linkedEntities[newLinkType.type0][newRelationship.entity0_id]
  );

  invariant(
    oldSource && newSource,
    'No source entity found',
  );

  const oldTarget = oldRelationship.entity1 || oldRelationship.target;
  const newTarget = newRelationship.entity1 || newRelationship.target;

  const oldSourceLink = makeEntityLink(
    oldSource,
    oldRelationship.entity0_credit,
    oldRelationship,
  );

  const newSourceLink = makeEntityLink(
    newSource,
    newRelationship.entity0_credit,
    newRelationship,
  );

  const oldTargetLink = makeEntityLink(
    oldTarget,
    oldRelationship.entity1_credit,
    oldRelationship,
  );

  const newTargetLink = makeEntityLink(
    newTarget,
    newRelationship.entity1_credit,
    newRelationship,
  );

  let oldPhrase: Expand2ReactOutput = '';
  let oldExtraAttributes: Array<LinkAttrT> = [];
  let newPhrase: Expand2ReactOutput = '';
  let newExtraAttributes: Array<LinkAttrT> = [];

  try {
    if (oldLinkType !== newLinkType) {
      expand2reactHooks.reactTextContentHook = diffOnlyA;
    }

    [oldPhrase, oldExtraAttributes] = getPhraseAndExtraAttributes(
      i18nConfig,
      oldLinkType,
      oldRelationship.attributes ?? [],
      'long_link_phrase',
      false, /* forGrouping */
      oldSource.id === newSource.id
        ? oldSourceLink : diffOnlyA(oldSourceLink),
      oldTarget.id === newTarget.id
        ? oldTargetLink : diffOnlyA(oldTargetLink),
    );

    if (oldLinkType !== newLinkType) {
      expand2reactHooks.reactTextContentHook = diffOnlyB;
    }

    [newPhrase, newExtraAttributes] = getPhraseAndExtraAttributes(
      i18nConfig,
      newLinkType,
      newRelationship.attributes ?? [],
      'long_link_phrase',
      false, /* forGrouping */
      oldSource.id === newSource.id
        ? newSourceLink : diffOnlyB(newSourceLink),
      oldTarget.id === newTarget.id
        ? newTargetLink : diffOnlyB(newTargetLink),
    );
  } finally {
    expand2reactHooks.reactTextContentHook = null;
  }

  const oldDateText = relationshipDateText(oldRelationship);
  const newDateText = relationshipDateText(newRelationship);

  return (
    <>
      <tr>
        <th rowSpan="2">{l('Relationship:')}</th>
        <td className="old">
          {oldPhrase}
          {' '}
          <DiffSide
            filter={DELETE}
            newText={newDateText}
            oldText={oldDateText}
          />
          {' '}
          {bracketed(displayLinkAttributes(oldExtraAttributes))}
        </td>
      </tr>
      <tr>
        <td className="new">
          {newPhrase}
          {' '}
          <DiffSide
            filter={INSERT}
            newText={newDateText}
            oldText={oldDateText}
          />
          {' '}
          {bracketed(displayLinkAttributes(newExtraAttributes))}
        </td>
      </tr>
    </>
  );
}): React.AbstractComponent<Props, void>);

export default RelationshipDiff;
