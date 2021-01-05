/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from '../components/list/ArtistList';
import PaginatedResults from '../components/PaginatedResults';
import {returnToCurrentPage} from '../utility/returnUri';

import InstrumentLayout from './InstrumentLayout';

type Props = {|
  ...InstrumentCreditsAndRelTypesRoleT,
  +$c: CatalystContextT,
  +artists: $ReadOnlyArray<ArtistT>,
  +instrument: InstrumentT,
  +pager: PagerT,
|};

const InstrumentArtists = ({
  $c,
  artists,
  instrument,
  instrumentCreditsAndRelTypes,
  pager,
}: Props): React.Element<typeof InstrumentLayout> => (
  <InstrumentLayout
    $c={$c}
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
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected artists for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {l('No artists found.')}
      </p>
    )}
  </InstrumentLayout>
);

export default InstrumentArtists;
