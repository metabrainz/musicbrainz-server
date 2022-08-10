/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../../context.mjs';
import InstrumentRelTypes
  from '../../../../components/InstrumentRelTypes.js';
import RemoveFromMergeTableCell
  from '../../../../components/RemoveFromMergeTableCell.js';
import loopParity from '../../../../utility/loopParity.js';
import formatDate from '../utility/formatDate.js';
import formatEndDate from '../utility/formatEndDate.js';
import renderMergeCheckboxElement
  from '../utility/renderMergeCheckboxElement.js';

import DescriptiveLink from './DescriptiveLink.js';
import RatingStars from './RatingStars.js';

type ArtistListRowProps = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +artist: ArtistT,
  +artistList?: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +index: number,
  +mergeForm?: MergeFormT,
  +showBeginEnd?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +showSortName?: boolean,
};

type ArtistListEntryProps = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +artist: ArtistT,
  +artistList?: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +index: number,
  +mergeForm?: MergeFormT,
  +score?: number,
  +showBeginEnd?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +showSortName?: boolean,
};

const ArtistListRow = ({
  artist,
  artistList,
  checkboxes,
  index,
  instrumentCreditsAndRelTypes,
  mergeForm,
  showBeginEnd = false,
  showInstrumentCreditsAndRelTypes = false,
  showRatings = false,
  showSortName = false,
}: ArtistListRowProps) => {
  const $c = React.useContext(CatalystContext);

  return (
    <>
      {$c.user && (nonEmpty(checkboxes) || mergeForm) ? (
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
          $c={$c}
          entity={artist}
          toMerge={artistList}
        />
      ) : null}
    </>
  );
};

const ArtistListEntry = ({
  artist,
  artistList,
  checkboxes,
  index,
  instrumentCreditsAndRelTypes,
  mergeForm,
  score,
  showBeginEnd,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  showSortName,
}: ArtistListEntryProps): React.Element<'tr'> => (
  <tr className={loopParity(index)} data-score={score ?? null}>
    <ArtistListRow
      artist={artist}
      artistList={artistList}
      checkboxes={checkboxes}
      index={index}
      instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
      mergeForm={mergeForm}
      showBeginEnd={showBeginEnd}
      showInstrumentCreditsAndRelTypes={showInstrumentCreditsAndRelTypes}
      showRatings={showRatings}
      showSortName={showSortName}
    />
  </tr>
);

export default ArtistListEntry;
