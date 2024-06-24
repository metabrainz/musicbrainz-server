/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import InstrumentRelTypes
  from '../../../../components/InstrumentRelTypes.js';
import RemoveFromMergeTableCell
  from '../../../../components/RemoveFromMergeTableCell.js';
import {CatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity.js';
import formatDate from '../utility/formatDate.js';
import formatEndDate from '../utility/formatEndDate.js';

import DescriptiveLink from './DescriptiveLink.js';
import MergeCheckboxElement from './MergeCheckboxElement.js';
import RatingStars from './RatingStars.js';

component ArtistListRow(
  artist: ArtistT,
  artistList?: $ReadOnlyArray<ArtistT>,
  checkboxes?: string,
  index: number,
  instrumentCreditsAndRelTypes?: InstrumentCreditsAndRelTypesT,
  mergeForm?: MergeFormT,
  showBeginEnd: boolean = false,
  showInstrumentCreditsAndRelTypes: boolean = false,
  showRatings: boolean = false,
  showSortName: boolean = false,
) {
  const $c = React.useContext(CatalystContext);

  return (
    <>
      {$c.user && (nonEmpty(checkboxes) || mergeForm) ? (
        <td>
          {mergeForm
            ? (
              <MergeCheckboxElement
                entity={artist}
                form={mergeForm}
                index={index}
              />
            ) : (
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
        {nonEmpty(artist.typeName)
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
      {showInstrumentCreditsAndRelTypes ? (
        <td>
          <InstrumentRelTypes
            entity={artist}
            instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
          />
        </td>
      ) : null}
      {mergeForm && artistList ? (
        <RemoveFromMergeTableCell
          entity={artist}
          toMerge={artistList}
        />
      ) : null}
    </>
  );
}

component ArtistListEntry(
  score?: number,
  ...rowProps: React.PropsOf<ArtistListRow>
) {
  return (
    <tr className={loopParity(rowProps.index)} data-score={score ?? null}>
      <ArtistListRow {...rowProps} />
    </tr>
  );
}

export default ArtistListEntry;
