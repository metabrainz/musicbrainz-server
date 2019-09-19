/*
 * @flow
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
import {withCatalystContext} from '../context';
import Filter from '../static/scripts/common/components/Filter';
import {type FilterFormT} from '../static/scripts/common/components/FilterForm';

import ArtistLayout from './ArtistLayout';

type Props = {
  +$c: CatalystContextT,
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +filterForm: ?FilterFormT,
  +pager: PagerT,
  +releases: $ReadOnlyArray<RecordingT>,
  +showingVariousArtistsOnly: boolean,
  +wantVariousArtistsOnly: boolean,
};

const ArtistReleases = ({
  $c,
  ajaxFilterFormUrl,
  artist,
  filterForm,
  pager,
  releases,
  showingVariousArtistsOnly,
  wantVariousArtistsOnly,
}: Props) => (
  <ArtistLayout entity={artist} page="releases" title={l('Releases')}>
    <h2>{l('Releases')}</h2>

    <Filter
      ajaxFormUrl={ajaxFilterFormUrl}
      initialFilterForm={filterForm}
    />

    {releases.length ? (
      <form action="/release/merge_queue" method="post">
        <PaginatedResults pager={pager}>
          <ReleaseList checkboxes="add-to-merge" releases={releases} />
        </PaginatedResults>
        {$c.user_exists ? (
          <div className="row">
            <FormSubmit label={l('Add selected releases for merging')} />
          </div>
        ) : null}
      </form>
    ) : null}

    {(showingVariousArtistsOnly && pager.total_entries === 0) ? (
      <p>{l('This artist does not have any releases')}</p>

    ) : (
      <>
        {releases.length === 0 ? (
          <p>{l('No releases found')}</p>
        ) : null}

        {showingVariousArtistsOnly ? (
          <p>{l('This artist only has releases by various artists.')}</p>
        ) : wantVariousArtistsOnly ? (
          exp.l(
            `Showing Various Artist releases.
             {show_subset|Show releases by this artist instead}.`,
            {show_subset: `/artist/${artist.gid}/releases?va=0`},
          )
        ) : (
          exp.l(
            `Showing releases by this artist.
             {show_all|Show Various Artist releases instead}.`,
            {show_all: `/artist/${artist.gid}/releases?va=1`},
          )
        )}
      </>
    )}
  </ArtistLayout>
);

export default withCatalystContext(ArtistReleases);
