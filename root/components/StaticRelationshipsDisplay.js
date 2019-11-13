/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {compare} from '../static/scripts/common/i18n';
import linkedEntities from '../static/scripts/common/linkedEntities';
import compareRelationships from '../utility/compareRelationships';
import {type GroupedRelationshipsT} from '../utility/groupRelationships';

import RelationshipTargetLinks from './RelationshipTargetLinks';

const detailsTableStyle = Object.freeze({width: '100%'});

function targetIsOrderable(relationship: RelationshipT) {
  const linkType = linkedEntities.link_type[relationship.linkTypeID];
  const backward = relationship.direction === 'backward';
  // `backward` indicates that the relationship target is entity0
  return (linkType.orderable_direction === 1 && !backward) ||
          (linkType.orderable_direction === 2 && backward);
}

type Props = {
  +hiddenArtistCredit?: ?ArtistCreditT,
  +relationships: GroupedRelationshipsT,
};

const StaticRelationshipsDisplay = ({
  hiddenArtistCredit,
  relationships,
}: Props) => {
  const tables = [];
  const targetTypes = Object.keys(relationships).sort();

  for (let i = 0; i < targetTypes.length; i++) {
    const targetType = targetTypes[i];
    const phraseGroups = relationships[targetType];
    const phraseKeys = Object.keys(phraseGroups).sort((a, b) => (
      (phraseGroups[a].linkType.child_order -
       phraseGroups[b].linkType.child_order) ||
      compare(a, b)
    ));
    const targetTypeRows = [];

    for (let j = 0; j < phraseKeys.length; j++) {
      const phraseKey = phraseKeys[j];
      const group = phraseGroups[phraseKey];
      const groupSize = group.relationships.length;
      const phraseRows = [];

      group.relationships.sort(compareRelationships);

      for (let k = 0; k < groupSize; k++) {
        const relationship = group.relationships[k];

        const relationshipLink = (
          <RelationshipTargetLinks
            forGrouping
            hiddenArtistCredit={hiddenArtistCredit}
            relationship={relationship}
          />
        );

        phraseRows.push(
          <React.Fragment key={relationship.id}>
            {groupSize > 1 &&
              relationship.linkOrder &&
              targetIsOrderable(relationship) ? (
                exp.l('{num}. {relationship}', {
                  num: relationship.linkOrder,
                  relationship: relationshipLink,
                })
              ) : relationshipLink}
            <br />
          </React.Fragment>,
        );
      }

      targetTypeRows.push(
        <tr key={phraseKey}>
          <th>{addColon(group.phrase)}</th>
          <td style={{wordBreak: 'break-all'}}>{phraseRows}</td>
        </tr>,
      );
    }

    tables.push(
      <table className="details" key={targetType} style={detailsTableStyle}>
        {targetTypeRows}
      </table>,
    );
  }

  return tables;
};

export default StaticRelationshipsDisplay;
