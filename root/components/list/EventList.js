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
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import localizeArtistRoles
  from '../../static/scripts/common/i18n/localizeArtistRoles.js';
import {
  defineArtistRolesColumn,
  defineCheckboxColumn,
  defineDatePeriodColumn,
  defineLocationColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

type Props = {
  ...SeriesItemNumbersRoleT,
  +artist?: ArtistT,
  +artistRoles?: boolean,
  +checkboxes?: string,
  +events: $ReadOnlyArray<EventT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showArtists?: boolean,
  +showLocation?: boolean,
  +showRatings?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

const EventList = ({
  artist,
  artistRoles = false,
  checkboxes,
  events,
  mergeForm,
  order,
  seriesItemNumbers,
  showArtists = false,
  showLocation = false,
  showRatings = false,
  showType = false,
  sortable,
}: Props): React$Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<EventT>({
        descriptive: false, // since dates have their own column
        order: order,
        sortable: sortable,
        title: l('Event'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'event_type',
      });
      const artistsColumn = defineArtistRolesColumn<EventT>({
        columnName: 'performers',
        getRoles: entity => entity.performers,
        title: l('Artists'),
      });
      const locationColumn = defineLocationColumn<EventT>({
        getEntity: entity => entity,
      });
      const timeColumn = defineTextColumn<EventT>({
        columnName: 'time',
        getText: entity => entity.time,
        title: l('Time'),
      });
      const rolesOnlyColumn = artist && artistRoles
        ? defineTextColumn<EventT>({
          columnName: 'performers',
          getText: entity => commaOnlyListText(
            entity.performers.reduce((
              result: Array<string>,
              performer,
            ) => {
              if (performer.entity.id === artist.id) {
                result.push(...localizeArtistRoles(performer.roles));
              }
              return result;
            }, []),
          ),
          title: l('Role'),
        })
        : null;
      const dateColumn = defineDatePeriodColumn<EventT>({
        getEntity: entity => entity,
        order: order,
        sortable: sortable,
      });
      const ratingsColumn = defineRatingsColumn<EventT>({
        getEntity: entity => entity,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        ...(showType ? [typeColumn] : []),
        ...(showArtists ? [artistsColumn] : []),
        ...(rolesOnlyColumn ? [rolesOnlyColumn] : []),
        ...(showLocation ? [locationColumn] : []),
        dateColumn,
        timeColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(mergeForm && events.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      artist,
      artistRoles,
      checkboxes,
      events,
      mergeForm,
      order,
      seriesItemNumbers,
      showArtists,
      showLocation,
      showRatings,
      showType,
      sortable,
    ],
  );

  const table = useTable<EventT>({columns, data: events});

  return (
    <>
      {table}
      {manifest.js('common/components/ArtistRoles', {async: 'async'})}
    </>
  );
};

export default EventList;
