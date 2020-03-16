/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {groupBy} from 'lodash';

import {withCatalystContext} from '../../context';
import loopParity from '../../utility/loopParity';
import releaseGroupType from '../../utility/releaseGroupType';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import EntityLink
  from '../../static/scripts/common/components/EntityLink';
import parseDate from '../../static/scripts/common/utility/parseDate';
import RatingStars from '../RatingStars';
import SortableTableHeader from '../SortableTableHeader';

type ReleaseGroupListHeaderProps = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +showRatings?: boolean,
  +showTypes?: boolean,
  +sortable?: boolean,
};

type ReleaseGroupListEntryProps = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +index: number,
  +releaseGroup: ReleaseGroupT,
  +showRatings?: boolean,
  +showTypes?: boolean,
};

type ReleaseGroupListTableProps = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +showTypes?: boolean,
  +sortable?: boolean,
};

type ReleaseGroupListProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const ReleaseGroupListHeader = ({
  $c,
  checkboxes,
  order,
  seriesItemNumbers,
  showRatings,
  showTypes,
  sortable,
}: ReleaseGroupListHeaderProps) => (
  <thead>
    <tr>
      {$c.user_exists && checkboxes ? (
        <th className="checkbox-cell">
          <input type="checkbox" />
        </th>
      ) : null}
      {seriesItemNumbers ? <th style={{width: '1em'}}>{l('#')}</th> : null}
      <th className="year c">
        {sortable
          ? (
            <SortableTableHeader
              label={l('Year')}
              name="year"
              order={order}
            />
          )
          : l('Year')}
      </th>
      <th>
        {sortable
          ? (
            <SortableTableHeader
              label={l('Title')}
              name="name"
              order={order}
            />
          )
          : l('Title')}
      </th>
      <th className="artist">{l('Artist')}</th>
      {showTypes ? (
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Type')}
                name="primary_type"
                order={order}
              />
            )
            : l('Type')}
        </th>
      ) : null}
      {showRatings ? <th className="rating c">{l('Rating')}</th> : null}
      <th className="count c">{l('Releases')}</th>
    </tr>
  </thead>
);

const ReleaseGroupListEntry = ({
  $c,
  checkboxes,
  index,
  releaseGroup,
  seriesItemNumbers,
  showRatings,
  showTypes,
}: ReleaseGroupListEntryProps) => (
  <tr className={loopParity(index)} key={releaseGroup.id}>
    {$c.user_exists && checkboxes ? (
      <td>
        <input
          name={checkboxes}
          type="checkbox"
          value={releaseGroup.id}
        />
      </td>
    ) : null}
    {seriesItemNumbers ? (
      <td style={{width: '1em'}}>
        {seriesItemNumbers[releaseGroup.id]}
      </td>
    ) : null}
    <td className="c">
      {releaseGroup.firstReleaseDate
        ? parseDate(releaseGroup.firstReleaseDate).year
        : '—'}
    </td>
    <td>
      <EntityLink entity={releaseGroup} />
    </td>
    <td>
      {releaseGroup.artistCredit
        ? <ArtistCreditLink artistCredit={releaseGroup.artistCredit} />
        : null}
    </td>
    {showTypes ? (
      <td>
        {releaseGroup.typeName
          ? releaseGroupType(releaseGroup)
          : null
        }
      </td>
    ) : null}
    {showRatings ? (
      <td className="c">
        <RatingStars entity={releaseGroup} />
      </td>
    ) : null}
    <td className="c">{releaseGroup.release_count}</td>
  </tr>
);

export const ReleaseGroupListTable = withCatalystContext(({
  $c,
  checkboxes,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings,
  showTypes = true,
  sortable,
}: ReleaseGroupListTableProps) => (
  <table className="tbl release-group-list">
    <ReleaseGroupListHeader
      $c={$c}
      checkboxes={checkboxes}
      order={order}
      seriesItemNumbers={seriesItemNumbers}
      showRatings={showRatings}
      showTypes={showTypes}
      sortable={sortable}
    />
    <tbody>
      {releaseGroups.map((releaseGroup, index) => (
        <ReleaseGroupListEntry
          $c={$c}
          checkboxes={checkboxes}
          index={index}
          key={releaseGroup.id}
          releaseGroup={releaseGroup}
          seriesItemNumbers={seriesItemNumbers}
          showRatings={showRatings}
          showTypes={showTypes}
        />
      ))}
    </tbody>
  </table>
));

const ReleaseGroupList = ({
  checkboxes,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings,
  sortable,
}: ReleaseGroupListProps) => {
  const groupedReleaseGroups = groupBy(releaseGroups, 'typeName');
  return (
    Object.keys(groupedReleaseGroups).map<React$Node>((type) => {
      const releaseGroupsOfType = groupedReleaseGroups[type];
      return (
        <React.Fragment key={type}>
          <h3>
            {type === 'null'
              ? l('Unspecified type')
              : releaseGroupType(releaseGroupsOfType[0])
            }
          </h3>
          <ReleaseGroupListTable
            checkboxes={checkboxes}
            order={order}
            releaseGroups={releaseGroupsOfType}
            seriesItemNumbers={seriesItemNumbers}
            showRatings={showRatings}
            showTypes={false}
            sortable={sortable}
          />
        </React.Fragment>
      );
    })
  );
};

export default ReleaseGroupList;
