/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../../context';
import RemoveFromMergeTableCell
  from '../../../../components/RemoveFromMergeTableCell';
import RatingStars from '../../../../components/RatingStars';
import loopParity from '../../../../utility/loopParity';
import formatDate from '../utility/formatDate';
import formatEndDate from '../utility/formatEndDate';
import renderMergeCheckboxElement
  from '../utility/renderMergeCheckboxElement';

import DescriptiveLink from './DescriptiveLink';

type ArtistListRowProps = {
  +$c: CatalystContextT,
  +artist: ArtistT,
  +artistList?: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +index: number,
  +mergeForm?: MergeFormT,
  +showBeginEnd?: boolean,
  +showRatings?: boolean,
  +showSortName?: boolean,
};

type ArtistListEntryProps = {
  +artist: ArtistT,
  +artistList?: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +index: number,
  +mergeForm?: MergeFormT,
  +score?: number,
  +showBeginEnd?: boolean,
  +showRatings?: boolean,
  +showSortName?: boolean,
};

const ArtistListRow = withCatalystContext(({
  $c,
  artist,
  artistList,
  checkboxes,
  index,
  mergeForm,
  showBeginEnd,
  showRatings,
  showSortName,
}: ArtistListRowProps) => (
  <>
    {$c.user_exists && (checkboxes || mergeForm) ? (
      <td>
        {mergeForm
          ? renderMergeCheckboxElement(artist, mergeForm, index)
          : (
            <input
              name={checkboxes}
              type="checkbox"
              value={artist.id}
            />
          )}
      </td>
    ) : null}
    <td>
      <DescriptiveLink entity={artist} />
    </td>
    {showSortName ? <td>{artist.sort_name}</td> : null}
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
    <td>
      {artist.area ? <DescriptiveLink entity={artist.area} /> : null}
    </td>
    {showBeginEnd ? (
      <>
        <td>{formatDate(artist.begin_date)}</td>
        <td>
          {artist.begin_area
            ? <DescriptiveLink entity={artist.begin_area} />
            : null}
        </td>
        <td>{formatEndDate(artist)}</td>
        <td>
          {artist.end_area
            ? <DescriptiveLink entity={artist.end_area} />
            : null}
        </td>
      </>
    ) : null}
    {showRatings ? (
      <td>
        <RatingStars entity={artist} />
      </td>
    ) : null}
    {mergeForm && artistList ? (
      <RemoveFromMergeTableCell
        entity={artist}
        toMerge={artistList}
      />
    ) : null}
  </>
));

const ArtistListEntry = ({
  artist,
  artistList,
  checkboxes,
  index,
  mergeForm,
  score,
  showBeginEnd,
  showRatings,
  showSortName,
}: ArtistListEntryProps) => (
  <tr className={loopParity(index)} data-score={score || null}>
    <ArtistListRow
      artist={artist}
      artistList={artistList}
      checkboxes={checkboxes}
      index={index}
      mergeForm={mergeForm}
      showBeginEnd={showBeginEnd}
      showRatings={showRatings}
      showSortName={showSortName}
    />
  </tr>
);

export default ArtistListEntry;
