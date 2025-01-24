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
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import Filter from '../static/scripts/common/components/Filter.js';
import {type EventFilterT}
  from '../static/scripts/common/components/FilterForm.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';

import ArtistLayout from './ArtistLayout.js';

component ArtistEvents(
  ajaxFilterFormUrl: string,
  artist: ArtistT,
  events: $ReadOnlyArray<EventT>,
  filterForm: ?EventFilterT,
  hasFilter: boolean,
  pager: PagerT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <ArtistLayout entity={artist} page="events" title={l('Events')}>
      <h2>{l('Events')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {events.length > 0 ? (
        <form
          action="/event/merge_queue"
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
            <>
              <ListMergeButtonsRow
                label={l('Add selected events for merging')}
              />
              {manifest(
                'common/components/ListMergeButtonsRow',
                {async: 'async'},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {hasFilter
            ? l('No events found that match this search.')
            : l('This artist is not currently associated with any events.')}
        </p>
      )}

      {manifest('common/components/Filter', {async: 'async'})}
      {manifest('common/MB/Control/SelectAll', {async: 'async'})}
    </ArtistLayout>
  );
}

export default ArtistEvents;
