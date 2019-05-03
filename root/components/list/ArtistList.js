/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../context';
import ArtistListEntry
  from '../../static/scripts/common/components/ArtistListEntry';

import SortableTableHeader from '../SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +artists: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +order?: string,
  +showBeginEnd?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
|};

const ArtistList = ({
  $c,
  artists,
  checkboxes,
  order,
  showBeginEnd,
  showRatings,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th>
            <input type="checkbox" />
          </th>
        ) : null}
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Artist')}
                name="name"
                order={order}
              />
            )
            : l('Artist')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Type')}
                name="type"
                order={order}
              />
            )
            : l('Type')}
        </th>
        <th>
          {sortable
            ? (
              <SortableTableHeader
                label={l('Gender')}
                name="gender"
                order={order}
              />
            )
            : l('Gender')}
        </th>
        <th>{l('Area')}</th>
        {showBeginEnd ? (
          <>
            <th>{l('Begin')}</th>
            <th>{l('Begin Area')}</th>
            <th>{l('End')}</th>
            <th>{l('End Area')}</th>
          </>
        ) : null}
        {showRatings ? <th>{l('Rating')}</th> : null}
      </tr>
    </thead>
    <tbody>
      {artists.map((artist, index) => (
        <ArtistListEntry
          artist={artist}
          checkboxes={checkboxes}
          index={index}
          key={artist.id}
          showBeginEnd={showBeginEnd}
          showRatings={showRatings}
        />
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(ArtistList);
