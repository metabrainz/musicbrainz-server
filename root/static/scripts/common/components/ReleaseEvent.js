/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatDate from '../utility/formatDate';
import isDateEmpty from '../utility/isDateEmpty';

import EntityLink from './EntityLink';

type Props = {
  +event: ReleaseEventT,
};

const ReleaseEvent = ({event}: Props) => (
  <>
    {isDateEmpty(event.date) ? null : (
      <>
        <span className="release-date">
          {formatDate(event.date)}
        </span>
        {' '}
      </>
    )}
    {event.country ? <EntityLink entity={event.country} /> : null}
  </>
);

export default ReleaseEvent;
