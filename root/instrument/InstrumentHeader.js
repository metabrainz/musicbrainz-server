/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
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
  +instrument: InstrumentT,
  +page: string,
|};

const InstrumentHeader = ({instrument, page}: Props) => (
  <EntityHeader
    entity={instrument}
    headerClass="instrumentheader"
    page={page}
    subHeading={instrument.typeName ? lp_attributes(instrument.typeName, 'instrument_type') : l('instrument')}
  />
);

export default InstrumentHeader;
