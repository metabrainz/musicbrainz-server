/*
 * @flow strict-local
 * Copyright (C) 2021 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import CDTocReleaseList from './components/CDTocReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportCDTocReleaseT} from './types';

const CDTocNotApplied = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportCDTocReleaseT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Disc IDs attached but not applied')}>
    <h1>{l('Disc IDs attached but not applied')}</h1>

    <ul>
      <li>
        {l(`This report shows disc IDs attached to a release but obviously not
        applied because at last one track duration is unknown on the release.
        The report is also restricted to mediums where only one disc ID is
        attached, so it is highly likely that the disc ID can be applied
        without any worries. Do make sure though that no existing durations
        clash with the disc ID, or that any clashes are clear mistakes.`)}
      </li>
      <li>
        {texp.l('Total discIDs found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <CDTocReleaseList items={items} pager={pager} />

  </Layout>
);

export default CDTocNotApplied;
