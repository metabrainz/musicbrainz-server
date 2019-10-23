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

const buildReleaseDate = (event) => event.date ? (
  <li key={formatDate(event.date)}>
    {formatDate(event.date)}
  </li>
) : null;

type ReleaseEventsProps = {
  +events?: $ReadOnlyArray<ReleaseEventT>,
};

const ReleaseDates = ({events}: ReleaseEventsProps) => (
  events && events.length ? (
    <ul className="links nowrap">
      {events.map(buildReleaseDate)}
    </ul>
  ) : null
);

export default ReleaseDates;
