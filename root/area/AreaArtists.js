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
import {returnToCurrentPage} from '../utility/returnUri.js';

import AreaLayout from './AreaLayout.js';

type Props = {
  +area: AreaT,
  +artists: ?$ReadOnlyArray<ArtistT>,
  +pager: PagerT,
};

const AreaArtists = ({
  area,
  artists,
  pager,
}: Props): React.Element<typeof AreaLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <AreaLayout entity={area} page="artists" title={l('Artists')}>
      <h2>{l('Artists')}</h2>

      {artists?.length ? (
        <form
          action={'/artist/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ArtistList
              artists={artists}
              checkboxes="add-to-merge"
              showBeginEnd
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
          {l('This area is not currently associated with any artists.')}
        </p>
      )}
    </AreaLayout>
  );
};

export default AreaArtists;
