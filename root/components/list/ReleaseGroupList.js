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
import useTable from '../../hooks/useTable.js';
import * as manifest from '../../static/manifest.mjs';
import {groupBy} from '../../static/scripts/common/utility/arrays.js';
import parseDate from '../../static/scripts/common/utility/parseDate.js';
import {defineNameAndCommentColumn}
  from '../../static/scripts/common/utility/tableColumns.js';
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

type ReleaseGroupListTableProps = {
  ...CollectionCommentsRoleT,
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showCollectionComments?: boolean,
  +showRatings?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

type ReleaseGroupListProps = {
  ...CollectionCommentsRoleT,
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showCollectionComments?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

export const ReleaseGroupListTable = ({
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showCollectionComments = false,
  showRatings = false,
  showType = true,
  sortable,
}: ReleaseGroupListTableProps): React$Element<'table'> => {
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
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<ReleaseGroupT>({
          canEditCollectionComments: canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId: collectionId,
          descriptive: false, // since ACs are in the next column
          order: order,
          showCaaPresence: true,
          sortable: sortable,
          title: l('Title'),
        })
      ) : (
        defineNameColumn<ReleaseGroupT>({
          descriptive: false, // since ACs are in the next column
          order: order,
          showCaaPresence: true,
          sortable: sortable,
          title: l('Title'),
        })
      );
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
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      mergeForm,
      order,
      releaseGroups,
      seriesItemNumbers,
      showCollectionComments,
      showRatings,
      showType,
      sortable,
    ],
  );

  return useTable<ReleaseGroupT>({
    className: 'release-group-list',
    columns,
    data: releaseGroups,
  });
};

const ReleaseGroupList = ({
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showCollectionComments,
  showRatings,
  sortable,
}: ReleaseGroupListProps): Array<React$Element<React$FragmentType>> => {
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
          canEditCollectionComments={canEditCollectionComments}
          checkboxes={checkboxes}
          collectionComments={collectionComments}
          collectionId={collectionId}
          mergeForm={mergeForm}
          order={order}
          releaseGroups={releaseGroupsOfType}
          seriesItemNumbers={seriesItemNumbers}
          showCollectionComments={showCollectionComments}
          showRatings={showRatings}
          showType={false}
          sortable={sortable}
        />
      </React.Fragment>,
    );
  }

  tables.push(
    <>
      {manifest.js('common/components/NameWithCommentCell', {async: 'async'})}
    </>,
  );

  return tables;
};

export default ReleaseGroupList;
