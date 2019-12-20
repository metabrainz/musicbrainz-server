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
import RemoveFromMergeTableHeader from '../RemoveFromMergeTableHeader';
import SortableTableHeader from '../SortableTableHeader';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +$c: CatalystContextT,
  +artists: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showBeginEnd?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const ArtistList = ({
  $c,
  artists,
  checkboxes,
  instrumentCreditsAndRelTypes,
  mergeForm,
  order,
  showBeginEnd,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  sortable,
}: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        {$c.user_exists && (checkboxes || mergeForm) ? (
          <th className="checkbox-cell">
            {mergeForm ? null : <input type="checkbox" />}
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
        {showInstrumentCreditsAndRelTypes
          ? <th>{l('Relationship Types')}</th>
          : null}
        {mergeForm
          ? <RemoveFromMergeTableHeader toMerge={artists} />
          : null}
      </tr>
    </thead>
    <tbody>
      {artists.map((artist, index) => (
        <ArtistListEntry
          artist={artist}
          artistList={artists}
          checkboxes={checkboxes}
          index={index}
          instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
          key={artist.id}
          mergeForm={mergeForm}
          showBeginEnd={showBeginEnd}
          showInstrumentCreditsAndRelTypes={showInstrumentCreditsAndRelTypes}
          showRatings={showRatings}
        />
      ))}
    </tbody>
  </table>
);

export default withCatalystContext(ArtistList);
