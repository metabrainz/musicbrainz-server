/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';
import {lp_attributes} from '../static/scripts/common/i18n/attributes';
import EntityHeader from '../components/EntityHeader';

type Props = {|
  +event: EventT,
  +page: string,
|};

const EventHeader = ({event, page}: Props) => (
  <EntityHeader
    entity={event}
    headerClass="eventheader"
    page={page}
    subHeading={event.typeName ? lp_attributes(event.typeName, 'event_type') : l('Event')}
  />
);

export default EventHeader;
