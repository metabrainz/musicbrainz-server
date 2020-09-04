/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  acoustidColumn,
  isrcsColumn,
  ratingsColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns';
import hydrate from '../../utility/hydrate';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +lengthClass?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +recordings: $ReadOnlyArray<RecordingT>,
  +showAcoustid?: boolean,
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
  showAcoustid = false,
  showExpandedArtistCredits = false,
  showInstrumentCreditsAndRelTypes = false,
  showRatings = false,
  sortable,
}: Props): React.Element<typeof Table> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
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
        ...(showAcoustid ? [acoustidColumn] : []),
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
      showAcoustid,
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

export default (hydrate<Props>(
  'div.recording-list',
  RecordingList,
): React.AbstractComponent<Props, void>);
