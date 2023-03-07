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
import {returnToCurrentPage} from '../utility/returnUri.js';

import PlaceLayout from './PlaceLayout.js';

type Props = {
  +events: $ReadOnlyArray<EventT>,
  +pager: PagerT,
  +place: PlaceT,
};

const PlaceEvents = ({
  events,
  pager,
  place,
}: Props): React$Element<typeof PlaceLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <PlaceLayout entity={place} page="events" title={l('Events')}>
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
          {l('This place is not currently associated with any events.')}
        </p>
      )}
    </PlaceLayout>
  );
};

export default PlaceEvents;
