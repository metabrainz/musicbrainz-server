/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from './DescriptiveLink';

type Props = {
  +event: EventT,
};

const EventLocations = ({event}: Props): React.Element<'ul'> => (
  <ul>
    {event.places.map(place => (
      <li key={place.entity.id}>
        <DescriptiveLink content={place.credit} entity={place.entity} />
      </li>
    ))}
    {event.areas.map(area => (
      <li key={area.entity.id}>
        <DescriptiveLink content={area.credit} entity={area.entity} />
      </li>
    ))}
  </ul>
);

export default EventLocations;
