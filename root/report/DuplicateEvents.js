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
import {l} from '../static/scripts/common/i18n';

import EventList from './components/EventList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportEventT} from './types';

const DuplicateEvents = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEventT>) => (
  <Layout fullWidth title={l('Possible duplicate events')}>
    <h1>{l('Possible duplicate events')}</h1>

    <ul>
      <li>
        {l(`This report lists events happening at the same place
            on the same date. If there are duplicates (for example,
            if there are separate events for headliner and supporting artist)
            please merge them.`)}
      </li>
      <li>{l('Total events found: {count}', {count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <EventList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DuplicateEvents);
