/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../components/FormSubmit';
import ReleaseList from '../components/list/ReleaseList';
import PaginatedResults from '../components/PaginatedResults';
import Filter from '../static/scripts/common/components/Filter';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm';
import {returnToCurrentPage} from '../utility/returnUri';

import ArtistLayout from './ArtistLayout';

type Props = {
  +$c: CatalystContextT,
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
  $c,
  ajaxFilterFormUrl,
  artist,
  filterForm,
  hasFilter,
  pager,
  releases,
  showingVariousArtistsOnly,
  wantVariousArtistsOnly,
}: Props): React.Element<typeof ArtistLayout> => (
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

export default ArtistReleases;
