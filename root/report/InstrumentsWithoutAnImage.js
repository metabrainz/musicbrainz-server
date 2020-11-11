/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import InstrumentList from './components/InstrumentList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportInstrumentT} from './types';

const InstrumentsWithoutAnImage = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportInstrumentT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows instruments without an image relationship
       to StaticBrainz (i.e. without an IROMBOOK image).`,
    )}
    entityType="instrument"
    filtered={filtered}
    generated={generated}
    title={l('Instruments without an image')}
    totalEntries={pager.total_entries}
  >
    <InstrumentList $c={$c} items={items} pager={pager} />
  </ReportLayout>
);

export default InstrumentsWithoutAnImage;
