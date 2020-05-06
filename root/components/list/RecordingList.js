/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import {withCatalystContext} from '../../context';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineRemoveFromMergeColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  isrcsColumn,
  ratingsColumn,
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
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn(seriesItemNumbers)
        : null;
      const nameColumn =
        defineNameColumn<RecordingT>(
          l('Name'),
          order,
          sortable,
          false, // no descriptive linking (since ACs are in the next column)
        );
      const artistCreditColumn = defineArtistCreditColumn<RecordingT>(
        entity => entity.artistCredit,
        'artist',
        l('Artist'),
        order,
        sortable,
        showExpandedArtistCredits,
      );
      const lengthColumn = defineTextColumn<RecordingT>(
        /* Show nothing rather than ?:?? for recordings merged away */
        entity => entity.gid ? formatTrackLength(entity.length) : '',
        'length',
        l('Length'),
        order,
        sortable,
        {className: lengthClass ?? ''},
      );
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn(instrumentCreditsAndRelTypes)
        : null;
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(recordings)
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
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
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

  return (
    <Table
      columns={columns}
      data={recordings}
    />
  );
};

export default withCatalystContext(RecordingList);
