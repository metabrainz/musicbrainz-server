/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EventLayout from './EventLayout.js';

type Props = {
  +event: EventT,
};

const EventArtDarkened = ({
  event,
}: Props): React$Element<typeof EventLayout> => {
  const title = lp('Cannot add event art', 'plural');

  return (
    <EventLayout entity={event} page="event-art" title={title}>
      <h2>{title}</h2>
      <p>
        {l(`The Event Art Archive has had a takedown request in the past
            for this event, so we are unable to allow any more uploads.`)}
      </p>
    </EventLayout>
  );
};

export default EventArtDarkened;
