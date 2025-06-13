/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from '../components/list/ArtistList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import InstrumentLayout from './InstrumentLayout.js';

component InstrumentArtists(
  artists: $ReadOnlyArray<ArtistT>,
  instrument: InstrumentT,
  instrumentCreditsAndRelTypes: InstrumentCreditsAndRelTypesT,
  pager: PagerT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <InstrumentLayout
      entity={instrument}
      page="artists"
      title={l('Artists')}
    >
      <h2>{l('Artists')}</h2>

      {artists && artists.length > 0 ? (
        <form
          action={'/artist/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ArtistList
              artists={artists}
              checkboxes="add-to-merge"
              instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
              showInstrumentCreditsAndRelTypes
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
            <>
              <ListMergeButtonsRow
                label={l('Add selected artists for merging')}
              />
              {manifest(
                'common/components/ListMergeButtonsRow',
                {async: true},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {l('No artists found.')}
        </p>
      )}
      {manifest('common/MB/Control/SelectAll', {async: true})}
      {manifest('common/ratings', {async: true})}
    </InstrumentLayout>
  );
}

export default InstrumentArtists;
