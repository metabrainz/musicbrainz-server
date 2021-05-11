/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import loopParity from '../utility/loopParity';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import {compare} from '../static/scripts/common/i18n';
import commaList from '../static/scripts/common/i18n/commaList';
import formatDatePeriod
  from '../static/scripts/common/utility/formatDatePeriod';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';
import displayLinkAttribute
  from '../static/scripts/common/utility/displayLinkAttribute';
import {interpolateText} from '../static/scripts/edit/utility/linkPhrase';
import {formatCount} from '../statistics/utilities';
import uriWith from '../utility/uriWith';

import PaginatedResults from './PaginatedResults';

type Props = {
  +$c: CatalystContextT,
  +entity: CoreEntityT,
  +fallbackMessage?: string,
  +heading: string,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
};

const generalTypesList = ['recording', 'release', 'release_group', 'work'];
const recordingOnlyTypesList = ['recording'];

const pickAppearancesTypes = (entityType) => {
  switch (entityType) {
    case 'area':
    case 'artist':
    case 'label':
    case 'place': {
      return generalTypesList;
    }
    case 'work': {
      return recordingOnlyTypesList;
    }
    default: return [];
  }
};

const getLinkPhraseForGroup = (linkTypeGroup) => (
  interpolateText(
    {linkTypeID: linkTypeGroup.link_type_id},
    linkTypeGroup.direction === 'backward'
      ? 'reverse_link_phrase'
      : 'link_phrase',
    true, /* forGrouping */
  )
);

const getDirectionFromName = (direction) => {
  switch (direction) {
    case 'forward':
      return 1;
    case 'backward':
      return 2;
    default:
      return 0;
  }
};

const RelationshipsTable = ({
  $c,
  entity,
  fallbackMessage,
  heading,
  pagedLinkTypeGroup,
  pager,
}: Props): React.MixedElement | null => {
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

  const RelationshipsTableGroup = ({
    group,
    relationshipRows,
  }) => {
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
                    direction: getDirectionFromName(group.direction),
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

  const RelationshipsTableRow = ({
    artistCredit,
    index,
    relationship,
    sourceCredit,
    targetCredit,
  }) => {
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

  const tableRows = [];

  const getRelationshipRows = (
    linkTypeGroup,
    rows,
  ) => {
    let index = 0;

    totalRelationships += linkTypeGroup.total_relationships;

    for (const relationship of linkTypeGroup.relationships) {
      let sourceCredit = '';
      let targetCredit = '';
      if (relationship.direction === 'backward') {
        targetCredit = relationship.entity0_credit;
        sourceCredit = relationship.entity1_credit;
      } else {
        sourceCredit = relationship.entity0_credit;
        targetCredit = relationship.entity1_credit;
      }

      const target = relationship.target;
      const artistCredit = hasOwnProp(target, 'artistCredit')
        // $FlowIgnore[prop-missing]
        ? target.artistCredit
        : null;

      hasCreditColumn = hasCreditColumn || nonEmpty(sourceCredit);
      hasAttributeColumn = hasAttributeColumn ||
        !!(relationship.attributes?.length);
      hasArtistColumn = hasArtistColumn || (artistCredit != null);
      hasLengthColumn = hasLengthColumn || (
        hasOwnProp(target, 'length') &&
        // $FlowIgnore[prop-missing]
        target.length != null
      );
      columnsCount = (
        1 +
        hasCreditColumn +
        hasAttributeColumn +
        hasArtistColumn +
        hasLengthColumn
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
        // $FlowIgnore[incompatible-call]
        .map((group: PagedLinkTypeGroupT) => ({
          ...group,
          phrase: getLinkPhraseForGroup(group),
        }))
        .sort((a, b) => compare(a.phrase, b.phrase));

      for (const linkTypeGroup of linkTypeGroups) {
        const relationshipRows = [];
        getRelationshipRows(linkTypeGroup, relationshipRows);

        tableRows.push(
          <RelationshipsTableGroup
            group={linkTypeGroup}
            key={linkTypeGroup.link_type_id + '-' + linkTypeGroup.direction}
            relationshipRows={relationshipRows}
          />,
        );
      }
    }
  }

  if (totalRelationships === 0) {
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
  let pageContent = tableElement;
  let finalHeading = heading;

  if (pagedLinkTypeGroup /*:: && pager */) {
    finalHeading = exp.l(
      '“{link_phrase}” relationships',
      {link_phrase: getLinkPhraseForGroup(pagedLinkTypeGroup)},
    );
    pageContent = (
      <PaginatedResults pager={pager}>
        {tableElement}
      </PaginatedResults>
    );
  }

  return (
    <>
      <h2>{finalHeading}</h2>
      {pageContent}
    </>
  );
};

export default RelationshipsTable;
