/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import {groupBy} from '../../static/scripts/common/utility/arrays.js';
import parseDate from '../../static/scripts/common/utility/parseDate.js';
import releaseGroupType from '../../utility/releaseGroupType.js';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineCountColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';
import Table from '../Table.js';

type ReleaseGroupListTableProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

type ReleaseGroupListProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +sortable?: boolean,
};

export const ReleaseGroupListTable = ({
  checkboxes,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings = false,
  showType = true,
  sortable,
}: ReleaseGroupListTableProps): React.Element<typeof Table> => {
  const $c = React.useContext(CatalystContext);

  function getFirstReleaseYear(entity: ReleaseGroupT) {
    if (empty(entity.firstReleaseDate)) {
      return '—';
    }

    return parseDate(entity.firstReleaseDate).year?.toString() ?? '—';
  }

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const yearColumn = defineTextColumn<ReleaseGroupT>({
        cellProps: {className: 'c'},
        columnName: 'year',
        getText: entity => getFirstReleaseYear(entity),
        headerProps: {className: 'year c'},
        order: order,
        sortable: sortable,
        title: l('Year'),
      });
      const nameColumn = defineNameColumn<ReleaseGroupT>({
        descriptive: false, // since ACs are in the next column
        order: order,
        showCaaPresence: true,
        sortable: sortable,
        title: l('Title'),
      });
      const artistCreditColumn = defineArtistCreditColumn<ReleaseGroupT>({
        columnName: 'artist',
        getArtistCredit: entity => entity.artistCredit,
        order: order,
        sortable: sortable,
        title: l('Artist'),
      });
      const typeColumn = defineTextColumn<ReleaseGroupT>({
        columnName: 'primary-type',
        getText: entity => entity.l_type_name || '',
        order: order,
        sortable: sortable,
        title: l('Type'),
      });
      const releaseNumberColumn = defineCountColumn<ReleaseGroupT>({
        columnName: 'release_count',
        getCount: entity => entity.release_count,
        title: l('Releases'),
      });
      const ratingsColumn = defineRatingsColumn<ReleaseGroupT>({
        getEntity: entity => entity,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        yearColumn,
        nameColumn,
        artistCreditColumn,
        ...(showType ? [typeColumn] : []),
        ...(showRatings ? [ratingsColumn] : []),
        releaseNumberColumn,
        ...(mergeForm && releaseGroups.length > 2
          ? [removeFromMergeColumn]
          : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      mergeForm,
      order,
      releaseGroups,
      seriesItemNumbers,
      showRatings,
      showType,
      sortable,
    ],
  );

  return (
    <Table
      className="release-group-list"
      columns={columns}
      data={releaseGroups}
    />
  );
};

const ReleaseGroupList = ({
  checkboxes,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings,
  sortable,
}: ReleaseGroupListProps): Array<React$Node> => {
  const groupedReleaseGroups = groupBy(releaseGroups, x => x.typeName ?? '');
  const tables = [];
  for (const [type, releaseGroupsOfType] of groupedReleaseGroups) {
    tables.push(
      <React.Fragment key={type}>
        <h3>
          {type === ''
            ? l('Unspecified type')
            : releaseGroupType(releaseGroupsOfType[0])
          }
        </h3>
        <ReleaseGroupListTable
          checkboxes={checkboxes}
          mergeForm={mergeForm}
          order={order}
          releaseGroups={releaseGroupsOfType}
          seriesItemNumbers={seriesItemNumbers}
          showRatings={showRatings}
          showType={false}
          sortable={sortable}
        />
      </React.Fragment>,
    );
  }
  return tables;
};

export default ReleaseGroupList;
