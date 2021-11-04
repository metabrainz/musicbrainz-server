/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import {SanitizedCatalystContext} from '../../context';
import manifest from '../../static/manifest';
import Table from '../Table';
import ReleaseGroupAppearances
  from '../../static/scripts/common/components/ReleaseGroupAppearances';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import {acoustIdsColumn}
  from '../../static/scripts/common/utility/tableColumns';
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
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...ReleaseGroupAppearancesRoleT,
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +lengthClass?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
  +showAcoustIds?: boolean,
  +showExpandedArtistCredits?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +showReleaseGroups?: boolean,
  +sortable?: boolean,
};

function defineReleaseGroupAppearancesColumn(
  releaseGroupAppearances,
): ColumnOptions<RecordingT, ReleaseGroupAppearancesT> {
  return {
    Cell: ({row: {original}}) => releaseGroupAppearances &&
      releaseGroupAppearances[original.id] ? (
        <ReleaseGroupAppearances
          appearances={releaseGroupAppearances[original.id]}
        />
      ) : null,
    Header: l('Release Groups'),
    id: 'appearances',
  };
}

const RecordingList = ({
  checkboxes,
  instrumentCreditsAndRelTypes,
  lengthClass,
  mergeForm,
  order,
  recordings,
  releaseGroupAppearances,
  seriesItemNumbers,
  showAcoustIds = false,
  showExpandedArtistCredits = false,
  showInstrumentCreditsAndRelTypes = false,
  showRatings = false,
  showReleaseGroups = false,
  sortable,
}: Props): React.MixedElement => {
  const $c = React.useContext(SanitizedCatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<RecordingWithArtistCreditT>({
        descriptive: false, // since ACs are in the next column
        order: order,
        sortable: sortable,
        title: l('Name'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<RecordingWithArtistCreditT>({
          columnName: 'artist',
          getArtistCredit: entity => entity.artistCredit,
          order: order,
          showExpandedArtistCredits: showExpandedArtistCredits,
          sortable: sortable,
          title: l('Artist'),
        });
      const lengthColumn = defineTextColumn<RecordingWithArtistCreditT>({
        cellProps: {className: lengthClass ?? ''},
        columnName: 'length',
        /* Show nothing rather than ?:?? for recordings merged away */
        getText: entity => entity.gid ? formatTrackLength(entity.length) : '',
        order: order,
        sortable: sortable,
        title: l('Length'),
      });
      const releaseGroupAppearancesColumn = showReleaseGroups
        ? defineReleaseGroupAppearancesColumn(releaseGroupAppearances)
        : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes: instrumentCreditsAndRelTypes,
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
      checkboxes,
      instrumentCreditsAndRelTypes,
      lengthClass,
      mergeForm,
      order,
      recordings,
      releaseGroupAppearances,
      seriesItemNumbers,
      showAcoustIds,
      showExpandedArtistCredits,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      showReleaseGroups,
      sortable,
    ],
  );

  return (
    <>
      <Table
        columns={columns}
        data={recordings}
      />
      {manifest.js('common/components/AcoustIdCell', {async: 'async'})}
    </>
  );
};

export default RecordingList;
