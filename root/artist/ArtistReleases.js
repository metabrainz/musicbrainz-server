/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import ReleaseList from '../components/list/ReleaseList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import Filter from '../static/scripts/common/components/Filter.js';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ArtistLayout from './ArtistLayout.js';

type Props = {
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +filterForm: ?FilterFormT,
  +hasFilter: boolean,
  +pager: PagerT,
  +releases: $ReadOnlyArray<ReleaseT>,
  +showingVariousArtistsOnly: boolean,
  +wantVariousArtistsOnly: boolean,
};

const ArtistReleases = ({
  ajaxFilterFormUrl,
  artist,
  filterForm,
  hasFilter,
  pager,
  releases,
  showingVariousArtistsOnly,
  wantVariousArtistsOnly,
}: Props): React.Element<typeof ArtistLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <ArtistLayout entity={artist} page="releases" title={l('Releases')}>
      <h2>{l('Releases')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {releases.length ? (
        <form
          action={'/release/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ReleaseList checkboxes="add-to-merge" releases={releases} />
          </PaginatedResults>
          {$c.user ? (
            <div className="row">
              <FormSubmit label={l('Add selected releases for merging')} />
            </div>
          ) : null}
        </form>
      ) : null}

      {releases.length === 0 ? (
        <p>
          {hasFilter
            ? l('No releases found that match this search.')
            : l('No releases found.')}
        </p>
      ) : null}

      {wantVariousArtistsOnly ? (
        exp.l(
          `Showing Various Artist releases.
           {show_subset|Show releases by this artist instead}.`,
          {show_subset: `/artist/${artist.gid}/releases?va=0`},
        )
      ) : showingVariousArtistsOnly ? (
        /*
         * The user didn't specifically ask for VA releases, but nothing
         * else was found, so we're showing them anyway.
         */
        <p>
          {hasFilter ? (
            l('This search only found releases by various artists.')
          ) : (
            l('This artist only has releases by various artists.')
          )}
        </p>
      ) : (
        exp.l(
          `Showing releases by this artist.
           {show_all|Show Various Artist releases instead}.`,
          {show_all: `/artist/${artist.gid}/releases?va=1`},
        )
      )}
    </ArtistLayout>
  );
};

export default ArtistReleases;
