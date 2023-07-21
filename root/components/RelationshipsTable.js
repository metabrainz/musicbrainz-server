/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {compare} from '../static/scripts/common/i18n.js';
import commaList from '../static/scripts/common/i18n/commaList.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import displayLinkAttribute
  from '../static/scripts/common/utility/displayLinkAttribute.js';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import {interpolateText} from '../static/scripts/edit/utility/linkPhrase.js';
import {formatCount} from '../statistics/utilities.js';
import loopParity from '../utility/loopParity.js';
import uriWith from '../utility/uriWith.js';

import PaginatedResults from './PaginatedResults.js';

type Props = {
  +entity: RelatableEntityT,
  +fallbackMessage?: string,
  +heading: string,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
};

const generalTypesList = ['recording', 'release', 'release_group', 'work'];
const recordingOnlyTypesList = ['recording'];

const pickAppearancesTypes = (entityType: RelatableEntityTypeT) => {
  switch (entityType) {
    case 'area':
    case 'artist':
    case 'place': {
      return generalTypesList;
    }
    case 'label':
      return [...generalTypesList, 'event'];
    case 'work': {
      return recordingOnlyTypesList;
    }
    default: return [];
  }
};

const getLinkPhraseForGroup = (linkTypeGroup: PagedLinkTypeGroupT) => (
  interpolateText(
    linkedEntities.link_type[linkTypeGroup.link_type_id],
    [],
    linkTypeGroup.backward
      ? 'reverse_link_phrase'
      : 'link_phrase',
    true, /* forGrouping */
  )
);

/*
 * Matches $DIRECTION_FORWARD and $DIRECTION_BACKWARD from
 * lib/MusicBrainz/Server/Constants.pm.
 */
const getDirectionInteger = (backward: boolean) => {
  return backward ? 2 : 1;
};

