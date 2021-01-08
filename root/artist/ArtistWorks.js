/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WorkList from '../components/list/WorkList';
import PaginatedResults from '../components/PaginatedResults';
import {returnToCurrentPage} from '../utility/returnUri';

import ArtistLayout from './ArtistLayout';

type Props = {
  +$c: CatalystContextT,
  +artist: ArtistT,
  +pager: PagerT,
  +works: ?$ReadOnlyArray<WorkT>,
};

const ArtistWorks = ({
  $c,
  artist,
  pager,
  works,
}: Props): React.Element<typeof ArtistLayout> => (
  <ArtistLayout $c={$c} entity={artist} page="works" title={l('Works')}>
    <h2>{l('Works')}</h2>

    {works?.length ? (
      <form
        action={'/work/merge_queue?' + returnToCurrentPage($c)}
        method="post"
      >
        <PaginatedResults pager={pager}>
          <WorkList
            $c={$c}
            checkboxes="add-to-merge"
            showRatings
            works={works}
          />
        </PaginatedResults>
        {$c.user ? (
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected works for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {l('This artist is not currently associated with any works.')}
      </p>
    )}
  </ArtistLayout>
);

export default ArtistWorks;
