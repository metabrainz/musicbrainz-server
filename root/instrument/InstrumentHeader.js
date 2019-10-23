/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EntityHeader from '../components/EntityHeader';

type Props = {
  +instrument: InstrumentT,
  +page: string,
};

const InstrumentHeader = ({instrument, page}: Props) => (
  <EntityHeader
    entity={instrument}
    headerClass="instrumentheader"
    page={page}
    subHeading={instrument.typeName ? lp_attributes(instrument.typeName, 'instrument_type') : l('instrument')}
  />
);

export default InstrumentHeader;
