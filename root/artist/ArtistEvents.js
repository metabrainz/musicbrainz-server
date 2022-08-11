/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EventList from '../components/list/EventList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import Filter from '../static/scripts/common/components/Filter.js';
import {type FilterFormT}
  from '../static/scripts/common/components/FilterForm.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ArtistLayout from './ArtistLayout.js';

type Props = {
  +$c: CatalystContextT,
  +ajaxFilterFormUrl: string,
  +artist: ArtistT,
  +events: $ReadOnlyArray<EventT>,
  +filterForm: ?FilterFormT,
  +hasFilter: boolean,
  +pager: PagerT,
};

const ArtistEvents = ({
  $c,
  ajaxFilterFormUrl,
  artist,
  events,
  filterForm,
  hasFilter,
  pager,
}: Props): React.Element<typeof ArtistLayout> => (
  <ArtistLayout entity={artist} page="events" title={l('Events')}>
    <h2>{l('Events')}</h2>

    <Filter
      ajaxFormUrl={ajaxFilterFormUrl}
      initialFilterForm={filterForm}
    />

    {events.length > 0 ? (
      <form
        action={'/event/merge_queue?' + returnToCurrentPage($c)}
        method="post"
      >
        <PaginatedResults pager={pager}>
          <EventList
            artist={artist}
            artistRoles
            checkboxes="add-to-merge"
            events={events}
            showLocation
            showRatings
            showType
          />
        </PaginatedResults>
        {$c.user ? (
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected events for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    ) : (
      <p>
        {hasFilter
          ? l('No events found that match this search.')
          : l('This artist is not currently associated with any events.')}
      </p>
    )}
  </ArtistLayout>
);

export default ArtistEvents;
