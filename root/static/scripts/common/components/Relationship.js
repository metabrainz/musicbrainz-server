/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities from '../linkedEntities';
import bracketed, {bracketedText} from '../utility/bracketed';
import {displayLinkAttributes}
  from '../utility/displayLinkAttribute';
import formatDate from '../utility/formatDate';
import isDateEmpty from '../utility/isDateEmpty';
import {interpolate, getExtraAttributes} from '../../edit/utility/linkPhrase';
import type {LinkPhraseProp} from '../../edit/utility/linkPhrase';
import relationshipDateText
  from '../../../../utility/relationshipDateText';

import DescriptiveLink from './DescriptiveLink';

type Props = {
  +phraseField?: LinkPhraseProp,
  +relationship: RelationshipT,
};

const HistoricRelationshipContent = ({
  relationship,
}: {relationship: RelationshipT}) => {
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  const source = linkedEntities[linkType.type0][relationship.entity0_id];
  const extraAttributes = getExtraAttributes(
    relationship,
    'link_phrase',
    false, /* forGrouping */
  );
  return (
    <>
      <DescriptiveLink
        content={relationship.entity0_credit}
        entity={source}
      />
      {' '}
      {linkType.link_phrase /* hardcoded untranslatable historical hack */}
      {' '}
      <DescriptiveLink
        // Used for historic edits which hardcode entity1 as target
        content={relationship.entity1_credit}
        entity={relationship.target}
      />
      {' '}
      {relationshipDateText(relationship)}
      {extraAttributes ? (
        <>
          {' '}
          {bracketed(displayLinkAttributes(extraAttributes))}
        </>
      ) : null}
    </>
  );
};

const RelationshipContent = ({
  relationship,
}: {relationship: RelationshipT}) => {
  const direction = relationship.direction;
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  let entity0;
  let entity1;
  if (direction === 'backward') {
    entity0 = relationship.target;
    entity1 = linkedEntities[linkType.type1][relationship.entity1_id];
  } else {
    entity1 = relationship.target;
    entity0 = linkedEntities[linkType.type0][relationship.entity0_id];
  }
  const longPhrase = interpolate(
    relationship,
    'long_link_phrase',
    false /* forGrouping */,
    <DescriptiveLink
      content={relationship.entity0_credit}
      entity={entity0}
    />,
    <DescriptiveLink
      content={relationship.entity1_credit}
      entity={entity1}
    />,
  );
  const extraAttributes = getExtraAttributes(
    relationship,
    'long_link_phrase',
    false, /* forGrouping */
  );
  return (
    <>
      {longPhrase}
      {' '}
      {relationshipDateText(relationship)}
      {extraAttributes ? (
        <>
          {' '}
          {bracketed(displayLinkAttributes(extraAttributes))}
        </>
      ) : null}
    </>
  );
};

export const HistoricRelationship = ({
  relationship,
}: Props) => (
  relationship.editsPending ? (
    <span className="mp mp-rel">
      <HistoricRelationshipContent relationship={relationship} />
    </span>
  ) : <HistoricRelationshipContent relationship={relationship} />
);

const Relationship = ({
  relationship,
}: Props) => (
  relationship.editsPending ? (
    <span className="mp mp-rel">
      <RelationshipContent relationship={relationship} />
    </span>
  ) : <RelationshipContent relationship={relationship} />
);

export default Relationship;
