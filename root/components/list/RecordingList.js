/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import useTable from '../../hooks/useTable';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  isrcsColumn,
  ratingsColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +lengthClass?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +recordings: $ReadOnlyArray<RecordingT>,
  +showExpandedArtistCredits?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const RecordingList = ({
  $c,
  checkboxes,
  instrumentCreditsAndRelTypes,
  lengthClass,
  mergeForm,
  order,
  recordings,
  seriesItemNumbers,
  showExpandedArtistCredits,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  sortable,
}: Props): React.Element<'table'> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<RecordingT>({
        descriptive: false, // since ACs are in the next column
        order: order,
        sortable: sortable,
        title: l('Name'),
      });
      const artistCreditColumn = defineArtistCreditColumn<RecordingT>({
        columnName: 'artist',
        getArtistCredit: entity => entity.artistCredit,
        order: order,
        showExpandedArtistCredits: showExpandedArtistCredits,
        sortable: sortable,
        title: l('Artist'),
      });
      const lengthColumn = defineTextColumn<RecordingT>({
        cellProps: {className: lengthClass ?? ''},
        columnName: 'length',
        /* Show nothing rather than ?:?? for recordings merged away */
        getText: entity => entity.gid ? formatTrackLength(entity.length) : '',
        order: order,
        sortable: sortable,
        title: l('Length'),
      });
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes: instrumentCreditsAndRelTypes,
        })
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        artistCreditColumn,
        isrcsColumn,
        ...(showRatings ? [ratingsColumn] : []),
        lengthColumn,
        ...(instrumentUsageColumn ? [instrumentUsageColumn] : []),
        ...(mergeForm && recordings.length > 2
          ? [removeFromMergeColumn]
          : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      instrumentCreditsAndRelTypes,
      lengthClass,
      mergeForm,
      order,
      recordings,
      seriesItemNumbers,
      showExpandedArtistCredits,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      sortable,
    ],
  );

  return useTable<RecordingT>({
    columns,
    data: recordings,
  });
};

export default RecordingList;
