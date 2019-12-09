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

import {ANNOTATION_REPORT_TEXT} from './constants';
import PlaceAnnotationList from './components/PlaceAnnotationList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportPlaceAnnotationT} from './types';

const AnnotationsPlaces = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportPlaceAnnotationT>) => (
  <Layout fullWidth title={l('Place annotations')}>
    <h1>{l('Place annotations')}</h1>

    <ul>
      <li>
        {l('This report lists places with annotations.')}
      </li>
      <li>{ANNOTATION_REPORT_TEXT()}</li>
      <li>
        {texp.l('Total places found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <PlaceAnnotationList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(AnnotationsPlaces);
