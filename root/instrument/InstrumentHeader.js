/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import localizeTypeNameForEntity
  from '../static/scripts/common/i18n/localizeTypeNameForEntity.js';

component InstrumentHeader(instrument: InstrumentT, page: string) {
  return (
    <EntityHeader
      entity={instrument}
      headerClass="instrumentheader"
      page={page}
      subHeading={localizeTypeNameForEntity(instrument)}
    />
  );
}

export default InstrumentHeader;
