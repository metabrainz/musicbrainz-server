/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import loopParity from '../utility/loopParity';
import generateRelationshipAppearancesList
  from '../utility/generateRelationshipAppearancesList';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import commaList from '../static/scripts/common/i18n/commaList';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';
import displayLinkAttribute
  from '../static/scripts/common/utility/displayLinkAttribute';

type Props = {|
  +entity: CoreEntityT,
  +heading: string,
  +showCredits: boolean,
|};

const RelationshipsTable = ({
  entity,
  heading,
  showCredits,
}: Props) => {
  const appearances = generateRelationshipAppearancesList(entity);
  const relationshipTypes = Object.keys(appearances);
  if (!appearances || relationshipTypes.length === 0) {
    return null;
  }
  let hasCreditColumn = 0;
  let hasAttributeColumn = 0;
  let hasArtistColumn = 0;
  let hasLengthColumn = 0;
  for (const relationshipType of relationshipTypes) {
    for (const relationship of appearances[relationshipType]) {
      const sourceCredit = (relationship.direction === 'backward')
        ? relationship.entity1_credit
        : relationship.entity0_credit;

      if (!hasCreditColumn && showCredits && sourceCredit) {
        hasCreditColumn = 1;
      }
      if (!hasAttributeColumn && relationship.attributes &&
        relationship.attributes.length > 0) {
        hasAttributeColumn = 1;
      }
      if (!hasArtistColumn && relationship.target.artistCredit) {
        hasArtistColumn = 1;
      }
      if (!hasLengthColumn && relationship.target.length) {
        hasLengthColumn = 1;
      }
      if (hasCreditColumn && hasAttributeColumn &&
        hasArtistColumn && hasLengthColumn) {
        break;
      }
    }

    if (hasCreditColumn && hasAttributeColumn &&
      hasArtistColumn && hasLengthColumn) {
      break;
    }
  }

  const columnsCount = 1 + hasCreditColumn +
                       hasAttributeColumn + hasArtistColumn + hasLengthColumn;
  return (
    <>
      <h2>{heading}</h2>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Date')}</th>
            <th>{l('Title')}</th>
            {hasCreditColumn ? <th>{l('Credited As')}</th> : null}
            {hasAttributeColumn ? <th>{l('Attributes')}</th> : null}
            {hasArtistColumn ? <th>{l('Artist')}</th> : null}
            {hasLengthColumn ? <th>{l('Length')}</th> : null}
          </tr>
        </thead>
        <tbody>
          {relationshipTypes.sort().map(relationshipType => (
            <React.Fragment key={relationshipType}>
              <tr className="subh">
                <th />
                <th colSpan={columnsCount}>
                  {l_relationships(relationshipType)}
                </th>
              </tr>
              {appearances[relationshipType].map((relationship, index) => {
                const attributes = relationship.attributes;
                let sourceCredit = '';
                let targetCredit = '';
                if (relationship.direction === 'backward') {
                  targetCredit = relationship.entity0_credit;
                  sourceCredit = relationship.entity1_credit;
                } else {
                  sourceCredit = relationship.entity0_credit;
                  targetCredit = relationship.entity1_credit;
                }

                return (
                  <tr className={loopParity(index)} key={relationship.id}>
                    <td>{formatDatePeriod(relationship)}</td>
                    <td>
                      {relationship.editsPending ? (
                        <span className="mp mp-rel">
                          <EntityLink
                            content={targetCredit}
                            entity={relationship.target}
                          />
                        </span>
                      ) : (
                        <EntityLink
                          content={targetCredit}
                          entity={relationship.target}
                        />
                      )}
                    </td>
                    {hasCreditColumn ? (
                      <td>
                        {sourceCredit || null}
                      </td>
                    ) : null}
                    {hasAttributeColumn ? (
                      <td>
                        {attributes && attributes.length > 0 ? (
                          commaList(
                            attributes.map(displayLinkAttribute),
                          )
                        ) : null}
                      </td>
                    ) : null}
                    {hasArtistColumn ? (
                      <td>
                        {relationship.target.artistCredit ? (
                          <ArtistCreditLink
                            artistCredit={relationship.target.artistCredit}
                          />
                        ) : null}
                      </td>
                    ) : null}
                    {hasLengthColumn ? (
                      <td>
                        {relationship.target.entityType === 'recording' ? (
                          formatTrackLength(relationship.target.length)
                        ) : null}
                      </td>
                    ) : null}
                  </tr>
                );
              })}
            </React.Fragment>
          ))}
        </tbody>
      </table>
    </>
  );
};

export default RelationshipsTable;
