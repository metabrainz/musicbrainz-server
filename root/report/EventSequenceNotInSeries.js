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

import EventList from './components/EventList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportEventT} from './types';

const EventSequenceNotInSeries = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventT>) => (
  <Layout fullWidth title={l('Events which should be part of series or larger event')}>
    <h1>{l('Events which should be part of series or larger event')}</h1>

    <ul>
      <li>
        {l(`This report lists events where the event name indicates that it
            may have to be part of a series or a larger event.`)}
      </li>
      <li>{texp.l('Total events found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <EventList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(EventSequenceNotInSeries);