const RelationshipsTable = ({
  entity,
  fallbackMessage,
  heading,
  pagedLinkTypeGroup,
  pager,
}: Props): React$MixedElement | null => {
  const $c = React.useContext(CatalystContext);

  if (pagedLinkTypeGroup && !pager) {
    throw new Error('Expected a pager');
  }

  const appearanceTypes = pickAppearancesTypes(entity.entityType);

  let hasCreditColumn = false;
  let hasAttributeColumn = false;
  let hasArtistColumn = false;
  let hasLengthColumn = false;
  let columnsCount = 1;
  let totalRelationships = 0;

  type PagedLinkTypeGroupWithPhraseT = $ReadOnly<{
    ...PagedLinkTypeGroupT,
    +phrase: string,
  }>;

  type RelationshipsTableGroupPropsT = {
    +group: PagedLinkTypeGroupWithPhraseT,
    +relationshipRows: $ReadOnlyArray<React$MixedElement>,
  };

  const RelationshipsTableGroup = ({
    group,
    relationshipRows,
  }: RelationshipsTableGroupPropsT) => {
    const isLimited = (
      group.total_relationships >
      (group.offset + group.relationships.length)
    );

    return (
      <>
        <tr className="subh">
          <th />
          <th colSpan={columnsCount}>
            {group.phrase}
          </th>
        </tr>
        {relationshipRows}
        {isLimited ? (
          <tr>
            <td />
            <td colSpan={columnsCount} style={{padding: '1em'}}>
              <a
                href={uriWith(
                  $c.req.uri, {
                    direction: getDirectionInteger(group.backward),
                    link_type_id: group.link_type_id,
                    page: 1,
                  },
                )}
              >
                {texp.l('See all {num} relationships', {
                  num: formatCount($c, group.total_relationships),
                })}
              </a>
            </td>
          </tr>
        ) : null}
      </>
    );
  };

  type RelationshipsTableRowPropsT = {
    +artistCredit: ?ArtistCreditT,
    +index: number,
    +relationship: RelationshipT,
    +sourceCredit: string,
    +targetCredit: string,
  };

  const RelationshipsTableRow = ({
    artistCredit,
    index,
    relationship,
    sourceCredit,
    targetCredit,
  }: RelationshipsTableRowPropsT) => {
    return (
      <tr className={loopParity(index)} key={relationship.id}>
        <td>{formatDatePeriod(relationship)}</td>
        <td>
          {relationship.editsPending ? (
            <span className="mp mp-rel">
              <EntityLink
                content={targetCredit}
                entity={relationship.target}
                showIcon
              />
            </span>
          ) : (
            <EntityLink
              content={targetCredit}
              entity={relationship.target}
              showIcon
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
            {relationship.attributes?.length ? (
              commaList(
                relationship.attributes.map(displayLinkAttribute),
              )
            ) : null}
          </td>
        ) : null}
        {hasArtistColumn ? (
          <td>
            {artistCredit ? (
              <ArtistCreditLink
                artistCredit={artistCredit}
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
  };

  const tableRows: Array<React$MixedElement> = [];

  const getRelationshipRows = (
    linkTypeGroup: PagedLinkTypeGroupT | PagedLinkTypeGroupWithPhraseT,
    rows: Array<React$MixedElement>,
  ) => {
    let index = 0;

    totalRelationships += linkTypeGroup.total_relationships;

    for (const relationship of linkTypeGroup.relationships) {
      let sourceCredit = '';
      let targetCredit = '';
      if (relationship.backward) {
        targetCredit = relationship.entity0_credit;
        sourceCredit = relationship.entity1_credit;
      } else {
        sourceCredit = relationship.entity0_credit;
        targetCredit = relationship.entity1_credit;
      }

      const target = relationship.target;
      const artistCredit = hasOwnProp(target, 'artistCredit')
        ? target.artistCredit
        : null;

      hasCreditColumn = hasCreditColumn || nonEmpty(sourceCredit);
      hasAttributeColumn = hasAttributeColumn ||
        !!(relationship.attributes?.length);
      hasArtistColumn = hasArtistColumn || (artistCredit != null);
      hasLengthColumn = hasLengthColumn || (
        hasOwnProp(target, 'length') &&
        target.length != null
      );
      columnsCount = (
        1 +
        (hasCreditColumn ? 1 : 0) +
        (hasAttributeColumn ? 1 : 0) +
        (hasArtistColumn ? 1 : 0) +
        (hasLengthColumn ? 1 : 0)
      );

      rows.push(
        <RelationshipsTableRow
          artistCredit={artistCredit}
          index={index}
          key={relationship.id}
          relationship={relationship}
          sourceCredit={sourceCredit}
          targetCredit={targetCredit}
        />,
      );
      index++;
    }
  };

  const pagedRelationshipGroups = entity.paged_relationship_groups;
  if (pagedLinkTypeGroup) {
    getRelationshipRows(pagedLinkTypeGroup, tableRows);
  } else if (pagedRelationshipGroups) {
    const sortedTargetTypes =
      Object.keys(pagedRelationshipGroups).sort();
    for (const targetType of sortedTargetTypes) {
      if (!appearanceTypes.includes(targetType)) {
        continue;
      }

      const targetTypeGroup: ?PagedTargetTypeGroupT =
        pagedRelationshipGroups[targetType];
      if (!targetTypeGroup) {
        continue;
      }

      const linkTypeGroups: $ReadOnlyArray<$ReadOnly<{
        ...PagedLinkTypeGroupT,
        +phrase: string,
      }>> = Object.values(targetTypeGroup)
        .map((group: PagedLinkTypeGroupT) => ({
          ...group,
          phrase: getLinkPhraseForGroup(group),
        }))
        .sort((a, b) => compare(a.phrase, b.phrase));

      for (const linkTypeGroup of linkTypeGroups) {
        const relationshipRows: Array<React$MixedElement> = [];
        getRelationshipRows(linkTypeGroup, relationshipRows);

        tableRows.push(
          <RelationshipsTableGroup
            group={linkTypeGroup}
            key={linkTypeGroup.link_type_id + '-' +
              String(linkTypeGroup.backward)}
            relationshipRows={relationshipRows}
          />,
        );
      }
    }
  }

  if (totalRelationships === 0 && !pagedLinkTypeGroup) {
    return nonEmpty(fallbackMessage) ? (
      <>
        <h2>{heading}</h2>
        <p>{fallbackMessage}</p>
      </>
    ) : null;
  }

  const tableElement = (
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
        {tableRows}
      </tbody>
    </table>
  );
  let pageContent: React$MixedElement = tableElement;
  let finalHeading = heading;

  if (pagedLinkTypeGroup /*:: && pager */) {
    const linkPhrase = getLinkPhraseForGroup(pagedLinkTypeGroup);
    finalHeading = linkPhrase ? texp.l(
      '“{link_phrase}” relationships',
      {link_phrase: getLinkPhraseForGroup(pagedLinkTypeGroup)},
    ) : l('Invalid relationship type');
    if (pagedLinkTypeGroup.total_relationships > 0) {
      pageContent = (
        <PaginatedResults pager={pager}>
          {tableElement}
        </PaginatedResults>
      );
    } else {
      pageContent = (
        <p>
          {linkPhrase
            ? l('No relationships of the selected type were found.')
            : l('The provided relationship type ID is not valid.')}
        </p>
      );
    }
  }

  return (
    <>
      <h2>{finalHeading}</h2>
      {pageContent}
    </>
  );
};

export default RelationshipsTable;
