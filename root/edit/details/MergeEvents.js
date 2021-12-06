/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EventList from '../../components/list/EventList';

type Props = {
  +edit: MergeEventsEditT,
};

const MergeEvents = ({edit}: Props): React.Element<'table'> => (
  <table className="details merge-events">
    <tr>
      <th>{l('Merge:')}</th>
      <td>
        <EventList
          events={edit.display_data.old}
          showArtists
          showLocation
          showType
        />
      </td>
    </tr>
    <tr>
      <th>{l('Into:')}</th>
      <td>
        <EventList
          events={[edit.display_data.new]}
          showArtists
          showLocation
          showType
        />
      </td>
    </tr>
  </table>
);

export default MergeEvents;
