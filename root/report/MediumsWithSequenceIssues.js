/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const MediumsWithSequenceIssues = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) => (
  <Layout fullWidth title={l('Releases with medium number issues')}>
    <h1>{l('Releases with medium number issues')}</h1>

    <ul>
      <li>
        {l(`This report lists all releases with gaps in the medium numbers
            (e.g. there is a medium 1 and 3 but no medium 2).`)}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(MediumsWithSequenceIssues);
