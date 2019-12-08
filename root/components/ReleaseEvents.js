/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatDate from '../static/scripts/common/utility/formatDate';

import ReleaseEvent from './ReleaseEvent';

const releaseEventKey = event => (
  String(event.country ? event.country.id : '') + '\0' +
  formatDate(event.date)
);

const buildReleaseEvent = (event) => (
  <li key={releaseEventKey(event)}>
    <ReleaseEvent event={event} />
  </li>
);

type ReleaseEventsProps = {
  +events: $ReadOnlyArray<ReleaseEventT>,
};

const ReleaseEvents = ({events}: ReleaseEventsProps) => (
  events.length ? (
    <ul className="links">
      {events.map(buildReleaseEvent)}
    </ul>
  ) : null
);

export default ReleaseEvents;
