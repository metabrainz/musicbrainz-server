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
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import AreaLayout from './AreaLayout.js';

component AreaEvents(
  area: AreaT,
  events: $ReadOnlyArray<EventT>,
  pager: PagerT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <AreaLayout entity={area} page="events" title={l('Events')}>
      <h2>{l('Events')}</h2>

      {events.length > 0 ? (
        <form
          action={'/event/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <EventList
              checkboxes="add-to-merge"
              events={events}
              showArtists
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
                {async: true},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {l('This area is not currently associated with any events.')}
        </p>
      )}
      {manifest('common/MB/Control/SelectAll', {async: true})}
      {manifest('common/ratings', {async: true})}
    </AreaLayout>
  );
}

export default AreaEvents;
