/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import InstrumentList from './components/InstrumentList';
import type {ReportDataT, ReportInstrumentT} from './types';

const InstrumentsWithoutWikidata = ({
  $c,
  generated,
  items,
  pager,
}: ReportDataT<ReportInstrumentT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Instruments without a Wikidata link')}>
    <h1>{l('Instruments without a Wikidata link')}</h1>

    <ul>
      <li>
        {l('This report shows instruments without Wikidata relationships.')}
      </li>
      <li>
        {texp.l('Total instruments found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

    </ul>

    <InstrumentList $c={$c} items={items} pager={pager} />

  </Layout>
);

export default InstrumentsWithoutWikidata;
