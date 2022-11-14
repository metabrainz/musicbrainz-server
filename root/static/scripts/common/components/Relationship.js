/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  getExtraAttributes,
  interpolate,
} from '../../edit/utility/linkPhrase.js';
import linkedEntities from '../linkedEntities.mjs';
import bracketed from '../utility/bracketed.js';
import {displayLinkAttributes}
  from '../utility/displayLinkAttribute.js';
import isDisabledLink from '../utility/isDisabledLink.js';
import relationshipDateText from '../utility/relationshipDateText.js';

import DescriptiveLink from './DescriptiveLink.js';

type HistoricRelationshipPropsT = {
  +relationship: RelationshipT,
};

type RelationshipPropsT = {
  +allowNewEntity0?: boolean,
  +allowNewEntity1?: boolean,
  +makeEntityLink?: (
    entity: CentralEntityT,
    content: string,
    relationship: RelationshipT,
    allowNew: ?boolean,
  ) => React.MixedElement,
  +relationship: RelationshipT,
};

const makeDescriptiveLink = (
  entity: CentralEntityT,
  content: string,
  relationship: RelationshipT,
  allowNew: ?boolean,
) => (
  <DescriptiveLink
    allowNew={allowNew ?? false}
    content={content}
    disableLink={isDisabledLink(relationship, entity)}
    entity={entity}
  />
);

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
  makeEntityLink = makeDescriptiveLink,
  relationship,
}: RelationshipPropsT) => {
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
    makeEntityLink(
      entity0,
      relationship.entity0_credit,
      relationship,
      allowNewEntity0,
    ),
    makeEntityLink(
      entity1,
      relationship.entity1_credit,
      relationship,
      allowNewEntity1,
    ),
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
}: HistoricRelationshipPropsT): React.MixedElement => (
  relationship.editsPending ? (
    <span className="mp mp-rel">
      <HistoricRelationshipContent relationship={relationship} />
    </span>
  ) : <HistoricRelationshipContent relationship={relationship} />
);

const Relationship = (props: RelationshipPropsT): React.MixedElement => (
  props.relationship.editsPending ? (
    <span className="mp mp-rel">
      <RelationshipContent {...props} />
    </span>
  ) : (
    <RelationshipContent {...props} />
  )
);

export default Relationship;
