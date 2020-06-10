/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipTargetLinks from '../components/RelationshipTargetLinks';
import commaList from '../static/scripts/common/i18n/commaList';
import type {
  RelationshipTargetTypeGroupT,
} from '../utility/groupRelationships';

const detailsTableStyle = Object.freeze({width: '100%'});

type Props = {
  +hiddenArtistCredit?: ?ArtistCreditT,
  +relationships: $ReadOnlyArray<RelationshipTargetTypeGroupT>,
};

const StaticRelationshipsDisplay = ({
  hiddenArtistCredit,
  relationships: groupedRelationships,
}: Props): Array<React.Element<'table'>> => {
  const tables = [];

  for (let i = 0; i < groupedRelationships.length; i++) {
    const targetTypeGroup = groupedRelationships[i];
    const relationshipPhraseGroups = targetTypeGroup.relationshipPhraseGroups;
    const targetTypeRows = [];

    for (let j = 0; j < relationshipPhraseGroups.length; j++) {
      const phraseGroup = relationshipPhraseGroups[j];
      const groupSize = phraseGroup.targetGroups.length;
      const phraseRows = [];

      for (let k = 0; k < groupSize; k++) {
        const targetGroup = phraseGroup.targetGroups[k];

        const relationshipLink = (
          <RelationshipTargetLinks
            hiddenArtistCredit={hiddenArtistCredit}
            relationship={targetGroup}
          />
        );

        phraseRows.push(
          <React.Fragment key={targetGroup.key}>
            {targetGroup.linkOrder ? (
              targetGroup.isOrderable ? (
                exp.l('{num}. {relationship}', {
                  num: targetGroup.linkOrder,
                  relationship: relationshipLink,
                })
              ) : (
                exp.l('{relationship} (order: {num})', {
                  num: targetGroup.linkOrder,
                  relationship: relationshipLink,
                })
              )
            ) : relationshipLink}
            <br />
          </React.Fragment>,
        );
      }

      targetTypeRows.push(
        <tr key={phraseGroup.key}>
          <th>{addColon(phraseGroup.combinedPhrase)}</th>
          <td style={{wordBreak: 'break-all'}}>{phraseRows}</td>
        </tr>,
      );
    }

    tables.push(
      <table
        className="details"
        key={targetTypeGroup.targetType}
        style={detailsTableStyle}
      >
        {targetTypeRows}
      </table>,
    );
  }

  return tables;
};

export default StaticRelationshipsDisplay;
