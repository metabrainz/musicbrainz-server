/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import {ANNOTATION_REPORT_TEXT} from './constants';
import WorkAnnotationList from './components/WorkAnnotationList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportWorkAnnotationT} from './types';

const AnnotationsWorks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkAnnotationT>):
React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Work annotations')}>
    <h1>{l('Work annotations')}</h1>

    <ul>
      <li>
        {l('This report lists works with annotations.')}
      </li>
      <li>{ANNOTATION_REPORT_TEXT()}</li>
      <li>
        {texp.l('Total works found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <WorkAnnotationList items={items} pager={pager} />

  </Layout>
);

export default AnnotationsWorks;
