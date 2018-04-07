/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {withCatalystContext} = require('../context');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');
const EntityHeader = require('../components/EntityHeader');

type Props = {|
  +$c: CatalystContextT,
  +instrument: InstrumentT,
  +page: string,
|};

const InstrumentHeader = ({$c, instrument, page}: Props) => (
  <EntityHeader
    entity={instrument}
    headerClass="instrumentheader"
    hideEditTab={!($c.user && $c.user.is_relationship_editor)}
    page={page}
    subHeading={instrument.typeName ? lp_attributes(instrument.typeName, 'instrument_type') : l('instrument')}
  />
);

export default withCatalystContext(InstrumentHeader);
