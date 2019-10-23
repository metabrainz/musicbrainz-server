/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import EventList from '../components/list/EventList';
import PaginatedResults from '../components/PaginatedResults';

import ArtistLayout from './ArtistLayout';

type Props = {
  +$c: CatalystContextT,
  +artist: ArtistT,
  +events: $ReadOnlyArray<EventT>,
  +pager: PagerT,
};

const ArtistEvents = ({
  $c,
  artist,
  events,
  pager,
}: Props) => (
  <ArtistLayout entity={artist} page="events" title={l('Events')}>
    <h2>{l('Events')}</h2>

    {events.length > 0 ? (
      <form action="/event/merge_queue" method="post">
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
        {$c.user_exists ? (
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
        {l('This artist is not currently associated with any events.')}
      </p>
    )}
  </ArtistLayout>
);

export default withCatalystContext(ArtistEvents);
