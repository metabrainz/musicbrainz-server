/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import {SanitizedCatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import manifest from '../../static/manifest.mjs';
import ReleaseGroupAppearances
  from '../../static/scripts/common/components/ReleaseGroupAppearances.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import {
  acoustIdsColumn,
  defineNameAndCommentColumn,
} from '../../static/scripts/common/utility/tableColumns.js';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  isrcsColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

function defineReleaseGroupAppearancesColumn(
  releaseGroupAppearances: ReleaseGroupAppearancesMapT | void,
): ColumnOptions<RecordingT, ReleaseGroupAppearancesT> {
  return {
    Cell: ({row: {original}}) => releaseGroupAppearances &&
      releaseGroupAppearances[original.id] ? (
        <ReleaseGroupAppearances
          appearances={releaseGroupAppearances[original.id]}
        />
      ) : null,
    Header: l('Release groups'),
    id: 'appearances',
  };
}

component RecordingList(
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  instrumentCreditsAndRelTypes?: InstrumentCreditsAndRelTypesT,
  lengthClass?: string,
  mergeForm?: MergeFormT,
  order?: string,
  recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
  releaseGroupAppearances?: ReleaseGroupAppearancesMapT,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showAcoustIds: boolean = false,
  showCollectionComments: boolean = false,
  showExpandedArtistCredits: boolean = false,
  showInstrumentCreditsAndRelTypes: boolean = false,
  showRatings: boolean = false,
  showReleaseGroups: boolean = false,
  sortable?: boolean,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<RecordingWithArtistCreditT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          descriptive: false, // since ACs are in the next column
          order,
          sortable,
          title: l('Name'),
        })
      ) : (
        defineNameColumn<RecordingWithArtistCreditT>({
          descriptive: false, // since ACs are in the next column
          order,
          sortable,
          title: l('Name'),
        })
      );
      const artistCreditColumn =
        defineArtistCreditColumn<RecordingWithArtistCreditT>({
          columnName: 'artist',
          getArtistCredit: entity => entity.artistCredit,
          order,
          showExpandedArtistCredits,
          sortable,
          title: l('Artist'),
        });
      const lengthColumn = defineTextColumn<RecordingWithArtistCreditT>({
        cellProps: {className: lengthClass ?? ''},
        columnName: 'length',
        /* Show nothing rather than ?:?? for recordings merged away */
        getText: entity => entity.gid ? formatTrackLength(entity.length) : '',
        order,
        sortable,
        title: l('Length'),
      });
      const releaseGroupAppearancesColumn = showReleaseGroups
        ? defineReleaseGroupAppearancesColumn(releaseGroupAppearances)
        : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes,
        })
        : null;
      const ratingsColumn = defineRatingsColumn<RecordingT>({
        getEntity: entity => entity,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        artistCreditColumn,
        isrcsColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(showAcoustIds ? [acoustIdsColumn] : []),
        lengthColumn,
        ...(releaseGroupAppearancesColumn
          ? [releaseGroupAppearancesColumn]
          : []),
        ...(instrumentUsageColumn ? [instrumentUsageColumn] : []),
        ...(mergeForm && recordings.length > 2
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
      instrumentCreditsAndRelTypes,
      lengthClass,
      mergeForm,
      order,
      recordings,
      releaseGroupAppearances,
      seriesItemNumbers,
      showAcoustIds,
      showCollectionComments,
      showExpandedArtistCredits,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      showReleaseGroups,
      sortable,
    ],
  );

  const table = useTable<RecordingWithArtistCreditT>({
    columns,
    data: recordings,
  });

  return (
    <>
      {table}
      {manifest('common/components/AcoustIdCell', {async: 'async'})}
      {manifest('common/components/IsrcList', {async: 'async'})}
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
}

export default RecordingList;
