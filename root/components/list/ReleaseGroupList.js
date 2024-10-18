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
import manifest from '../../static/manifest.mjs';
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

export component ReleaseGroupListTable(
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  mergeForm?: MergeFormT,
  order?: string,
  releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showCollectionComments: boolean = false,
  showRatings: boolean = false,
  showType: boolean = true,
  sortable?: boolean,
) {
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
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers})
        : null;
      const yearColumn = defineTextColumn<ReleaseGroupT>({
        cellProps: {className: 'c'},
        columnName: 'year',
        getText: entity => getFirstReleaseYear(entity),
        headerProps: {className: 'year c'},
        order,
        sortable,
        title: l('Year'),
      });
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<ReleaseGroupT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          descriptive: false, // since ACs are in the next column
          order,
          showArtworkPresence: true,
          sortable,
          title: l('Title'),
        })
      ) : (
        defineNameColumn<ReleaseGroupT>({
          descriptive: false, // since ACs are in the next column
          order,
          showArtworkPresence: true,
          sortable,
          title: l('Title'),
        })
      );
      const artistCreditColumn = defineArtistCreditColumn<ReleaseGroupT>({
        columnName: 'artist',
        getArtistCredit: entity => entity.artistCredit,
        order,
        sortable,
        title: l('Artist'),
      });
      const typeColumn = defineTextColumn<ReleaseGroupT>({
        columnName: 'primary-type',
        getText: entity => entity.l_type_name || '',
        order,
        sortable,
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
}

component ReleaseGroupList(...props: React.PropsOf<ReleaseGroupListTable>) {
  const groupedReleaseGroups =
    groupBy(props.releaseGroups, x => x.typeName ?? '');
  const tables: Array<React.MixedElement> = [];
  for (const [type, releaseGroupsOfType] of groupedReleaseGroups) {
    tables.push(
      <React.Fragment key={type}>
        <h3>
          {type === ''
            ? l('Unspecified type')
            : releaseGroupType(releaseGroupsOfType[0])}
        </h3>
        <ReleaseGroupListTable
          {...props}
          releaseGroups={releaseGroupsOfType}
          showType={false}
        />
      </React.Fragment>,
    );
  }

  tables.push(
    <>
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
    </>,
  );

  return tables;
}

export default ReleaseGroupList;
