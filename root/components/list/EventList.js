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
  defineRemoveFromMergeColumn,
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
  +mergeForm?: MergeFormT,
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
  mergeForm,
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
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
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
      const timeColumn = defineTextColumn<EventT>({
        columnName: 'time',
        getText: entity => entity.time,
        title: l('Time'),
      });
      const rolesOnlyColumn = artist && artistRoles
        ? defineTextColumn<EventT>({
          columnName: 'performers',
          getText: entity => commaOnlyListText(
            entity.performers.reduce((result, performer) => {
              if (performer.entity.id === artist.id) {
                result.push(...localizeArtistRoles(performer.roles));
              }
              return result;
            }, []),
          ),
          title: l('Role'),
        })
        : null;
      const dateColumn = defineDatePeriodColumn({
        order: order,
        sortable: sortable,
      });
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn({toMerge: events})
        : null;

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
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
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

  return <Table columns={columns} data={events} />;
};

export default withCatalystContext(EventList);
