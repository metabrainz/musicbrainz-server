/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import InstrumentList from './components/InstrumentList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportInstrumentT} from './types.js';

const InstrumentsWithoutWikidata = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportInstrumentT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows instruments without Wikidata relationships.`,
    )}
    entityType="instrument"
    filtered={filtered}
    generated={generated}
    title={l('Instruments without a Wikidata link')}
    totalEntries={pager.total_entries}
  >
    <InstrumentList items={items} pager={pager} />
  </ReportLayout>
);

export default InstrumentsWithoutWikidata;
