/*
 * @flow strict-local
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
import RecordingAnnotationList from './components/RecordingAnnotationList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingAnnotationT} from './types';

const AnnotationsRecordings = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingAnnotationT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Recording annotations')}>
    <h1>{l('Recording annotations')}</h1>

    <ul>
      <li>
        {l('This report lists recordings with annotations.')}
      </li>
      <li>{ANNOTATION_REPORT_TEXT()}</li>
      <li>
        {texp.l('Total recordings found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <RecordingAnnotationList items={items} pager={pager} />

  </Layout>
);

export default AnnotationsRecordings;
