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
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList';
import localizeArtistRoles
  from '../../static/scripts/common/i18n/localizeArtistRoles';
import {
  defineArtistRolesColumn,
  defineCheckboxColumn,
  defineDatePeriodColumn,
  defineNameColumn,
  defineSeriesNumberColumn,
  defineTypeColumn,
  defineTextColumn,
  locationColumn,
  ratingsColumn,
} from '../../utility/tableColumns';

type Props = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +artist?: ArtistT,
  +artistRoles?: boolean,
  +checkboxes?: string,
  +events: $ReadOnlyArray<EventT>,
  +order?: string,
  +showArtists?: boolean,
  +showLocation?: boolean,
  +showRatings?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

const EventList = ({
  $c,
  artist,
  artistRoles,
  checkboxes,
  events,
  order,
  seriesItemNumbers,
  showArtists,
  showLocation,
  showRatings,
  showType,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn(seriesItemNumbers)
        : null;
      const nameColumn =
        defineNameColumn<EventT>(
          l('Event'),
          order,
          sortable,
          false, // to use EntityLink without dates (separate column for that)
        );
      const typeColumn = defineTypeColumn('event_type', order, sortable);
      const artistsColumn = defineArtistRolesColumn<EventT>(
        entity => entity.performers,
        'performers',
        l('Artists'),
      );
      const timeColumn = defineTextColumn<EventT>(
        entity => entity.time,
        'time',
        l('Time'),
      );
      const rolesOnlyColumn = artist && artistRoles
        ? defineTextColumn<EventT>(
          entity => commaOnlyListText(
            entity.performers.reduce((result, performer) => {
              if (performer.entity.id === artist.id) {
                result.push(...localizeArtistRoles(performer.roles));
              }
              return result;
            }, []),
          ),
          'performers',
          l('Role'),
        )
        : null;
      const dateColumn = defineDatePeriodColumn(order, sortable);

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
      ];
    },
    [
      $c.user_exists,
      artist,
      artistRoles,
      checkboxes,
      order,
      seriesItemNumbers,
      showArtists,
      showLocation,
      showRatings,
      showType,
      sortable,
    ],
  );

  return <Table columns={columns} data={events} />;
};

export default withCatalystContext(EventList);
