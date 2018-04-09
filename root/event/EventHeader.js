/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');
const EntityHeader = require('../components/EntityHeader');

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

module.exports = EventHeader;
