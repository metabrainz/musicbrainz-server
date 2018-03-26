/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import formatDate from '../static/scripts/common/utility/formatDate';
import isDateEmpty from '../static/scripts/common/utility/isDateEmpty';

type Props = {|
  +event: ReleaseEventT,
|};

const ReleaseEvent = ({event}: Props) => (
  <>
    {event.country ? <EntityLink entity={event.country} /> : null}
    {isDateEmpty(event.date) ? null : (
      <>
        <br />
        <span className="release-date">
          {formatDate(event.date)}
        </span>
      </>
    )}
  </>
);

export default ReleaseEvent;
