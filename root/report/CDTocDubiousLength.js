/*
 * @flow strict-local
 * Copyright (C) 2020 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import CDTocList from './components/CDTocList';
import type {ReportDataT, ReportCDTocT} from './types';

const CDTocDubiousLength = ({
  $c,
  generated,
  items,
  pager,
}: ReportDataT<ReportCDTocT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Disc IDs with dubious duration')}>
    <h1>{l('Disc IDs with dubious duration')}</h1>

    <ul>
      <li>
        {l(`This report shows disc IDs indicating a total duration much longer
        than what a standard CD allows (at least 88 minutes for a CD, or 30
        minutes for a mini-CD). This usually means a disc ID was created for
        the wrong format (SACD) or with a buggy tool.`)}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>
    </ul>

    <CDTocList items={items} pager={pager} />

  </Layout>
);

export default CDTocDubiousLength;
