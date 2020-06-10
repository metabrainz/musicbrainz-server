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
import RecordingList from '../components/list/RecordingList';
import PaginatedResults from '../components/PaginatedResults';
import Filter from '../static/scripts/common/components/Filter';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm';

import ArtistLayout from './ArtistLayout';

type Props = {
  +$c: CatalystContextT,
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +filterForm: ?FilterFormT,
  +hasFilter: boolean,
  +pager: PagerT,
  +recordings: $ReadOnlyArray<RecordingT>,
  +standaloneOnly: boolean,
  +videoOnly: boolean,
};

const ArtistRecordings = ({
  $c,
  ajaxFilterFormUrl,
  artist,
  filterForm,
  hasFilter,
  pager,
  recordings,
  standaloneOnly,
  videoOnly,
}: Props): React.Element<typeof ArtistLayout> => (
  <ArtistLayout $c={$c} entity={artist} page="recordings" title={l('Recordings')}>
    <h2>{l('Recordings')}</h2>

    <Filter
      ajaxFormUrl={ajaxFilterFormUrl}
      initialFilterForm={filterForm}
    />

    {recordings.length ? (
      <form action="/recording/merge_queue" method="post">
        <PaginatedResults pager={pager}>
          <RecordingList
            $c={$c}
            checkboxes="add-to-merge"
            recordings={recordings}
            showRatings
          />
        </PaginatedResults>
        {$c.user ? (
          <div className="row">
            <FormSubmit label={l('Add selected recordings for merging')} />
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {hasFilter
          ? l('No recordings found that match this search.')
          : l('No recordings found.')}
      </p>
    )}

    {standaloneOnly ? (
      <p>
        {exp.l(
          `Showing only standalone recordings.
           {show_all|Show all recordings instead}.`,
          {show_all: `/artist/${artist.gid}/recordings?standalone=0`},
        )}
      </p>

    ) : videoOnly ? (
      <p>
        {exp.l(
          'Showing only videos. {show_all|Show all recordings instead}.',
          {show_all: `/artist/${artist.gid}/recordings?video=0`},
        )}
      </p>

    ) : (
      <p>
        {exp.l(
          `Showing all recordings.
           {show_sa|Show only standalone recordings instead}, or
           {show_vid|show only videos}.`,
          {
            show_sa: `/artist/${artist.gid}/recordings?standalone=1`,
            show_vid: `/artist/${artist.gid}/recordings?video=1`,
          },
        )}
      </p>
    )}
  </ArtistLayout>
);

export default ArtistRecordings;
