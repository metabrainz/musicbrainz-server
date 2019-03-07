/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import loopParity from '../utility/loopParity';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';

import RatingStars from './RatingStars';
import SortableTableHeader from './SortableTableHeader';

type Props = {|
  +$c: CatalystContextT,
  +artists: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +noRatings?: boolean,
  +order?: string,
  +sortable?: boolean,
|};

const ArtistsList = ({
  $c,
  artists,
  checkboxes,
  noRatings,
  order,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && checkboxes ? (
          <th style={{width: '1em'}}>
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
        {noRatings ? null : <th>{l('Rating')}</th>}
      </tr>
    </thead>
    <tbody>
      {artists.map((artist, index) => (
        <tr className={loopParity(index)} key={artist.id}>
          {$c.user_exists && checkboxes ? (
            <td>
              <input
                name={checkboxes}
                type="checkbox"
                value={artist.id}
              />
            </td>
          ) : null}
          <td>
            <DescriptiveLink entity={artist} />
          </td>
          <td>
            {artist.typeName
              ? lp_attributes(artist.typeName, 'artist_type')
              : null}
          </td>
          <td>
            {artist.gender
              ? lp_attributes(artist.gender.name, 'gender')
              : null}
          </td>
          {noRatings ? null : (
            <td>
              <RatingStars entity={artist} />
            </td>
          )}
        </tr>
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(ArtistsList);
