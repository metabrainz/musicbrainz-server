/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import keyBy from 'lodash/keyBy';
import * as React from 'react';

import relationshipDateText from '../../../../../utility/relationshipDateText';
import {INSERT, DELETE} from '../../utility/editDiff';
import DescriptiveLink from '../../../common/components/DescriptiveLink';
import commaList from '../../../common/i18n/commaList';
import commaOnlyList from '../../../common/i18n/commaOnlyList';
import expand2react, {hooks as expand2reactHooks} from '../../../common/i18n/expand2react';
import linkedEntities from '../../../common/linkedEntities';
import bracketed from '../../../common/utility/bracketed';
import displayLinkAttribute from '../../../common/utility/displayLinkAttribute';
import {
  getPhraseAndExtraAttributes,
  type CachedLinkPhraseData,
  type LinkPhraseI18n,
  type RelationshipInfoT,
} from '../../utility/linkPhrase';

import DiffSide from './DiffSide';

const diffOnlyA = content => <span className="diff-only-a">{content}</span>;
const diffOnlyB = content => <span className="diff-only-b">{content}</span>;

type Props = {
  newRelationship: RelationshipT,
  oldRelationship: RelationshipT,
};

const RelationshipDiff = ({
  newRelationship,
  oldRelationship,
}: Props) => {
  const oldAttrs = oldRelationship.attributes
    ? keyBy(oldRelationship.attributes, 'typeID')
    : {};
  const newAttrs = newRelationship.attributes
    ? keyBy(newRelationship.attributes, 'typeID')
    : {};

  const i18nConfig: LinkPhraseI18n<Expand2ReactOutput> = {
    cache: new WeakMap<
      RelationshipInfoT,
      CachedLinkPhraseData<Expand2ReactOutput>,
    >(),
    commaList,
    commaOnlyList,
    displayLinkAttribute: function (attr: LinkAttrT) {
      const typeId = attr.typeID;
      const display = displayLinkAttribute(attr);

      if (oldAttrs[typeId] && !newAttrs[typeId]) {
        return diffOnlyA(display);
      }

      if (newAttrs[typeId] && !oldAttrs[typeId]) {
        return diffOnlyB(display);
      }

      return display;
    },
    expand: expand2react,
  };

  const oldLinkType = linkedEntities.link_type[oldRelationship.linkTypeID];
  const newLinkType = linkedEntities.link_type[newRelationship.linkTypeID];

  /*
   * The display data relationships are created with direction=forward,
   * so entity0 is always the source.
   */
  const oldSource =
    linkedEntities[oldLinkType.type0][oldRelationship.entity0_id];
  const newSource =
    linkedEntities[newLinkType.type0][newRelationship.entity0_id];

  const oldTarget = oldRelationship.target;
  const newTarget = newRelationship.target;

  const oldSourceLink = (
    <DescriptiveLink
      credit={oldRelationship.entity0_credit}
      entity={oldSource}
    />
  );

  const newSourceLink = (
    <DescriptiveLink
      credit={newRelationship.entity0_credit}
      entity={newSource}
    />
  );

  const oldTargetLink = (
    <DescriptiveLink
      credit={oldRelationship.entity1_credit}
      entity={oldTarget}
    />
  );

  const newTargetLink = (
    <DescriptiveLink
      credit={newRelationship.entity1_credit}
      entity={newTarget}
    />
  );

  let [oldPhrase, oldExtraAttributes] = ['', null];
  let [newPhrase, newExtraAttributes] = ['', null];

  try {
    if (oldLinkType !== newLinkType) {
      expand2reactHooks.reactTextContentHook = diffOnlyA;
    }

    [oldPhrase, oldExtraAttributes] = getPhraseAndExtraAttributes(
      i18nConfig,
      oldRelationship,
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
      newRelationship,
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
          {bracketed(oldExtraAttributes)}
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
          {bracketed(newExtraAttributes)}
        </td>
      </tr>
    </>
  );
};

export default RelationshipDiff;
