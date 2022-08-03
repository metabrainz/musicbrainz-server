/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities from '../linkedEntities.mjs';
import bracketed from '../utility/bracketed';
import {displayLinkAttributes}
  from '../utility/displayLinkAttribute';
import {interpolate, getExtraAttributes} from '../../edit/utility/linkPhrase';
import isDisabledLink from '../../../../utility/isDisabledLink';
import relationshipDateText
  from '../../../../utility/relationshipDateText';

import DescriptiveLink from './DescriptiveLink';

type Props = {
  +allowNewEntity0?: boolean,
  +allowNewEntity1?: boolean,
  +relationship: RelationshipT,
};

const HistoricRelationshipContent = ({
  relationship,
}: {relationship: RelationshipT}) => {
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  const source = linkedEntities[linkType.type0][relationship.entity0_id];
  const extraAttributes = getExtraAttributes(
    linkType,
    relationship.attributes,
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
  allowNewEntity0,
  allowNewEntity1,
  relationship,
}: Props) => {
  const backward = relationship.backward;
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  let entity0 = relationship.entity0;
  let entity1 = relationship.entity1;
  const type0 = linkType.type0 ||
    (backward
      ? relationship.target_type
      : relationship.source_type);
  const type1 = linkType.type1 ||
    (backward
      ? relationship.source_type
      : relationship.target_type);
  if (!entity0 || !entity1) {
    if (backward) {
      entity0 = relationship.target;
      entity1 = linkedEntities[type1][relationship.entity1_id] ||
        {entityType: type1, id: relationship.entity1_id};
    } else {
      entity1 = relationship.target;
      entity0 = linkedEntities[type0][relationship.entity0_id] ||
        {entityType: type0, id: relationship.entity0_id};
    }
  }
  const longPhrase = interpolate(
    linkType,
    relationship.attributes,
    'long_link_phrase',
    false /* forGrouping */,
    <DescriptiveLink
      allowNew={allowNewEntity0}
      content={relationship.entity0_credit}
      disableLink={isDisabledLink(relationship, entity0)}
      entity={entity0}
    />,
    <DescriptiveLink
      allowNew={allowNewEntity1}
      content={relationship.entity1_credit}
      disableLink={isDisabledLink(relationship, entity1)}
      entity={entity1}
    />,
  );
  const extraAttributes = getExtraAttributes(
    linkType,
    relationship.attributes,
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
}: Props): React.MixedElement => (
  relationship.editsPending ? (
    <span className="mp mp-rel">
      <HistoricRelationshipContent relationship={relationship} />
    </span>
  ) : <HistoricRelationshipContent relationship={relationship} />
);

const Relationship = ({
  allowNewEntity0,
  allowNewEntity1,
  relationship,
}: Props): React.MixedElement => (
  relationship.editsPending ? (
    <span className="mp mp-rel">
      <RelationshipContent
        allowNewEntity0={allowNewEntity0}
        allowNewEntity1={allowNewEntity1}
        relationship={relationship}
      />
    </span>
  ) : (
    <RelationshipContent
      allowNewEntity0={allowNewEntity0}
      allowNewEntity1={allowNewEntity1}
      relationship={relationship}
    />
  )
);

export default Relationship;
